#!/bin/sh
# Local hardening; run inside the LibreLane nix shell (see Makefile).
set -e
export PATH="$PWD/.venv-tt/bin:$PATH"
python3 -m pip --version >/dev/null 2>&1 || true
.venv-tt/bin/python tt/tt_tool.py --create-user-config --ihp
python3 flow.py wokwi
.venv-tt/bin/python tt/tt_tool.py --create-png --ihp
