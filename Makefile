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
# Local sign-off uses the full CMOS5L KLayout deck from the IHP dev branch
# (tools/drc_deck.py adds -c KLAYOUT_DRC_RUNSET=... when it is installed);
# src/config.json itself points at the PDK's own deck so the CI can resolve it.
DRC_DECK = $$(python3 tools/drc_deck.py)
else
RUN = sh -c
endif

.PHONY: tt-8x4 venv config harden harden-tt gui klayout clean shell test

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
# Viewers.  Every step directory holds a self-contained .odb, so any of them
# can be opened in the OpenROAD GUI:
#   make gui FILE=runs/wokwi/22-project-extendpowerstripes/tt_um_pettit_js_prism.odb
#   make gui                            # final database of runs/wokwi
#   make klayout [FILE=some.gds]        # final GDS of runs/wokwi by default
RUN_DIR ?= runs/wokwi
FILE    ?=
gui:
	$(RUN) "openroad -gui -no_init -db $(or $(FILE),$(firstword $(wildcard $(RUN_DIR)/final/odb/*.odb)))"

klayout:
	$(RUN) "klayout $(or $(FILE),$(firstword $(wildcard $(RUN_DIR)/final/gds/*.gds)))"

harden-tt: config
	$(RUN) "PATH=\$$PATH:$(CURDIR)/.venv-tt/bin .venv-tt/bin/python tt/tt_tool.py --harden --ihp --no-docker"

test:
	$(RUN) "make -C test"

shell:
	nix-shell $(NIX_SHELL)

clean:
	rm -rf runs

# Where is the detailed router and what is it stuck on (the newest DRC
# report; config.json writes one every 4 iterations), and stop a run that
# is clearly not going to converge: the flow then fails at that step and
# the report on disk is the one to read.
drt-status:
	python3 tools/drt_status.py runs/wokwi

harden-stop:
	python3 tools/drt_status.py runs/wokwi --stop

# Placement seed sweep: PL_TARGET_DENSITY_PCT is the seed (the placer is
# deterministic but chaotic).  Each candidate runs only to global routing
# (~40 min); seed-report ranks them by Metal3 overflow; seed-finish resumes
# the winner from the step after global routing and renames it to runs/wokwi.
SEEDS      ?= 53 54 56 57
SEED       ?=
ACCEPT     ?= 85
DRT_ITERS  ?= 4
ACCEPT_BIN ?= 300
PARALLEL   ?= 3
seed-sweep: config
	$(RUN) "PATH=\$$PATH:$(CURDIR)/.venv-tt/bin python3 tools/seed_sweep.py run --accept=$(ACCEPT) --drt=$(DRT_ITERS) --accept-bin=$(ACCEPT_BIN) --parallel=$(PARALLEL) --finish $(SEEDS)"

seed-report:
	python3 tools/seed_sweep.py report

seed-finish: config
	$(RUN) "PATH=\$$PATH:$(CURDIR)/.venv-tt/bin python3 tools/seed_sweep.py finish $(SEED)"

# Tiny Tapeout precheck on a finished run's GDS (what the GDS action runs
# in CI): layers, pins against the 8x4 template, boundary, KLayout checks.
# The tool reads info.yaml from the GDS's directory and its pin check
# resolves the template relative to tt/precheck, hence the copy and the cd.
precheck:
	cp info.yaml $(RUN_DIR)/final/gds/info.yaml
	$(RUN) "cd tt/precheck && PDK_ROOT=$$PDK_ROOT PDK=ihp-sg13cmos5l ../../.venv-tt/bin/python precheck.py --gds ../../$(RUN_DIR)/final/gds/tt_um_pettit_js_prism.gds --tech ihp-sg13cmos5l"
