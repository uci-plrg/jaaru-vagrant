#!/bin/bash
set -e
# change this flag to false to get LLVM source code instead of using binary files
USELLVMBIN=false


# 1. Getting all the source code

git clone https://github.com/uci-plrg/jaaru.git
mv jaaru pmcheck
cd pmcheck/
git checkout vagrant
cd ..

git clone https://github.com/uci-plrg/nvm-benchmarks.git
cd nvm-benchmarks
git checkout vagrant
cd ..

git clone https://github.com/uci-plrg/jaaru-pmdk.git
mv jaaru-pmdk pmdk
cd pmdk
git checkout vagrant
cd ..

if ! $USELLVMBIN
then
	# 2. Compiling the LLVM Pass
	git clone https://github.com/llvm/llvm-project.git
	cd llvm-project
	git checkout 7899fe9da8d8df6f19ddcbbb877ea124d711c54b
	cd ..

	git clone https://github.com/uci-plrg/jaaru-llvm-pass.git
	mv jaaru-llvm-pass PMCPass
	cd PMCPass
	git checkout vagrant
	cd ..

	mv PMCPass llvm-project/llvm/lib/Transforms/
	echo "add_subdirectory(PMCPass)" >> llvm-project/llvm/lib/Transforms/CMakeLists.txt
	cd llvm-project
	mkdir build
	cd build
	cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm
	make -j 4
	cd ~/
	touch llvm-project/build/lib/libPMCPass.so
else
	# 2. Using the LLVM binary files
	cp /vagrant/data/llvm-project.tar.gz .
	tar -xzvf llvm-project.tar.gz
	rm llvm-project.tar.gz
fi


# 3. Compiling Jaaru (PMCheck) with default libpmem API
cd pmcheck/
sed -i 's/LLVMDIR=.*/LLVMDIR=~\/llvm-project\//g' Test/gcc
sed -i 's/JAARUDIR=.*/JAARUDIR=~\/pmcheck\/bin\//g' Test/gcc

sed -i 's/LLVMDIR=.*/LLVMDIR=~\/llvm-project\//g' Test/g++
sed -i 's/JAARUDIR=.*/JAARUDIR=~\/pmcheck\/bin\//g' Test/g++
make
make test
cd ~/

# 4. Building PMDK
cd pmdk
sed -i 's/CXX=\/.*/CXX=~\/pmcheck\/Test\/g++/g' src/common.inc
sed -i 's/CC=\/.*/CC=~\/pmcheck\/Test\/gcc/g' src/common.inc
sed -i 's/export LD_LIBRARY_PATH=.*/export LD_LIBRARY_PATH=~\/pmcheck\/bin\//g' src/examples/libpmemobj/map/run.sh
sed -i 's/export DYLD_LIBRARY_PATH=.*/export DYLD_LIBRARY_PATH=~\/pmcheck\/bin\//g' src/examples/libpmemobj/map/run.sh
make
cd ~/

# 5. Compiling Jaaru (PMCheck) with libvmmalloc configuration
cp -r pmcheck pmcheck-vmem
cd pmcheck-vmem
sed -i 's/JAARUDIR=.*/JAARUDIR=~\/pmcheck-vmem\/bin\//g' Test/gcc
sed -i 's/JAARUDIR=.*/JAARUDIR=~\/pmcheck-vmem\/bin\//g' Test/g++
sed -i 's/.*\#define ENABLE_VMEM.*/\#define ENABLE_VMEM/g' config.h
make clean
make
make test
cd ~/

# 6. Compiling RECIPE benchmarks
cd nvm-benchmarks
sed -i 's/export LD_LIBRARY_PATH=.*/export LD_LIBRARY_PATH=~\/pmcheck-vmem\/bin\//g' run
cd RECIPE

#Initializing CCEH
cd CCEH
sed -i 's/CXX := \/.*/CXX := ~\/pmcheck-vmem\/Test\/g++/g' Makefile
cd ..

#Initializing FAST_FAIR
cd FAST_FAIR
sed -i 's/CXX=.*/CXX=~\/pmcheck-vmem\/Test\/g++/g' Makefile
cd ..

#initializing P-ART, P-BwTree, P-CLHT, P-Masstree, and P-HOT
RECIPE_BENCH="P-ART P-BwTree P-CLHT P-Masstree"
for bench in $RECIPE_BENCH; do
        cd $bench
        sed -i 's/set(CMAKE_C_COMPILER .*)/set(CMAKE_C_COMPILER "\/home\/vagrant\/pmcheck-vmem\/Test\/gcc")/g' CMakeLists.txt
        sed -i 's/set(CMAKE_CXX_COMPILER .*)/set(CMAKE_CXX_COMPILER "\/home\/vagrant\/pmcheck-vmem\/Test\/g++")/g' CMakeLists.txt
        sed -i 's/export LD_LIBRARY_PATH=.*/export LD_LIBRARY_PATH=~\/pmcheck-vmem\/bin\//g' run.sh
        sed -i 's/export DYLD_LIBRARY_PATH=.*/export DYLD_LIBRARY_PATH=~\/pmcheck-vmem\/bin\//g' run.sh
        cd ..
done

# 7. Copying the generator scritps
cd ~/
cp /vagrant/data/recipe-bugs.sh ~/
cp /vagrant/data/recipe-perf.sh ~/
cp /vagrant/data/pmdk-bugs.sh ~/
