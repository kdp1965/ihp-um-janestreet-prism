# Copyright 2026 Ken Pettit
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""
Placement keep-outs at the CFGMEM "mouths".

Every stalled route of this tile died in the same places: the strip of
standard-cell rows just outside a CFGMEM column's tile-facing edge, at the
height of the gap between the two macros of a pair.  Every net for the
macros' pins crosses that strip, and the placer fills it to the target
density as well, so its Metal2 tracks run out.  This step puts a placement
blockage on each such strip before global placement: a density cap
(DEF PARTIAL) by default so the placer thins the logic there, hard when
the cap is 0.

The geometry comes from the macro instances: the columns are found by x,
the tile-facing side is the one toward the core centre, and the strip spans
the gap between consecutive macros of a column plus a margin into each, and
can reach inward over the gap as well (--inward), where the displaced logic
otherwise piles up against the keep-out.
"""

import click
import odb

from reader import click_odb


@click.command()
@click.option("--macro-prefix", default="CFGMEM", help="Master name prefix of the macros that form the columns")
@click.option("--width", default=60.0, type=float, help="Keep-out width outward from the column edge (um)")
@click.option("--margin", default=20.0, type=float, help="Extension of the keep-out into each macro's height (um)")
@click.option("--max-density", default=0.25, type=float, help="Soft blockage density cap (0 = hard blockage)")
@click.option("--inward", default=0.0, type=float, help="Extension of the keep-out inward from the column edge, over the gap between the macros (um)")
@click_odb
def main(reader, macro_prefix, width, margin, max_density, inward):
    block = reader.block
    u = block.getDbUnitsPerMicron()
    core = block.getCoreArea()
    centre_x = (core.xMin() + core.xMax()) / 2

    macros = [
        inst for inst in block.getInsts()
        if inst.getMaster().isBlock() and inst.getMaster().getName().startswith(macro_prefix)
    ]
    if not macros:
        print(f"no macros with master prefix {macro_prefix}: nothing to do")
        return

    # group into columns by x extent
    columns = {}
    for inst in macros:
        b = inst.getBBox()
        columns.setdefault((b.xMin(), b.xMax()), []).append(inst)

    made = 0
    for (x0, x1), insts in sorted(columns.items()):
        facing_east = (x0 + x1) / 2 < centre_x
        inw = int(inward * u)
        kx0, kx1 = (x1 - inw, x1 + int(width * u)) if facing_east else (x0 - int(width * u), x0 + inw)
        kx0, kx1 = max(kx0, core.xMin()), min(kx1, core.xMax())
        insts = sorted(insts, key=lambda i: i.getBBox().yMin())
        for lower, upper in zip(insts, insts[1:]):
            lb, ub = lower.getBBox(), upper.getBBox()
            ky0 = max(core.yMin(), lb.yMax() - int(margin * u))
            ky1 = min(core.yMax(), ub.yMin() + int(margin * u))
            blk = odb.dbBlockage.create(block, kx0, ky0, kx1, ky1)
            if max_density > 0:
                # a PARTIAL blockage (density cap) only: DEF allows one of
                # SOFT / PARTIAL per placement blockage, and the RC extraction
                # step re-reads the DEF (a SOFT + PARTIAL pair is rejected
                # with DEFPARS-6543).
                blk.setMaxDensity(max_density)
            made += 1
            print(
                f"keep-out beside {lower.getName()} / {upper.getName()}: "
                f"x {kx0 / u:.2f}-{kx1 / u:.2f}  y {ky0 / u:.2f}-{ky1 / u:.2f}  "
                f"({'hard' if max_density <= 0 else f'partial, max density {max_density}'})"
            )
    print(f"{made} mouth keep-outs created")


if __name__ == "__main__":
    main()
