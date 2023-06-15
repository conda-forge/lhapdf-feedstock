#!/bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./config
#This has to be here because autotools doesn't find the right cython
(cd wrappers/python && cython --cplus lhapdf.pyx)
./configure --prefix=$PREFIX
make -j
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
make check
fi
make install

cd wrappers
make
make install
