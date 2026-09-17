#!/usr/bin/env python3
"""Where is the detailed router, and what is it stuck on?

    python3 tools/drt_status.py [runs/wokwi] [--bin 30] [--top 10] [--stop]

Reads the run's latest detailed-routing step: the violation count per
iteration from its log, and the newest DRC report it has written (the final
one, or a per-iteration one when the config sets DRT_SAVE_DRC_REPORT_ITERS =
N, i.e. detailed_route -drc_report_iter_step N).  Prints the counts by layer
and type, the densest bins of the tile (where the cluster is), and the nets
that appear most.  --stop then kills the openroad process of that step, so a
run that is clearly not going to converge ends now instead of at iteration
64; the report on disk is the one to read, and the flow exits with an error.
"""
import glob, os, re, signal, subprocess, sys
from collections import Counter, defaultdict

args = [a for a in sys.argv[1:] if not a.startswith("--")]
opts = [a for a in sys.argv[1:] if a.startswith("--")]
run = args[0] if args else "runs/wokwi"
def opt(name, default):
    for o in opts:
        if o.startswith(f"--{name}="):
            return type(default)(o.split("=", 1)[1])
    return default
BIN = opt("bin", 30.0)
TOP = opt("top", 10)

steps = sorted(glob.glob(os.path.join(run, "*-openroad-detailedrouting*")),
               key=lambda p: int(os.path.basename(p).split("-")[0]))
if not steps and glob.glob(os.path.join(run, "drt-run-*")):
    steps = [run]                       # a standalone replay directory (see docs 4v)
if not steps:
    sys.exit(f"no detailed-routing step under {run}")
step = steps[-1]
print(f"== {step}")

# ---- iteration history from the step log
log = os.path.join(step, "openroad-detailedrouting.log")
if not os.path.exists(log):
    logs = glob.glob(os.path.join(step, "*.log")) + glob.glob(os.path.join(step, "..", os.path.basename(step) + ".log"))
    log = logs[0] if logs else log
if os.path.exists(log):
    txt = open(log, errors="replace").read()
    counts = [int(m) for m in re.findall(r"Number of violations = (\d+)", txt)]
    print(f"   iterations so far: {len(counts)}; violations: {' '.join(map(str, counts))}")
    tail = txt[txt.rfind("Number of violations"):] if counts else ""
    tbl = re.search(r"Viol/Layer.*?(?=\n\[INFO|\n\n|\Z)", tail, re.S)
    if tbl:
        print("   " + tbl.group(0).strip().replace("\n", "\n   "))

# ---- newest DRC report
reports = [p for p in glob.glob(os.path.join(step, "**", "*"), recursive=True)
           if os.path.isfile(p) and (".drc" in os.path.basename(p) or p.endswith(".rpt"))
           and not p.endswith((".xml", ".lyrdb"))]
if not reports:
    print("   no DRC report written yet (set DRT_SAVE_DRC_REPORT_ITERS in config.json for per-iteration reports)")
elif all(os.path.getsize(p) == 0 for p in reports):
    print(f"   newest report {os.path.relpath(max(reports, key=os.path.getmtime), run)} is empty: no violations")
    reports = []
if reports:
    reports = [p for p in reports if os.path.getsize(p) > 0]
if reports:
    rpt = max(reports, key=os.path.getmtime)
    import time
    print(f"   report: {os.path.relpath(rpt, run)}  ({time.strftime('%H:%M:%S', time.localtime(os.path.getmtime(rpt)))})")
    text = open(rpt, errors="replace").read()
    viols = []
    for block in re.split(r"(?=violation type:)", text):
        t = re.search(r"violation type:\s*(.+)", block)
        b = re.search(r"bbox = \(\s*([-\d.]+),\s*([-\d.]+)\s*\)\s*-\s*\(\s*([-\d.]+),\s*([-\d.]+)\s*\)\s*on Layer\s*(\S+)", block)
        s = re.search(r"srcs:\s*(.*)", block)
        if t and b:
            x = (float(b.group(1)) + float(b.group(3))) / 2
            y = (float(b.group(2)) + float(b.group(4))) / 2
            nets = [n[4:] if n.startswith("net:") else n for n in (s.group(1).split() if s else [])]
            viols.append((t.group(1).strip(), b.group(5), x, y, nets))
    if not viols:
        print("   report format not recognised; first lines:")
        print("   " + "\n   ".join(text.splitlines()[:6]))
    else:
        print(f"   {len(viols)} violations in the report")
        bylt = Counter((v[1], v[0]) for v in viols)
        for (lay, typ), n in sorted(bylt.items(), key=lambda kv: -kv[1]):
            print(f"      {lay:10s} {typ:22s} {n:5d}")
        bins = defaultdict(Counter)
        for typ, lay, x, y, _ in viols:
            bins[(int(x // BIN), int(y // BIN))][lay] += 1
        print(f"   densest {BIN:.0f} um bins (x, y ranges in um):")
        for (bx, by), c in sorted(bins.items(), key=lambda kv: -sum(kv[1].values()))[:TOP]:
            lays = ", ".join(f"{l} {n}" for l, n in c.most_common())
            print(f"      x {bx*BIN:6.0f}-{(bx+1)*BIN:6.0f}  y {by*BIN:6.0f}-{(by+1)*BIN:6.0f}: {sum(c.values()):4d}   ({lays})")
        nets = Counter(n for v in viols for n in v[4])
        if nets:
            print("   nets appearing most:")
            for n, k in nets.most_common(8):
                print(f"      {k:4d}  {n}")

# ---- stop the router
if "--stop" in opts:
    ps = subprocess.run(["ps", "-eo", "pid,command"], capture_output=True, text=True).stdout
    run_key = os.path.abspath(run).rstrip("/") + "/"          # only this run's router
    victims = [int(l.split()[0]) for l in ps.splitlines()[1:]
               if len(l.split()) > 1 and os.path.basename(l.split()[1]) == "openroad"
               and "detailedrouting" in l and run_key in l and "-gui" not in l]
    if not victims:
        print("   --stop: no detailed-routing openroad process found")
    for pid in victims:
        os.kill(pid, signal.SIGTERM)
        print(f"   --stop: sent SIGTERM to openroad pid {pid}; the flow will now fail at this step, "
              f"and the report above is the one to read")
