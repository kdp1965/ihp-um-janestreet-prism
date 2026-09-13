# 8x4 tile template for ihp-sg13cmos5l

The Tiny Tapeout support tools (`tt/`, branch `cmos`) stop at 8x2 / 6x4 for
CMOS5L, but the Jane Street protocol emulator competition allows 8x4
(1724.16 x 710.64 um).  `tt_block_8x4_pgvdd.def` is assembled from the
official templates: the 4x4 template supplies the height (rows, Y tracks and
the pin row at the top edge; pin X positions are identical for every width)
and the 8x2 template supplies the width (die width, row length, X tracks).

`make tt-8x4` (run automatically by `make config`) installs the DEF and the
`8x4` entry of `tile_sizes.yaml` into `tt/`.  Replace this with the official
template when Tiny Tapeout publishes one.
