# Pin as many cells as possible, registers AND combinational cells, where a
# good earlier run had them, before global placement, so that run's draw is
# reused and the placer only has to find room for what is new.
#
# Registers are matched by the RTL name of the net on their data output, as
# odb_anchor_seq.py does.  Combinational cells have no stable name (Yosys
# renumbers _NNNN_ instances and nets every run), so they are matched by
# structure, in two passes:
#  1. exact: every synthetic net gets a key built from its driver's cell
#     function and the keys of the driver's inputs, propagated forward from
#     the anchors (register outputs, ports, macro pins, ties); equal keys =
#     the same logic cone in both netlists.
#  2. local: ABC re-maps gates here and there when the RTL changes, and pass
#     1 loses every cell downstream of such a spot.  So the unmatched cells
#     are labelled by their neighbourhood a few hops wide, in both directions
#     (Weisfeiler-Lehman refinement over the anchors); cells whose label is
#     unique on both sides (or equally repeated: interchangeable twins) are
#     matched, become anchors, and the labelling repeats until nothing new
#     matches.  A changed gate thus blocks only the cells next to it.
# Buffers are collapsed out of both graphs (the reference placement carries
# the resizer's fanout buffers, the pre-placement netlist does not).  A cell
# is pinned onto its reference cell's spot and orientation with FIRM status
# (DEF FIXED, the placers leave it) when the reference footprint holds it.
#
#   --dump TABLE.json   write the reference graph + placement from a placed
#                       design (its post-detailed-placement ODB); no pinning
#   --table TABLE.json  pin this design's cells from the table
#
# Both modes take an input ODB and --output-odb.  Must run after the rows are
# cut, the taps and the PDN are in (cut_rows slices rows around FIRM cells),
# i.e. right before global placement; the floorplan must be the reference's.
# 2026-09-30, the "I want can_ko40's placement back" experiment, part 2.
import hashlib
import json
import re
import sys
from collections import defaultdict, Counter

import click
import odb
from reader import click_odb

sys.setrecursionlimit(100000)

SEQ_MASTER = re.compile(r"(dfrbp|dfbp|dfrbpq|sdfbbp|sdfrbp|dlhq|dlhr|dlhrq|dllr|dllrq|dlclkp|dllrtp)", re.I)
PHYSICAL = re.compile(r"(fill|decap|tap|endcap|antenna|diode)", re.I)
BUFFER = re.compile(r"_buf_\d+$", re.I)
TIE = re.compile(r"_tie", re.I)
SYNTHETIC = re.compile(r"^(_\d+_|net\d+|\$.*)$")
STRENGTH = re.compile(r"_\d+$")


def H(*parts):
    return hashlib.blake2b("|".join(parts).encode(), digest_size=10).hexdigest()


def is_seq(master):
    return master.isSequential() or SEQ_MASTER.search(master.getName()) is not None


def extract(block):
    """The logic graph of a block: cells {name: {fn, master, ins, outs, anchor,
    x, y, orient}} and nets {name: {anchor}}, buffers collapsed, physical cells
    left out.  Anchors are the stable identities: "S:<rtl>" for a register,
    "N:<name>" for a net driven by a register, a port or a macro (RTL names
    that survive synthesis), "T:<tie>" for constants."""
    u = block.getDbUnitsPerMicron()

    def clean(name):
        return name.replace("\\", "")

    # buffer collapse: output net -> input net, chased through chains
    alias = {}
    for inst in block.getInsts():
        m = inst.getMaster()
        if m.isBlock() or not BUFFER.search(m.getName()):
            continue
        src = dst = None
        for it in inst.getITerms():
            mt = it.getMTerm()
            if mt.getSigType() != "SIGNAL" or it.getNet() is None:
                continue
            if mt.getIoType() == "INPUT":
                src = it.getNet().getName()
            elif mt.getIoType() == "OUTPUT":
                dst = it.getNet().getName()
        if src is not None and dst is not None:
            alias[dst] = src

    def canon(n):
        seen = set()
        while n in alias and n not in seen:
            seen.add(n)
            n = alias[n]
        return n

    cells = {}
    nets = {}
    unnamed_regs = 0
    for inst in block.getInsts():
        m = inst.getMaster()
        mname = m.getName()
        if m.isBlock() or PHYSICAL.search(mname) or BUFFER.search(mname):
            continue
        ins, outs = [], []
        for it in inst.getITerms():
            mt = it.getMTerm()
            if mt.getSigType() != "SIGNAL" or it.getNet() is None:
                continue
            n = canon(it.getNet().getName())
            (ins if mt.getIoType() == "INPUT" else outs).append((mt.getName(), n))
        fn = STRENGTH.sub("", mname)
        if TIE.search(mname):
            for _, n in outs:
                nets.setdefault(n, {})["anchor"] = "T:" + fn
            continue                              # tie cells are not placed by match
        anchor = None
        if is_seq(m):
            byname = dict(outs)
            q = byname.get("Q") or byname.get("Q_N") or (outs[0][1] if outs else None)
            if q is None or SYNTHETIC.match(clean(q)):
                unnamed_regs += 1
                q = None
            anchor = ("S:" + clean(q)) if q else None
            for _, n in outs:
                nets.setdefault(n, {})["anchor"] = ("N:" + clean(n)) if not SYNTHETIC.match(clean(n)) else None
        x, y = inst.getLocation()
        cells[inst.getName()] = {
            "fn": fn, "master": mname, "seq": is_seq(m), "anchor": anchor,
            "ins": sorted(n for _, n in ins), "outs": [(p, n) for p, n in outs],
            "x": x / u, "y": y / u, "orient": inst.getOrient(), "placed": inst.isPlaced(),
        }
        for _, n in ins + outs:
            nets.setdefault(n, {}).setdefault("anchor", None)
    # macro pins and ports: named nets with no register driver
    for inst in block.getInsts():
        m = inst.getMaster()
        if not m.isBlock():
            continue
        for it in inst.getITerms():
            mt = it.getMTerm()
            if mt.getIoType() == "OUTPUT" and it.getNet() is not None:
                n = canon(it.getNet().getName())
                nets.setdefault(n, {})["anchor"] = "M:" + clean(inst.getName()) + ":" + mt.getName()
    for bt in block.getBTerms():
        if bt.getIoType() == "INPUT" and bt.getNet() is not None:
            n = canon(bt.getNet().getName())
            nets.setdefault(n, {})["anchor"] = "N:" + clean(n)
    return {"cells": cells, "nets": nets, "unnamed_regs": unnamed_regs}


