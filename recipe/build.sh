#!/bin/bash

set -x

if [[ $HOST == *apple* ]]; then
    # Bug for macOS as of lhapdf v6.1.1+
    # https://gitlab.com/hepcedar/lhapdf/-/blob/c5b048f5794e483d85801d1ae39f42aaa46999dd/INSTALL#L162-164
    export CFLAGS=-Qunused-arguments
    export CPPFLAGS=-Qunused-arguments

    # As using autotools
    # https://conda-forge.org/blog/2020/10/29/macos-arm64/#how-to-add-a-osx-arm64-build-to-a-feedstock
    if [[ $HOST == *arm64-apple* ]]; then
        # Get an updated config.sub and config.guess
        cp $BUILD_PREFIX/share/gnuconfig/config.* .
    fi
fi

autoreconf --install --force
(cd wrappers/python && cython --include-dir . --cplus lhapdf.pyx)

./configure --help

./configure --prefix=$PREFIX CXXFLAGS="${CXXFLAGS}"

make --jobs="${CPU_COUNT}"

make install

# Need to run 'make check' after 'make install' as tests the Python library
# with compiled extensions
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
    if [[ "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
        # During cross-compilation, the Python interpreter is the build-platform
        # (x86_64) binary and can't import the target-architecture C extension.
        # Skip the Python TESTS in the tests Makefile.
        # c.f. https://gitlab.com/hepcedar/lhapdf/-/blob/92239ac82134be698805c1002b4615e5167c6fa3/tests/Makefile.am#L25
        sed -i 's/ testunc\.py//' tests/Makefile.am
    fi
    make check
fi
