#!/usr/bin/env python3
"""Placement "seed" sweep: the placer is deterministic but chaotic, so a few
percent of target density is a different placement and Metal3 usage moves
by ten percent either way.  Run each candidate only up to global routing
(about 40 minutes), compare, and finish only the best one.

    python3 tools/seed_sweep.py run [--accept=82] [--finish] 53 54 56 57
                                                    # inside the nix shell (make seed-sweep):
                                                    # stop at the first seed whose Metal3 usage
                                                    # is <= --accept %, finish it if --finish
    python3 tools/seed_sweep.py report              # table of every runs/seed_*
    python3 tools/seed_sweep.py finish 54           # resume the winner from CheckAntennas,
                                                    # then rename runs/seed_54 -> runs/wokwi
The "seed" is PL_TARGET_DENSITY_PCT; runs live in runs/seed_<pct>.

    python3 tools/seed_sweep.py run --drt=4 --accept-bin=250 [--parallel=2] 55 53 57
Detailed-routing proxy: each seed also routes for --drt iterations (a DRC
report every 2), and its score is the hottest 30 um bin of the last report,
the thing global routing cannot see (a placement that funnels too much
through one strip beside a macro stalls there whatever its Metal3 usage).
A seed is accepted when that bin is <= --accept-bin; --finish resumes it
from OpenROAD.DetailedRouting with the full iteration count.  --parallel
runs that many seeds at once with DRT_THREADS shared out between them.
"""
import glob, os, re, subprocess, sys, shutil
from collections import Counter
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from drc_deck import override as _drc_override  # noqa: E402  (full KLayout deck when installed here)

LIBRELANE = ["python", "-m", "librelane", "--pdk-root", os.environ.get("PDK_ROOT", os.path.expanduser("~/projects/fossi")),
             "--pdk", "ihp-sg13cmos5l", "--manual-pdk"] + [a for o in _drc_override() for a in ("-c", o)]
CONFIG = "src/config_merged.json"
GRT_STEP = "OpenROAD.GlobalRouting"
NEXT_STEP = "OpenROAD.CheckAntennas"

DRT_STEP = "OpenROAD.DetailedRouting"

def run_seed(pct, drt_iters=0, threads=None):
    tag = f"seed_{pct}"
    if os.path.isdir(f"runs/{tag}"):
        shutil.rmtree(f"runs/{tag}")
    os.makedirs(f"runs/{tag}")                   # --force-run-dir wants it to exist
    cmd = LIBRELANE + ["--run-tag", tag, "--force-run-dir", f"runs/{tag}",
                       "--to", DRT_STEP if drt_iters else GRT_STEP,
                       "-c", f"PL_TARGET_DENSITY_PCT={pct}"]
    if drt_iters:
        cmd += ["-c", f"DRT_OPT_ITERS={drt_iters}", "-c", "DRT_SAVE_DRC_REPORT_ITERS=2", "-c", "DRT_ANTENNA_REPAIR_ITERS=0"]
    if threads:
        cmd += ["-c", f"DRT_THREADS={threads}"]
    cmd += [CONFIG]
    print(f"== seed {pct}: {' '.join(cmd)}", flush=True)
    with open(f"runs/{tag}.log", "w") as log:
        rc = subprocess.call(cmd, stdout=log, stderr=subprocess.STDOUT)
    print(f"== seed {pct}: exit {rc}", flush=True)

def grt_numbers(run):
    step = sorted(glob.glob(f"{run}/*-openroad-globalrouting"))
    if not step:
        return None
    logs = glob.glob(f"{step[-1]}/*.log")
    txt = open(logs[0], errors="replace").read() if logs else ""
    wl = re.findall(r"Total wirelength: (\d+)", txt)
    m3 = re.findall(r"^Metal3\s+\d+\s+\d+\s+([\d.]+)%\s+\d+\s*/\s*\d+\s*/\s*(\d+)", txt, re.M)
    m2 = re.findall(r"^Metal2\s+\d+\s+\d+\s+([\d.]+)%\s+\d+\s*/\s*\d+\s*/\s*(\d+)", txt, re.M)
    return {"wl": int(wl[-1]) if wl else None,
            "m3_pct": float(m3[-1][0]) if m3 else None, "m3_ovf": int(m3[-1][1]) if m3 else None,
            "m2_pct": float(m2[-1][0]) if m2 else None, "m2_ovf": int(m2[-1][1]) if m2 else None}