def forward_keys(g):
    """Pass 1: the exact forward key of every cell (anchors as themselves)."""
    cells, nets = g["cells"], g["nets"]
    driver = {}
    for cname, c in cells.items():
        for p, n in c["outs"]:
            driver[n] = (cname, p)
    net_key, cell_key = {}, {}
    busy = set()

    def kn(n):
        if n in net_key:
            return net_key[n]
        a = nets.get(n, {}).get("anchor")
        if a:
            net_key[n] = a
            return a
        if n in busy:
            return "CYC"
        busy.add(n)
        d = driver.get(n)
        if d is None:
            k = "U:" + n                          # undriven
        else:
            c = cells[d[0]]
            if c["seq"]:
                k = (c["anchor"] or "RU:" + n) + ":" + d[1]   # a register that lost its name
            else:
                k = kc(d[0]) + ":" + d[1]
        busy.discard(n)
        net_key[n] = k
        return k

    def kc(cname):
        if cname in cell_key:
            return cell_key[cname]
        c = cells[cname]
        k = "C:" + H(c["fn"], *sorted(kn(n) for n in c["ins"]))
        cell_key[cname] = k
        return k

    return {cname: (c["anchor"] or kc(cname)) for cname, c in cells.items()}


def wl_labels(g, anchor_of, rounds):
    """Local labels: anchored cells/nets carry their anchor id; the others a
    hash of their neighbours' labels, refined `rounds` times."""
    cells, nets = g["cells"], g["nets"]
    sinks = defaultdict(list)
    driver = {}
    for cname, c in cells.items():
        for n in c["ins"]:
            sinks[n].append(cname)
        for p, n in c["outs"]:
            driver[n] = cname
    net_anchor = {n: v.get("anchor") for n, v in nets.items()}
    net_anchor.update(anchor_of["nets"])
    cl = {cname: anchor_of["cells"].get(cname) or c["anchor"] or c["fn"] for cname, c in cells.items()}
    nl = {n: net_anchor.get(n) or "?" for n in nets}
    for _ in range(rounds):
        nl2 = {}
        for n in nets:
            a = net_anchor.get(n)
            nl2[n] = a if a else H("n", cl.get(driver.get(n), "src?"), *sorted(cl[s] for s in sinks[n]))
        cl2 = {}
        for cname, c in cells.items():
            a = anchor_of["cells"].get(cname) or c["anchor"]
            cl2[cname] = a if a else H("c", c["fn"], *sorted(nl2[n] for n in c["ins"]), "/", *sorted(nl2[n] for _, n in c["outs"]))
        cl, nl = cl2, nl2
    return cl


