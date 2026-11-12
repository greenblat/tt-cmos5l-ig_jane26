# Convenience targets for the Tiny Tapeout IHP SG13CMOS5L 8x4 project.
SHELL := /bin/bash
ENV   := source scripts/env.sh &&

.PHONY: setup setup-sim check test test-gl harden harden-nix clean

setup:          ## venv + tt-support-tools + PDK + LibreLane
	./scripts/setup.sh

setup-sim:      ## cocotb only
	./scripts/setup.sh --sim-only

check:          ## show installed tools, validate info.yaml for 8x4
	./scripts/check-env.sh

test:           ## RTL simulation (cocotb + iverilog)
	$(ENV) cd test && $(MAKE) clean && $(MAKE) && python -m cocotb_tools.check_results results.xml

test-gl:        ## gate-level simulation (run `make harden` first)
	$(ENV) cd test && $(MAKE) clean && $(MAKE) GATES=yes && python -m cocotb_tools.check_results results.xml

harden:         ## GDS with LibreLane in Docker (same as CI)
	./scripts/harden.sh

harden-nix:     ## GDS with EDA tools on PATH (LibreLane Nix shell)
	./scripts/harden.sh --no-docker

clean:
	rm -rf runs src/user_config.json src/config_merged.json
	cd test && $(MAKE) clean 2>/dev/null; rm -f test/results.xml test/gate_level_netlist.v
