# Cut the standard-cell rows under a box, before the PDN is generated: the
# box then gets no cells, no filler or decap, and no Metal1 rails (the rails
# follow the rows), so a Metal4 picture placed over it (Project.ChipArt)
# sits on bare oxide instead of on logic.  Routing stays out through the
# matching ROUTING_OBSTRUCTIONS entries on Metal2-Metal4.  Rows that cross
# the box are split into a left and a right part on the site grid; rows
# inside it are removed.  Runs after OpenROAD.CutRows.  2026-10-01.
import click
import odb
from reader import click_odb


@click.command()
@click.option("--box", nargs=4, type=float, required=True, help="x0 y0 x1 y1 in um")
@click_odb
def main(reader, box):
    block = reader.block
    u = block.getDbUnitsPerMicron()
    x0, y0, x1, y1 = (int(round(v * u)) for v in box)
    cut = split = removed = 0
    for row in list(block.getRows()):
        bb = row.getBBox()
        if bb.xMax() <= x0 or bb.xMin() >= x1 or bb.yMax() <= y0 or bb.yMin() >= y1:
            continue
        site = row.getSite()
        sw = site.getWidth()
        ox, oy = row.getOrigin()                      # a [x, y] list in the Python binding
        n = row.getSiteCount()
        name, orient, direction, spacing = row.getName(), row.getOrient(), row.getDirection(), row.getSpacing()
        # sites left of the box: those ending at or before x0; right of it: starting at or after x1
        n_left = max(0, min(n, (x0 - ox) // sw))
        first_right = (x1 - ox + sw - 1) // sw
        n_right = max(0, n - first_right)
        odb.dbRow_destroy(row)
        cut += 1
        if n_left > 0:
            odb.dbRow_create(block, f"{name}_a", site, ox, oy, orient, direction, int(n_left), spacing)
            split += 1
        if n_right > 0:
            odb.dbRow_create(block, f"{name}_b", site, ox + int(first_right) * sw, oy, orient, direction, int(n_right), spacing)
            split += 1
        if n_left == 0 and n_right == 0:
            removed += 1
    print(f"art keep-out {box}: {cut} rows cut into {split} segments, {removed} rows removed; {len(list(block.getRows()))} rows now")


if __name__ == "__main__":
    main()
