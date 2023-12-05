#!/bin/bash

if [[ $HOST == *arm64* ]]; then
    # Get an updated config.sub and config.guess
    cp $BUILD_PREFIX/share/gnuconfig/config.* ./config/
fi

if [[ $HOST == *apple* ]]; then
    # Apply patch to build.py.in (autoreconf might not be needed?)
    patch -p1 < osx_patch.diff
    # These two flags are mentioned in the LHAPDF docs
    export CFLAGS=-Qunused-arguments
    export CPPFLAGS=-Qunused-arguments
fi

./configure --prefix=$PREFIX

make -j
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    make check
fi
make install
