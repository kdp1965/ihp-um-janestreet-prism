#!/usr/bin/env python3
"""
Harden the project locally with LibreLane's Classic flow plus the step that
runs the tile's Metal4 power stripes across the CFGMEM macros (the single-layer
Tiny Tapeout PDN cannot reach macro pins otherwise; pdngen carves its stripes
around macros). Reads src/config_merged.json, which tt_tool.py creates from
src/config.json and the tile template (see Makefile / run_flow.sh).

`make harden-tt` runs the same thing the Tiny Tapeout action runs
(tt_tool.py --harden); the step is inserted there by the plugin module and
meta.substituting_steps instead of this file.

    python3 flow.py [run-tag]      inside the LibreLane nix shell, PDK_ROOT set
"""
import os
import sys

from librelane.flows.classic import Classic
from librelane.steps import OpenROAD

# The step lives in the LibreLane plugin module so the stock Tiny Tapeout
# harden (python -m librelane from the repo root) picks it up too; see
# librelane_plugin_prism_pdn.py and meta.substituting_steps in src/config.json.
from librelane_plugin_prism_pdn import ExtendPowerStripes

HERE = os.path.dirname(os.path.abspath(__file__))


class ProjectFlow(Classic):
    Steps = list(Classic.Steps)
    Steps.insert(Steps.index(OpenROAD.GeneratePDN) + 1, ExtendPowerStripes)


def main():
    # Load by path so LibreLane applies its JSON conventions (0/1 booleans etc.)
    # exactly as the Tiny Tapeout CI does with the same file.
    # Same layout as the Tiny Tapeout action: design dir is src/ (dir:: paths in
    # the merged config are relative to it), the working directory is the repo
    # root (plain relative paths such as macros/...), run dir runs/<tag>.
    os.chdir(HERE)
    tag = sys.argv[1] if len(sys.argv) > 1 else "wokwi"
    # The full CMOS5L KLayout deck for local sign-off, when it is installed
    # here (tools/drc_deck.py); the config's own deck otherwise.
    sys.path.insert(0, os.path.join(HERE, "tools"))
    try:
        from drc_deck import override
    except ImportError:
        def override():
            return []

    flow = ProjectFlow(
        os.path.join(HERE, "src", "config_merged.json"),
        design_dir=os.path.join(HERE, "src"),
        pdk_root=os.environ["PDK_ROOT"],
        pdk="ihp-sg13cmos5l",
        scl="sg13cmos5l_stdcell",
        config_override_strings=override(),
    )
    flow.start(tag=tag, _force_run_dir=os.path.join(HERE, "runs", tag))


if __name__ == "__main__":
    main()
