ARG VARIANT=ubuntu-24.04
FROM mcr.microsoft.com/vscode/devcontainers/base:${VARIANT}

# Tiny Tapeout IHP SG13CMOS5L dev container.
# Versions below mirror TinyTapeout/tt-gds-action@ihp-cmos5l so local runs match CI.
ENV DEBIAN_FRONTEND=noninteractive
ENV PDK_ROOT=/ttsetup/pdk
ENV PDK=ihp-sg13cmos5l
ARG TT_SUPPORT_TOOLS_BRANCH=ihp-sg13cmos5l
ARG LIBRELANE_VERSION=3.1.0.dev3
# IHP-Open-PDK dev branch, 2026-09-08 (same revision as tt-gds-action install_sg13cmos5l.sh)
ARG IHP_PDK_REV=2bbec755dc67ca3db0261c3d6163e15735d66710

RUN apt update && apt install -y iverilog gtkwave python3 python3-pip python3-venv python3-tk \
    python-is-python3 libcairo2 verilator libpng-dev libqhull-dev librsvg2-bin pngquant git

# tt-support-tools (CMOS5L branch)
RUN mkdir -p /ttsetup && \
    git clone -b ${TT_SUPPORT_TOOLS_BRANCH} https://github.com/TinyTapeout/tt-support-tools /ttsetup/tt-support-tools

# IHP SG13CMOS5L PDK, pinned
RUN mkdir -p ${PDK_ROOT} && cd ${PDK_ROOT} && git init -q && \
    git fetch -q --depth 1 https://github.com/IHP-GmbH/IHP-Open-PDK.git ${IHP_PDK_REV} && \
    git checkout -q FETCH_HEAD && \
    echo "IHP-Open-PDK ${IHP_PDK_REV}" > ${PDK_ROOT}/ihp-sg13cmos5l/SOURCES

COPY test/requirements.txt /ttsetup/test_requirements.txt
COPY .devcontainer/copy_tt_support_tools.sh /ttsetup

RUN python -m venv /ttsetup/venv && \
    /ttsetup/venv/bin/pip install -r /ttsetup/test_requirements.txt -r /ttsetup/tt-support-tools/requirements.txt && \
    /ttsetup/venv/bin/pip install librelane==${LIBRELANE_VERSION}

# verible (formatting)
RUN umask 022 && \
    curl -L https://github.com/chipsalliance/verible/releases/download/v0.0-4023-gc1271a00/verible-v0.0-4023-gc1271a00-linux-static-x86_64.tar.gz | \
    tar zxf - -C /usr/local --strip-components=1 && \
    chmod 755 /usr/local/bin

RUN chown -R vscode:vscode /ttsetup
