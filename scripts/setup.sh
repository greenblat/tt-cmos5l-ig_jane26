#!/usr/bin/env bash
# One-time local setup for the Tiny Tapeout IHP SG13CMOS5L flow (Linux / macOS).
#
#   ./scripts/setup.sh            # sim + harden (venv, tt-support-tools, PDK, LibreLane)
#   ./scripts/setup.sh --sim-only # cocotb/iverilog only, no PDK or LibreLane
#
# Hardening runs LibreLane in Docker by default (needs Docker running).
# With LibreLane's Nix shell instead, use `make harden-nix`.
set -euo pipefail
source "$(dirname "$0")/env.sh"

SIM_ONLY=0
[ "${1:-}" = "--sim-only" ] && SIM_ONLY=1

echo "==> Python venv at $TT_VENV"
mkdir -p "$(dirname "$TT_VENV")"
# CI uses Python 3.11; tt-support-tools pins numpy 1.26.4, which has no 3.13 wheels.
PY="${PYTHON:-}"
if [ -z "$PY" ]; then
  for c in python3.11 python3.12 python3; do command -v "$c" >/dev/null && { PY="$c"; break; }; done
fi
case "$("$PY" -c 'import sys;print(f"{sys.version_info[0]}.{sys.version_info[1]}")')" in
  3.11|3.12) ;;
  *) echo "WARN: $PY is not 3.11/3.12 - tt-support-tools deps may build from source (slow). Set PYTHON=python3.11." ;;
esac
[ -d "$TT_VENV" ] || "$PY" -m venv "$TT_VENV"
# shellcheck disable=SC1091
source "$TT_VENV/bin/activate"
pip install -q --upgrade pip
pip install -q -r "$TT_ROOT/test/requirements.txt"

command -v iverilog >/dev/null || echo "WARN: iverilog not found (apt install iverilog / brew install icarus-verilog)"

if [ "$SIM_ONLY" = 1 ]; then
  echo "==> Sim-only setup done. Run: make test"
  exit 0
fi

echo "==> tt-support-tools ($TT_SUPPORT_TOOLS_BRANCH) -> $TT_ROOT/tt"
if [ -d "$TT_ROOT/tt/.git" ]; then
  git -C "$TT_ROOT/tt" fetch -q origin "$TT_SUPPORT_TOOLS_BRANCH"
  git -C "$TT_ROOT/tt" checkout -q "$TT_SUPPORT_TOOLS_BRANCH"
  git -C "$TT_ROOT/tt" pull -q --ff-only
elif [ ! -e "$TT_ROOT/tt" ]; then
  git clone -q -b "$TT_SUPPORT_TOOLS_BRANCH" "$TT_SUPPORT_TOOLS_REPO" "$TT_ROOT/tt"
fi
pip install -q -r "$TT_ROOT/tt/requirements.txt"

echo "==> IHP SG13CMOS5L PDK @ ${IHP_PDK_REV:0:12} -> $PDK_ROOT"
if [ -f "$PDK_ROOT/ihp-sg13cmos5l/SOURCES" ] && grep -q "$IHP_PDK_REV" "$PDK_ROOT/ihp-sg13cmos5l/SOURCES"; then
  echo "    already installed"
else
  mkdir -p "$PDK_ROOT"
  git -C "$PDK_ROOT" init -q
  git -C "$PDK_ROOT" fetch -q --depth 1 "$IHP_PDK_REPO" "$IHP_PDK_REV"
  git -C "$PDK_ROOT" checkout -q -f FETCH_HEAD
  echo "IHP-Open-PDK $IHP_PDK_REV" > "$PDK_ROOT/ihp-sg13cmos5l/SOURCES"
fi

echo "==> LibreLane $LIBRELANE_VERSION"
pip install -q "librelane==$LIBRELANE_VERSION"

echo
echo "Setup complete. Next:"
echo "  make check     # validate info.yaml + 8x4 config"
echo "  make test      # RTL simulation"
echo "  make harden    # GDS via LibreLane Docker image (make harden-nix for Nix)"
