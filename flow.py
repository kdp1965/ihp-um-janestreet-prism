#!/usr/bin/env python3
"""
Harden the project locally with LibreLane's Classic flow plus the step that
runs the tile's Metal4 power stripes across the CFGMEM macros (the single-layer
Tiny Tapeout PDN cannot reach macro pins otherwise; pdngen carves its stripes
around macros). Reads src/config_merged.json, which tt_tool.py creates from
src/config.json and the tile template (see Makefile / run_flow.sh).

    python3 flow.py [run-tag]      inside the LibreLane nix shell, PDK_ROOT set
"""
import os
import sys

from librelane.flows.classic import Classic
from librelane.steps import OpenROAD
from librelane.steps.odb import OdbpyStep

HERE = os.path.dirname(os.path.abspath(__file__))


class ExtendPowerStripes(OdbpyStep):
    id = "Project.ExtendPowerStripes"
    name = "Extend Power Stripes Over Macros"

    def get_script_path(self):
        return os.path.join(HERE, "odb_stripes.py")


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
    flow = ProjectFlow(
        os.path.join(HERE, "src", "config_merged.json"),
        design_dir=os.path.join(HERE, "src"),
        pdk_root=os.environ["PDK_ROOT"],
        pdk="ihp-sg13cmos5l",
        scl="sg13cmos5l_stdcell",
    )
    flow.start(tag=tag, _force_run_dir=os.path.join(HERE, "runs", tag))


if __name__ == "__main__":
    main()
