#!/bin/bash
set -e

cd ~/nvm-benchmarks/RECIPE
RESULTDIR=~/results
mkdir -p $RESULTDIR
PERFDIR=$RESULTDIR/recipe-performance
rm -rf $PERFDIR
bash runall
mv result $PERFDIR