def hot_bin(run, size=30.0):
    """(count, x, y) of the densest size-um bin in the run's newest DRC report, or None"""
    steps = sorted(glob.glob(os.path.join(run, "*-openroad-detailedrouting*")))
    if not steps:
        return None
    rpts = [p for p in glob.glob(os.path.join(steps[-1], "**", "*"), recursive=True)
            if os.path.isfile(p) and os.path.getsize(p) > 0 and ".drc" in os.path.basename(p) and not p.endswith((".xml", ".lyrdb"))]
    if not rpts:
        return None
    text = open(max(rpts, key=os.path.getmtime), errors="replace").read()
    bins = Counter()
    for b in re.finditer(r"bbox = \(\s*([-\d.]+),\s*([-\d.]+)\s*\)\s*-\s*\(\s*([-\d.]+),\s*([-\d.]+)\s*\)", text):
        x = (float(b.group(1)) + float(b.group(3))) / 2; y = (float(b.group(2)) + float(b.group(4))) / 2
        bins[(int(x // size), int(y // size))] += 1
    if not bins:
        return (0, 0, 0)
    (bx, by), n = bins.most_common(1)[0]
    return (n, bx * size, by * size)

def report(runs):
    rows = []
    for run in runs:
        n = grt_numbers(run)
        if n and n["m3_ovf"] is not None:
            rows.append((os.path.basename(run), n))
    rows.sort(key=lambda r: r[1]["m3_ovf"])
    print(f"{'run':16s} {'GRT wl (um)':>12s} {'Metal3 %':>9s} {'M3 ovf':>7s} {'Metal2 %':>9s} {'M2 ovf':>7s}  {'DRT hot bin (30 um)':>22s}")
    for name, n in rows:
        hb = hot_bin(f"runs/{name}")
        hbs = f"{hb[0]:5d} at ({hb[1]:.0f}, {hb[2]:.0f})" if hb else "-"
        print(f"{name:16s} {n['wl']:12d} {n['m3_pct']:9.2f} {n['m3_ovf']:7d} {n['m2_pct']:9.2f} {n['m2_ovf']:7d}  {hbs:>22s}")
    if rows:
        best = rows[0][0]
        hint = f"  ->  make seed-finish SEED={best.split('_')[-1]}" if best.startswith("seed_") else ""
        print(f"best by Metal3 overflow: {best}{hint}")

def finish(pct):
    tag = f"seed_{pct}"
    routed = bool(glob.glob(f"runs/{tag}/*-openroad-detailedrouting*"))
    cmd = LIBRELANE + ["--run-tag", tag, "--force-run-dir", f"runs/{tag}", "--from", DRT_STEP if routed else NEXT_STEP,
                       "-c", f"PL_TARGET_DENSITY_PCT={pct}", CONFIG]
    print(f"== finishing {tag}: {' '.join(cmd)}", flush=True)
    with open(f"runs/{tag}.log", "a") as log:
        rc = subprocess.call(cmd, stdout=log, stderr=subprocess.STDOUT)
    print(f"== {tag}: exit {rc}", flush=True)
    if rc == 0:
        if os.path.isdir("runs/wokwi"):
            print("runs/wokwi exists; leaving the finished run at runs/" + tag)
        else:
            os.rename(f"runs/{tag}", "runs/wokwi"); print(f"runs/{tag} -> runs/wokwi")
    return rc

if __name__ == "__main__":
    what = sys.argv[1] if len(sys.argv) > 1 else "report"
    opts = [a for a in sys.argv[2:] if a.startswith("--")]
    args = [a for a in sys.argv[2:] if not a.startswith("--")]
    def optv(name, default, conv):
        return next((conv(o.split("=", 1)[1]) for o in opts if o.startswith(f"--{name}=")), default)
    accept = optv("accept", None, float)          # Metal3 usage % at global routing
    accept_bin = optv("accept-bin", None, int)    # hottest 30 um bin after --drt iterations
    drt_iters = optv("drt", 0, int)
    parallel = optv("parallel", 1, int)
    do_finish = "--finish" in opts
    if what == "run":
        accepted = None
        threads = max(4, (os.cpu_count() or 16) // parallel) if parallel > 1 else None

        def evaluate(pct):
            run_seed(pct, drt_iters, threads)
            n = grt_numbers(f"runs/seed_{pct}") or {}
            hb = hot_bin(f"runs/seed_{pct}") if drt_iters else None
            if n.get("m3_pct") is not None:
                print(f"== seed {pct}: Metal3 {n['m3_pct']:.2f}% usage, overflow {n['m3_ovf']}"
                      + (f"; hottest DRT bin {hb[0]} at ({hb[1]:.0f}, {hb[2]:.0f})" if hb else ""), flush=True)
            ok = n.get("m3_pct") is not None and (accept is None or n["m3_pct"] <= accept) \
                 and (accept_bin is None or (hb is not None and hb[0] <= accept_bin))
            return pct, ok

        batches = [args[i:i + parallel] for i in range(0, len(args), parallel)]
        for batch in batches:
            with ThreadPoolExecutor(max_workers=parallel) as ex:
                results = list(ex.map(evaluate, batch))
            for pct, ok in results:
                if ok and accepted is None:
                    accepted = pct
            if accepted is not None:
                print(f"== seed {accepted} accepted; remaining seeds skipped", flush=True)
                break
        seeds = sorted(r for r in glob.glob("runs/seed_*") if re.fullmatch(r"runs/seed_\d+", r))
        report(seeds + (["runs/wokwi"] if os.path.isdir("runs/wokwi") else []))
        if do_finish:
            if accepted is None:
                if drt_iters:
                    ranked = sorted((hot_bin(r)[0], r) for r in seeds if hot_bin(r))
                else:
                    ranked = sorted((grt_numbers(r)["m3_ovf"], r) for r in seeds if grt_numbers(r) and grt_numbers(r)["m3_ovf"] is not None)
                accepted = ranked[0][1].split("_")[-1] if ranked else None
                if accepted is not None:
                    print(f"== no seed met the bar; finishing the best, seed {accepted}", flush=True)
            if accepted is not None:
                sys.exit(finish(accepted))
    elif what == "report":
        report(sorted(r for r in glob.glob("runs/seed_*") if re.fullmatch(r"runs/seed_\d+", r)) + [r for r in ["runs/wokwi"] + sys.argv[2:] if os.path.isdir(r)])
    elif what == "finish":
        sys.exit(finish(sys.argv[2]))
    else:
        sys.exit(__doc__)
