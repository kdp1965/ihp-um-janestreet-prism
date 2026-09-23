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
Drop the placement keep-outs once the route is finished.

The mouth keep-outs (odb_keepouts.py) thin the rows beside a CFGMEM column
so the nets crossing into the macro's pins find free Metal2 there.  They do
their work during placement and routing; afterwards they only stop the
filler, and the strips ship as bare rows.  On the 8x4 tile that is six
strips, about 57000 um2, with no decoupling capacitance and nothing but the
power rails on Metal1.

Fill and decap cells carry no signal pins, so they cannot take back the
tracks the keep-outs protected, and this step runs after detailed routing:
placement and routing are both settled by the time the blockages go away.
"""

import click
import odb

from reader import click_odb


@click.command()
@click_odb
def main(reader):
    block = reader.block
    u = block.getDbUnitsPerMicron()
    blockages = list(block.getBlockages())
    area = 0.0
    for b in blockages:
        bb = b.getBBox()
        area += (bb.xMax() - bb.xMin()) * (bb.yMax() - bb.yMin()) / (u * u)
        odb.dbBlockage_destroy(b)
    print(f"[INFO] {len(blockages)} placement keep-outs removed, "
          f"{area:.0f} um2 of rows returned to the filler")


if __name__ == "__main__":
    main()
