#!/bin/bash
set -e

cd ~/nvm-benchmarks/RECIPE


cd CCEH
make
cd ..

cd FAST_FAIR
make
cd ..

RECIPE_BENCH="P-ART P-BwTree P-CLHT P-Masstree"
for bench in $RECIPE_BENCH; do
        cd $bench
        rm -rf build
        mkdir build
        cd build
        cmake -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS\
=-fheinous-gnu-extensions ..
        make -j
        touch run.sh
        cd ../../
done


RESULTDIR=~/results
mkdir -p $RESULTDIR
PERFDIR=$RESULTDIR/recipe-performance
rm -rf $PERFDIR
bash runall
mv result $PERFDIR


