![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout – IHP SG13CMOS5L – 8x4 tiles

Project infrastructure for a Tiny Tapeout design on the **IHP SG13CMOS5L** shuttle,
based on the official `cmos5l` branch of
[TinyTapeout/ttihp-verilog-template](https://github.com/TinyTapeout/ttihp-verilog-template/tree/cmos5l).

| Item | Value |
| --- | --- |
| PDK | `ihp-sg13cmos5l` (IHP-Open-PDK `2bbec755`, 2026-09-08) |
| Tiles | **8x4** → die **1724.16 × 710.64 µm** |
| Top module | `tt_um_project` (rename before submitting, must be unique) |
| Clock | 50 MHz (`CLOCK_PERIOD` 20 ns in `src/config.json`) |
| CI actions | `TinyTapeout/tt-gds-action@ihp-cmos5l` |
| Support tools | `tt-support-tools` branch `ihp-sg13cmos5l` |
| LibreLane | 3.1.0.dev3 |
| Sim | cocotb 2.0.1 + Icarus Verilog |

## Layout

```
info.yaml                 project metadata — tiles: "8x4"
src/project.v             top module (placeholder: uo_out = ui_in + uio_in)
src/config.json           LibreLane config (density, clock, PDN)
test/                     cocotb testbench (tb.v, test.py, Makefile)
docs/info.md              datasheet text
scripts/env.sh            pinned versions + paths (sourced by all scripts)
scripts/setup.sh          local install: venv, tt-support-tools, PDK, LibreLane
scripts/harden.sh         local GDS build, same steps as CI
scripts/check-env.sh      tool check + info.yaml validation
.devcontainer/            VS Code / Codespaces container with everything pre-installed
.github/workflows/        gds, test, docs, fpga
Makefile                  shortcuts
```

## Quick start

```bash
make setup        # or: make setup-sim  (simulation only)
make check        # validates info.yaml and the 8x4 floorplan config
make test         # RTL sim
make harden       # GDS via LibreLane Docker image (make harden-nix for Nix)
make test-gl      # gate-level sim on the hardened netlist
```

Paths default to `~/ttsetup/{venv,pdk}`; override with `TT_VENV` / `PDK_ROOT`.
Or open the repo in the Dev Container (VS Code → *Reopen in Container*) where it's all pre-installed.

## Before your first push

1. Rename `tt_um_project` → `tt_um_<github-user>_<name>` in `info.yaml`, `src/project.v`, `test/tb.v`.
2. Fill `title`, `author`, `description`, and the `pinout` in `info.yaml`.
3. Add each new source file to `source_files` in `info.yaml` **and** `PROJECT_SOURCES` in `test/Makefile`.
4. In GitHub: *Settings → Pages → Source: GitHub Actions* (needed by the `viewer` job).

## 8x4 notes

- The 8x4 floorplan DEF is `tt/tech/ihp-sg13cmos5l/def/tt_block_8x4_pgvdd.def`, selected automatically by `tt_tool.py`.
- `PL_TARGET_DENSITY_PCT` starts at 60. With this much area you can usually lower it to spread logic and ease routing; raise it (up to ~80) only if global placement fails with `GPL-0302`.
- Pin budget is unchanged: 8 in / 8 out / 8 bidir + `clk`, `rst_n`, `ena`.

## Resources

- [Tiny Tapeout FAQ](https://tinytapeout.com/faq/)
- [Testing your design](test/README.md)
- [LibreLane configuration reference](https://librelane.readthedocs.io/en/latest/reference/configuration.html)
- 
