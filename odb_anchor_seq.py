# Pin the flops and latches of this design where a good earlier run had
# them (a tools/seq_placement.py JSON table keyed by RTL name), before
# global placement: the registers become the skeleton of that run's draw
# and the placer arranges the combinational cells around them.
#
# A register is matched by the name of the net on its data output (Q, or
# Q_N when that is the only output), which Yosys keeps through synthesis
# and flattening; instance names (_NNNN_) are renumbered every run and are
# useless.  Registers the table does not know (new RTL) and names the table
# has but the design no longer has are left to the placer and listed.  Pinned
# cells get the table's spot and orientation and FIRM status (DEF FIXED), which the
# global and detailed placers honour; the spot is snapped to the row it is
# on so legalization has nothing to do.  Runs after the macro placement and
# the keep-outs (the rows and the floorplan must be those of the table's
# run).  2026-09-30, the "I want can_ko40's placement back" experiment.
import json
import re

import click
import odb
from reader import click_odb

SEQ_MASTER = re.compile(r"(dfrbp|dfbp|dfrbpq|sdfbbp|sdfrbp|dlhq|dlhr|dlhrq|dllr|dllrq|dlclkp|dllrtp)", re.I)
NOT_SEQ = re.compile(r"(clkbuf|buf|inv|fill|decap|tie|antenna)", re.I)
SYNTHETIC = re.compile(r"^(_\d+_|net\d+)$")


@click.command()
@click.option("--table", required=True, help="tools/seq_placement.py JSON of the run to copy")
@click.option("--status", default="FIRM", help="Placement status given to the pinned cells: FIRM (DEF FIXED, the placers leave them) or PLACED")
@click_odb
def main(reader, table, status):
    block = reader.block
    u = block.getDbUnitsPerMicron()
    rows = [r for r in json.load(open(table)) if r.get("named") and r.get("rtl")]
    want = {r["rtl"]: r for r in rows}

    # the design's registers by RTL name
    have = {}
    unnamed = 0
    for inst in block.getInsts():
        master = inst.getMaster()
        if master.isBlock():
            continue
        mname = master.getName()
        if NOT_SEQ.search(mname) or not (master.isSequential() or SEQ_MASTER.search(mname)):
            continue
        outs = {}
        for it in inst.getITerms():
            mt = it.getMTerm()
            if mt.getSigType() != "SIGNAL" or mt.getIoType() != "OUTPUT":
                continue
            net = it.getNet()
            outs[mt.getName()] = net.getName() if net is not None else None
        qname = outs.get("Q") or outs.get("Q_N") or next((v for v in outs.values() if v), None)
        rtl = qname.replace("\\", "") if qname else None
        if not rtl or SYNTHETIC.match(rtl):
            unnamed += 1
            continue
        have[rtl] = inst

    # rows: snap each spot to the nearest row's y and that row's site grid
    site_rows = []
    for row in block.getRows():
        bb = row.getBBox()
        site_rows.append((bb.yMin(), bb.xMin(), bb.xMax(), row.getSite().getWidth(), row.getOrient()))
    site_rows.sort()

    def snap(x, y):
        # the rows are segments once they are cut around the macros: the one
        # on the nearest y that holds x, else the nearest segment on that y
        dy = min(abs(r[0] - y) for r in site_rows)
        same_y = [r for r in site_rows if abs(r[0] - y) == dy]
        holding = [r for r in same_y if r[1] <= x < r[2]]
        best = holding[0] if holding else min(same_y, key=lambda r: min(abs(r[1] - x), abs(r[2] - x)))
        ymin, xmin, xmax, sw, _ = best
        x = xmin + round((x - xmin) / sw) * sw
        return max(xmin, min(x, xmax - sw)), ymin

    pinned, moved_far, missing_in_design, new_in_design = 0, 0, [], []
    for rtl, r in want.items():
        inst = have.get(rtl)
        if inst is None:
            missing_in_design.append(rtl)
            continue
        if inst.getMaster().getName() != r["master"]:
            # same register, another drive strength: the spot still fits a row
            pass
        x, y = snap(int(round(r["x"] * u)), int(round(r["y"] * u)))
        if abs(x - r["x"] * u) > u or abs(y - r["y"] * u) > u:
            moved_far += 1
        inst.setOrient(r["orient"])
        inst.setLocation(x, y)
        inst.setPlacementStatus(status)
        pinned += 1
    for rtl in have:
        if rtl not in want:
            new_in_design.append(rtl)

    print(f"{len(want)} named registers in the table, {len(have)} in the design ({unnamed} unnamed)")
    print(f"{pinned} pinned {status} at the table's spots ({moved_far} snapped by more than 1 um)")
    print(f"{len(missing_in_design)} table registers not in this design (left out): {', '.join(missing_in_design[:12])}{' ...' if len(missing_in_design) > 12 else ''}")
    print(f"{len(new_in_design)} design registers not in the table (free): {', '.join(new_in_design[:16])}{' ...' if len(new_in_design) > 16 else ''}")


if __name__ == "__main__":
    main()