def match(ref, cur, rounds=3, max_iter=30, log=print):
    """Pairs {current cell: reference cell}.  Registers by name and the exact
    forward keys first, then WL refinement until it stalls."""
    pairs = {}
    ref_used = set()

    def pair_by(keys_cur, keys_ref, what):
        by_ref = defaultdict(list)
        for rname, k in keys_ref.items():
            if rname not in ref_used:
                by_ref[k].append(rname)
        by_cur = defaultdict(list)
        for cname, k in keys_cur.items():
            if cname not in pairs:
                by_cur[k].append(cname)
        n = 0
        for k, cs in by_cur.items():
            rs = by_ref.get(k)
            if not rs or len(cs) != len(rs):
                continue                          # unique on both sides, or twins in equal number
            for cname, rname in zip(sorted(cs), sorted(rs)):
                if cur["cells"][cname]["fn"] != ref["cells"][rname]["fn"]:
                    continue
                pairs[cname] = rname
                ref_used.add(rname)
                n += 1
        log(f"  {what}: +{n} matched ({len(pairs)} total)")
        return n

    pair_by(forward_keys(cur), forward_keys(ref), "exact forward keys")

    for it in range(max_iter):
        a_cur = {"cells": {}, "nets": {}}
        a_ref = {"cells": {}, "nets": {}}
        for cname, rname in pairs.items():
            a_cur["cells"][cname] = "A:" + rname
            a_ref["cells"][rname] = "A:" + rname
            for (p, n), (_, rn) in zip(cur["cells"][cname]["outs"], ref["cells"][rname]["outs"]):
                a_cur["nets"][n] = "A:" + rname + ":" + p
                a_ref["nets"][rn] = "A:" + rname + ":" + p
        n = pair_by(wl_labels(cur, a_cur, rounds), wl_labels(ref, a_ref, rounds), f"local round {it + 1}")
        if n == 0:
            break
    return pairs


@click.command()
@click.option("--dump", default=None, help="Write the reference graph + placement from this (placed) design and stop")
@click.option("--table", default=None, help="Reference table to pin this design's cells from")
@click.option("--status", default="FIRM", help="Placement status given to the pinned cells: FIRM (DEF FIXED) or PLACED")
@click.option("--rounds", default=3, help="WL label radius (hops) for the local matching")
@click.option("--seq-only", is_flag=True, help="Pin the registers only (the combinational matches are reported, not applied)")
@click.option("--report", default=None, help="Write the pairs (current inst -> reference inst) as JSON")
@click_odb
def main(reader, dump, table, status, rounds, seq_only, report):
    block = reader.block
    u = block.getDbUnitsPerMicron()
    g = extract(block)
    nseq = sum(1 for c in g["cells"].values() if c["seq"])
    print(f"{len(g['cells'])} logic cells ({nseq} registers, {g['unnamed_regs']} of them unnamed), {len(g['nets'])} nets")

    if dump:
        with open(dump, "w") as f:
            json.dump(g, f)
        print(f"reference graph written to {dump}")
        return

    ref = json.load(open(table))
    print(f"reference: {len(ref['cells'])} logic cells")
    pairs = match(ref, g, rounds=rounds)
    if report:
        with open(report, "w") as f:
            json.dump(pairs, f, indent=0)

    widths = {m.getName(): m.getWidth() for lib in reader.db.getLibs() for m in lib.getMasters()}
    site_rows = []
    for row in block.getRows():
        bb = row.getBBox()
        site_rows.append((bb.yMin(), bb.xMin(), bb.xMax(), row.getSite().getWidth()))
    site_rows.sort()

    def snap(x, y):
        dy = min(abs(r[0] - y) for r in site_rows)
        same_y = [r for r in site_rows if abs(r[0] - y) == dy]
        holding = [r for r in same_y if r[1] <= x < r[2]]
        best = holding[0] if holding else min(same_y, key=lambda r: min(abs(r[1] - x), abs(r[2] - x)))
        ymin, xmin, xmax, sw = best
        x = xmin + round((x - xmin) / sw) * sw
        return max(xmin, min(x, xmax - sw)), ymin

    pinned = Counter()
    too_wide = moved_far = taken = 0
    spots = set()
    insts = {inst.getName(): inst for inst in block.getInsts()}
    for cname, rname in pairs.items():
        c, r = g["cells"][cname], ref["cells"][rname]
        kind = "registers" if c["seq"] else "comb"
        inst = insts[cname]
        if inst.getPlacementStatus() in ("FIRM", "LOCKED"):
            continue
        if not r["placed"]:
            continue
        if widths.get(r["master"], 0) < inst.getMaster().getWidth():
            too_wide += 1
            continue
        if kind == "comb" and seq_only:
            pinned["comb (not applied)"] += 1
            continue
        x, y = snap(int(round(r["x"] * u)), int(round(r["y"] * u)))
        if abs(x - r["x"] * u) > u or abs(y - r["y"] * u) > u:
            moved_far += 1
        if (x, y) in spots:
            taken += 1
            continue
        spots.add((x, y))
        inst.setOrient(r["orient"])
        inst.setLocation(x, y)
        inst.setPlacementStatus(status)
        pinned[kind] += 1
    unmatched = Counter("registers" if c["seq"] else "comb" for cname, c in g["cells"].items() if cname not in pairs)
    print(f"{sum(pinned.values())} cells pinned {status}: {dict(pinned)}; {moved_far} snapped by more than 1 um, "
          f"{taken} skipped (spot taken), {too_wide} skipped (reference cell narrower)")
    print(f"unmatched: {dict(unmatched)}")
    free = sum(1 for cname in g["cells"] if insts[cname].getPlacementStatus() not in ("FIRM", "LOCKED"))
    print(f"{free} of {len(g['cells'])} logic cells are left to the placer")


if __name__ == "__main__":
    main()
