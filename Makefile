# Local hardening of the PRISM/TinyQV tile on IHP CMOS5L.
#
# Tools come from the LibreLane nix shell (the DFFRAM.librelane checkout's
# shell.nix points at ../librelane); PDK_ROOT must hold ihp-sg13cmos5l, see
# DFFRAM.librelane/Readme.md. The Tiny Tapeout tools live in tt/ (git-ignored)
# and need their own Python environment (.venv-tt, git-ignored):
#     git clone -b cmos https://github.com/htfab/tt-support-tools tt
#     make venv
NIX_SHELL ?= ../DFFRAM.librelane/shell.nix
PYTHON    ?= python3.12
# tt_tool.py shells out to yowasp-yosys from the same venv, so put it on PATH
TT_PY     := PATH=$(CURDIR)/.venv-tt/bin:$$PATH .venv-tt/bin/python
ifeq ($(IN_NIX_SHELL),)
RUN = nix-shell $(NIX_SHELL) --run
else
RUN = sh -c
endif

.PHONY: tt-8x4 venv config harden harden-tt clean shell test

venv:
	$(PYTHON) -m venv .venv-tt
	.venv-tt/bin/python -m pip install --quiet --upgrade pip
	.venv-tt/bin/python -m pip install --quiet -r tt/requirements.txt

# The cmos branch of the TT tools has no 8x4 template: install ours (tt_8x4/)
tt-8x4:
	cp tt_8x4/tt_block_8x4_pgvdd.def tt/tech/ihp-sg13cmos5l/def/
	grep -q '^8x4:' tt/tech/ihp-sg13cmos5l/tile_sizes.yaml || cat tt_8x4/tile_sizes_8x4.yaml >> tt/tech/ihp-sg13cmos5l/tile_sizes.yaml

config: tt-8x4
	$(TT_PY) tt/tt_tool.py --create-user-config --ihp

harden: config
	rm -rf runs/wokwi
	$(RUN) "python3 flow.py wokwi"

# Exactly what the Tiny Tapeout GDS action runs: tt_tool.py --harden invokes
# `python -m librelane ... src/config_merged.json` from the repo root, where
# librelane_plugin_prism_pdn.py is discovered and meta.substituting_steps in
# src/config.json inserts the stripe step.  Output in runs/wokwi as well.
harden-tt: config
	$(RUN) "PATH=\$$PATH:$(CURDIR)/.venv-tt/bin .venv-tt/bin/python tt/tt_tool.py --harden --ihp --no-docker"

test:
	$(RUN) "make -C test"

shell:
	nix-shell $(NIX_SHELL)

clean:
	rm -rf runs
