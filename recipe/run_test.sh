#!/bin/bash

#
echo -e "\n# Check installed directory structure"
echo "# test -d ${PREFIX}/bin"
test -d "${PREFIX}/bin"
echo "# test -d ${PREFIX}/include"
test -d "${PREFIX}/include"
echo "# test -d ${PREFIX}/include/LHAPDF"
test -d "${PREFIX}/include/LHAPDF"
echo "# test -d ${PREFIX}/lib"
test -d "${PREFIX}/lib"
echo "# test -d ${PREFIX}/share"
test -d "${PREFIX}/share"
echo "# test -d ${PREFIX}/share/LHAPDF"
test -d "${PREFIX}/share/LHAPDF"

echo -e "\n# Check installed files"
echo "# test -f ${PREFIX}/bin/lhapdf"
test -f "${PREFIX}/bin/lhapdf"
echo "# test -f ${PREFIX}/bin/lhapdf-config"
test -f "${PREFIX}/bin/lhapdf-config"
echo "# test -f ${PREFIX}/include/LHAPDF/LHAPDF.h"
test -f "${PREFIX}/include/LHAPDF/LHAPDF.h"
if [[ "${target_platform}" == linux-* ]]; then
    echo "# test -f ${PREFIX}/lib/libLHAPDF.so"
    test -f "${PREFIX}/lib/libLHAPDF.so"
else
    # macOS
    echo "# test -f ${PREFIX}/lib/libLHAPDF.dylib"
    test -f "${PREFIX}/lib/libLHAPDF.dylib"
fi
echo "# test -f ${PREFIX}/share/LHAPDF/lhapdf.conf"
test -f "${PREFIX}/share/LHAPDF/lhapdf.conf"

#
echo -e "\n# Check lhapdf-config CLI API and flags return expected values"
echo -e "# lhapdf-config --help\n"
lhapdf-config --help

echo -e "# lhapdf-config --version\n"
lhapdf-config --version

echo -e "\n# lhapdf-config --cxxflags: $(lhapdf-config --cxxflags)"

echo -e "\n# lhapdf-config --ldflags: $(lhapdf-config --ldflags)"

echo -e "\n# Check lhapdf CLI API"
echo -e "# lhapdf --help\n"
lhapdf --help

#
cd examples/
echo -e "\n# Test example analyticpdf"
"$CXX" analyticpdf.cc \
    -o analyticpdf \
    $(lhapdf-config --cxxflags --ldflags) \
    -Wl,-rpath,"$(lhapdf-config --libdir)"
./analyticpdf

# needed for: compatibility, reweight, pythonexample.py
echo -e "\n# lhapdf install CT10nlo\n"
# avoid lots of output to stdout from download of the file
lhapdf install CT10nlo &> /dev/null

echo -e "\n# Test example compatibility"
"$CXX" compatibility.cc \
    -o compatibility \
    $(lhapdf-config --cxxflags --ldflags) \
    -Wl,-rpath,"$(lhapdf-config --libdir)"
./compatibility

# needed for hessian2replicas
echo -e "\n# lhapdf install MSTW2008nnlo68cl\n"
lhapdf install MSTW2008nnlo68cl &> /dev/null

echo -e "\n# Test example hessian2replicas"
"$CXX" hessian2replicas.cc \
    -o hessian2replicas \
    $(lhapdf-config --cxxflags --ldflags) \
    -Wl,-rpath,"$(lhapdf-config --libdir)"
./hessian2replicas MSTW2008nnlo68cl 1234 10

# needed for reweight
echo -e "\n# lhapdf install MSTW2008lo68cl\n"
lhapdf install MSTW2008lo68cl &> /dev/null

echo -e "\n# Test example reweight"
"$CXX" reweight.cc \
    -o reweight \
    $(lhapdf-config --cxxflags --ldflags) \
    -Wl,-rpath,"$(lhapdf-config --libdir)"
./reweight CT10nlo/0 MSTW2008lo68cl/0

echo -e "\n# Test example pythonexample.py"
python pythonexample.py
