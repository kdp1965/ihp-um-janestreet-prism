# Release the anchors: every FIRM standard cell (the registers and logic
# that Project.AnchorSequential pinned to a reference placement) goes back
# to PLACED, right after global placement.  FIRM only has to steer the
# global placer; left on, the resizers still swap a pinned cell's master in
# place (repair_design upsizes nor2_1 -> nor2_2 on the spot) and the
# detailed placer may not move the wider cell off its neighbour (DPL-0033,
# runs/vga3_anchor2 2026-09-30).  Released, the cells sit where they are
# and legalize like any other.  Macros (blocks) stay FIRM.
import click
from reader import click_odb


@click.command()
@click_odb
def main(reader):
    block = reader.block
    n = 0
    for inst in block.getInsts():
        if inst.getMaster().isBlock():
            continue
        if inst.getPlacementStatus() == "FIRM":
            inst.setPlacementStatus("PLACED")
            n += 1
    print(f"{n} anchored cells released to PLACED")


if __name__ == "__main__":
    main()
