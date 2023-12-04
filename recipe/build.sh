#!/bin/bash
#
if [[ $HOST == *arm64* ]]; then
    # Get an updated config.sub and config.guess
    cp $BUILD_PREFIX/share/gnuconfig/config.* ./config/
fi

./configure --prefix=$PREFIX
make -j

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
    make check
fi

make install
