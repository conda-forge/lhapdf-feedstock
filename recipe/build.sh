#!/bin/bash
./configure --prefix=$PREFIX
make -j
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
make check
fi
make install

cd wrappers
make
make install
