#!/bin/bash
#set -e


######################################### Running Jaaru to find bugs
cd ~/nvm-benchmarks/RECIPE
RESULTDIR=~/results
mkdir -p $RESULTDIR
BUGDIR=$RESULTDIR/recipe-bugs
rm -rf $BUGDIR
mkdir $BUGDIR

############################### Bugs in  CCEH
cd CCEH
sed -i "3iBUGFLAG=''" Makefile
sed -i '4s/$/ $(BUGFLAG)/' Makefile
# First bug in src/CCEH_LSB.cpp line 162
sed -i "162 c\#ifndef MYBUG" src/CCEH_LSB.cpp
make BUGFLAG=-DMYBUG=1
sed -i '3iexport PMCheck="-f11"' run.sh
timeout 30 ./run.sh ./example 2 1 >> $BUGDIR/CCEH-bug-1.log
if [ $? -eq 124 ]; then
    echo "ERROR: The test case terminated by hitting the timeout." >> $BUGDIR/CCEH-bug-1.log
fi
sed -i "162 c\#ifdef BUGFIX" src/CCEH_LSB.cpp
# Second bug in src/CCEH_LSB.cpp line 165
sed -i "165 c\#ifndef MYBUG" src/CCEH_LSB.cpp
make BUGFLAG=-DMYBUG=1
timeout 30 ./run.sh ./example 2 1 >> $BUGDIR/CCEH-bug-2.log
sed -i "165 c\#ifdef BUGFIX" src/CCEH_LSB.cpp
# Third bug in src/CCEH_LSB.cpp line 168
sed -i "170 c\#ifndef MYBUG" src/CCEH_LSB.cpp
make BUGFLAG=-DMYBUG=1
timeout 30 ./run.sh ./example 2 1 >> $BUGDIR/CCEH-bug-3.log
sed -i "170 c\#ifdef BUGFIX" src/CCEH_LSB.cpp
sed -i '3d' run.sh
git checkout -- Makefile
sed -i 's/CXX := \/.*/CXX := ~\/pmcheck-vmem\/Test\/g++/g' Makefile
cd ..

############################### Bugs in  FAST_FAIR
cd FAST_FAIR
sed -i "3iBUGFLAG=''" Makefile
sed -i '8s/$/ $(BUGFLAG)/' Makefile
sed -i '3iexport PMCheck="-f11"' run.sh
# 1st bug
sed -i "169 c\#ifndef MYBUG" btree.h
make BUGFLAG=-DMYBUG=1
timeout 10 ./run.sh ./example 10 2 >> $BUGDIR/FAST_FAIR-bug-1.log
sed -i "169 c\#ifdef BUGFIX" btree.h
# 2nd bug
sed -i "188 c\#ifndef MYBUG" btree.h
make BUGFLAG=-DMYBUG=1
timeout 10 ./run.sh ./example 2 2 >> $BUGDIR/FAST_FAIR-bug-2.log
sed -i "188 c\#ifdef BUGFIX" btree.h
# Third bug
sed -i "1851 c\#ifndef MYBUG" btree.h
make BUGFLAG=-DMYBUG=1
timeout 10 ./run.sh ./example 2 2 >> $BUGDIR/FAST_FAIR-bug-3.log
sed -i "1851 c\#ifdef BUGFIX" btree.h
sed -i '3d' run.sh
git checkout -- Makefile
sed -i 's/CXX=.*/CXX=~\/pmcheck-vmem\/Test\/g++/g' Makefile
cd ..

############################### Bugs in  P-ART
cd P-ART
rm -rf build
mkdir build
sed -i '4iset(CMAKE_CXX_FLAGS "-DMYBUG=1")' CMakeLists.txt
cd build
cmake CMAKE_CXX_FLAGS=-DMYBUG=1 -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..
# 1st Bug
sed -i "77 c\#ifndef MYBUG" ../Epoche.h
sed -i '3iexport PMCheck="-f11"' run.sh
make -j
timeout 10 ./run.sh ./example 9 5 &> $BUGDIR/P-ART-1.log
sed -i "77 c\#ifdef BUGFIX" ../Epoche.h
sed -i '3d' run.sh
# 2nd Bug
sed -i "25 c\#ifndef MYBUG" ../Tree.cpp
make -j
timeout 10 ./run.sh ./example 2 2 &> $BUGDIR/P-ART-2.log
sed -i "25 c\#ifdef BUGFIX" ../Tree.cpp
# 3rd Bug
sed -i "46 c\#ifndef MYBUG" ../example.cpp
sed -i '3iexport PMCheck="-f11"' run.sh
make -j
timeout 30 ./run.sh ./example 2 2 &> $BUGDIR/P-ART-3.log
if [ $? -eq 124 ]; then
    echo "ERROR: The test case terminated by hitting the timeout." >> $BUGDIR/P-ART-3.log
