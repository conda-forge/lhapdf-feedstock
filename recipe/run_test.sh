#!/usr/bin/env bash

set -ex

lhapdf-config --version

echo -e "\n# Check lhapdf-config CLI API and flags return expected values"
lhapdf-config --help

echo -e "\n# lhapdf-config --cxxflags: $(lhapdf-config --cxxflags)"

echo -e "\n# lhapdf-config --ldflags: $(lhapdf-config --ldflags)"

echo -e "\n# Check lhapdf CLI API"
lhapdf --help

#
cd examples/
"$CXX" analyticpdf.cc \
    -o analyticpdf \
    $(lhapdf-config --cxxflags --libs) \
    -Wl,-rpath,"$(lhapdf-config --libdir)"
./analyticpdf

# needed for: compatibility, reweight, pythonexample.py
# avoid lots of output to stdout from download of the file
lhapdf update
lhapdf install CT10nlo &> /dev/null

"$CXX" compatibility.cc \
    -o compatibility \
    $(lhapdf-config --cxxflags --libs) \
    -Wl,-rpath,"$(lhapdf-config --libdir)"
./compatibility

# needed for hessian2replicas
lhapdf install MSTW2008nnlo68cl &> /dev/null

"$CXX" hessian2replicas.cc \
    -o hessian2replicas \
    $(lhapdf-config --cxxflags --libs) \
    -Wl,-rpath,"$(lhapdf-config --libdir)"
./hessian2replicas MSTW2008nnlo68cl 1234 10

# needed for reweight
lhapdf install MSTW2008lo68cl &> /dev/null

"$CXX" reweight.cc \
    -o reweight \
    $(lhapdf-config --cxxflags --libs) \
    -Wl,-rpath,"$(lhapdf-config --libdir)"
./reweight CT10nlo/0 MSTW2008lo68cl/0

python pythonexample.py
