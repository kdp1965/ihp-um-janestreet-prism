# Compare the flop/latch placements of two runs (tools/seq_placement.py
# JSON files) by RTL name: how far each register moved, overall and per
# design block, and where the large moves are.
#
#   python3 tools/seq_compare.py <reference.json> <other.json> [--bins 30] [--top 12]

import argparse
import json
import math
import re
from collections import Counter, defaultdict


def block_of(name):
    m = re.match(r"(i_peripherals\.i_prism\.SH\[\d\]|i_peripherals\.i_prism\.i_prism|i_peripherals\.i_prism|"
                 r"i_peripherals\.i_cfgmem|i_peripherals\.[a-z_]+|i_tinyqv[^.]*|[a-z_]+)", name or "")
    return m.group(1) if m else (name or "?")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("ref"); ap.add_argument("other")
    ap.add_argument("--bins", type=float, default=30.0, help="bin size (um) for the displacement map")
    ap.add_argument("--top", type=int, default=12)
    a = ap.parse_args()
    ref = {r["rtl"]: r for r in json.load(open(a.ref)) if r.get("named", True)}
    oth = {r["rtl"]: r for r in json.load(open(a.other)) if r.get("named", True)}
    common = sorted(set(ref) & set(oth))
    only_ref, only_oth = len(set(ref) - set(oth)), len(set(oth) - set(ref))
    d = {n: math.hypot(ref[n]["x"] - oth[n]["x"], ref[n]["y"] - oth[n]["y"]) for n in common}
    ds = sorted(d.values())
    pct = lambda p: ds[min(len(ds) - 1, int(p * len(ds)))] if ds else float("nan")
    print(f"{len(common)} registers matched by RTL name ({only_ref} only in reference, {only_oth} only in other)")
    print(f"displacement um: median {pct(0.5):.1f}  mean {sum(ds)/len(ds):.1f}  p90 {pct(0.9):.1f}  max {ds[-1]:.1f}")
    for thr in (5, 20, 50, 100, 200):
        print(f"  moved more than {thr:3d} um: {sum(1 for v in ds if v > thr):5d} ({100*sum(1 for v in ds if v > thr)/len(ds):4.1f}%)")
    same_orient = sum(1 for n in common if ref[n]["orient"] == oth[n]["orient"])
    print(f"  same orientation: {same_orient} ({100*same_orient/len(common):.1f}%)")

    print("\nper block (median / p90 / max displacement, count):")
    byb = defaultdict(list)
    for n in common:
        byb[block_of(n)].append(d[n])
    for b, vals in sorted(byb.items(), key=lambda kv: -len(kv[1])):
        vals.sort()
        print(f"  {b:42s} {vals[len(vals)//2]:7.1f} {vals[int(0.9*(len(vals)-1))]:7.1f} {vals[-1]:7.1f}   n={len(vals)}")

    print(f"\nreference-position bins ({a.bins:.0f} um) with the largest mean displacement:")
    bins = defaultdict(list)
    for n in common:
        bins[(int(ref[n]["x"] // a.bins) * int(a.bins), int(ref[n]["y"] // a.bins) * int(a.bins))].append(d[n])
    rows = [(sum(v) / len(v), len(v), k) for k, v in bins.items() if len(v) >= 3]
    for mean, n, (x, y) in sorted(rows, reverse=True)[: a.top]:
        print(f"  x {x:4d}-{x+int(a.bins):4d} y {y:3d}-{y+int(a.bins):3d}: mean {mean:6.1f} um over {n} registers")

    print(f"\nlargest individual moves:")
    for n in sorted(common, key=lambda n: -d[n])[: a.top]:
        print(f"  {d[n]:7.1f} um  {n}  ({ref[n]['x']:.0f},{ref[n]['y']:.0f}) -> ({oth[n]['x']:.0f},{oth[n]['y']:.0f})")


if __name__ == "__main__":
    main()