fi
sed -i "46 c\#ifdef BUGFIX" ../example.cpp
sed -i '3d' run.sh
sed -i '4d' ../CMakeLists.txt
cd ../../

############################### Bugs in P-BwTree
cd P-BwTree
rm -rf build
mkdir build
sed -i '4iset(CMAKE_CXX_FLAGS "-DMYBUG=1")' CMakeLists.txt
sed -i '3iexport PMCheck="-f11"' run.sh
cd build
cmake CMAKE_CXX_FLAGS=-DMYBUG=1 -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..
# 1st Bug
sed -i "177 c\#ifdef BUGFIX" ../example.cpp
make -j
timeout 10 ./run.sh ./example 2 2 &> $BUGDIR/P-BwTree-Bug-1.log
sed -i "177 c\#ifndef BUGFIX" ../example.cpp
# 2nd Bug
sed -i "457 c\#ifndef MYBUG" ../src/bwtree.h
make -j
timeout 30 ./run.sh ./example 8 2 &> $BUGDIR/P-BwTree-Bug-2.log
sed -i "457 c\#ifdef BUGFIX" ../src/bwtree.h
# 3rd bugs
sed -i "471 c\#ifndef MYBUG" ../src/bwtree.h
make -j
timeout 10 ./run.sh ./example 10 2 &> $BUGDIR/P-BwTree-Bug-3.log
sed -i "471 c\#ifdef BUGFIX" ../src/bwtree.h
# 4th bugs
sed -i "2000 c\#ifndef MYBUG" ../src/bwtree.h
make -j
timeout 10 ./run.sh ./example 2 2 &> $BUGDIR/P-BwTree-Bug-4.log
sed -i "2000 c\#ifdef BUGFIX" ../src/bwtree.h
# 5th bugs
sed -i "2792 c\#ifndef MYBUG" ../src/bwtree.h
make -j
timeout 10 ./run.sh ./example 2 2 &> $BUGDIR/P-BwTree-Bug-5.log
sed -i "2792 c\#ifdef BUGFIX" ../src/bwtree.h
git checkout -- ../src/bwtree.h
sed -i '3d' ../run.sh
sed -i '4d' ../CMakeLists.txt
cd ../../


############################### Bugs in P-CLHT
cd P-CLHT
rm -rf build
mkdir build
sed -i '4iset(CMAKE_CXX_FLAGS "-DMYBUG=1")' CMakeLists.txt
sed -i '3iexport PMCheck=""' run.sh
cd build
cmake -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..
# 1st Bug: It didn't crash
sed -i "172 c\#ifdef DISABLEFIX" ../src/clht_lf_res.c
make -j
timeout 30 ./run.sh ./example 2 2 &> $BUGDIR/P-CLHT-Bug-1.log
sed -i "172 c\#ifdef BUGFIX" ../src/clht_lf_res.c
# 2nd bug
sed -i "224 c\#ifdef DISABLEFIX" ../src/clht_lf_res.c
make -j
timeout 30 ./run.sh ./example 2 2 &> $BUGDIR/P-CLHT-Bug-2.log
sed -i "224 c\#ifdef BUGFIX" ../src/clht_lf_res.c
# 3rd bug
sed -i "227 c\#ifdef DISABLEFIX" ../src/clht_lf_res.c
make -j
sed -i '3 c\export PMCheck="-f11"' run.sh
timeout 30 ./run.sh ./example 2 2 &> $BUGDIR/P-CLHT-Bug-3.log
if [ $? -eq 124 ]; then
    echo "ERROR: The test case terminated by hitting the timeout." >> $BUGDIR/P-CLHT-Bug-3.log
fi
sed -i "227 c\#ifdef BUGFIX" ../src/clht_lf_res.c
sed -i '3d' ../run.sh
sed -i '4d' ../CMakeLists.txt
cd ../../


############################### Bugs in P-MassTree
cd P-Masstree
rm -rf build
mkdir build
sed -i '4iset(CMAKE_CXX_FLAGS "-DMYBUG=1")' CMakeLists.txt
sed -i '3iexport PMCheck="-f11"' run.sh
cd build
cmake CMAKE_CXX_FLAGS=-DMYBUG=1 -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..
# 1st Bug:
sed -i "1341 c\#ifndef MYBUG" ../masstree.h
make -j
timeout 10 ./run.sh ./example 20 10 &> $BUGDIR/P-Masstree-1.log
sed -i "1341 c\#ifdef BUGFIX" ../masstree.h
sed -i '3d' ../run.sh
sed -i '4d' ../CMakeLists.txt
cd ../../

