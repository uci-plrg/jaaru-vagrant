#!/bin/bash
#set -e

######################################### Running Jaaru to find bugs
cd ~/pmdk
RESULTDIR=~/results
mkdir -p $RESULTDIR
PMDKRESDIR=$RESULTDIR/pmdk-bugs
rm -rf $PMDKRESDIR
mkdir $PMDKRESDIR
############################## Bugs in PMDK
cd src/examples/libpmemobj/map
####### Btree - btree_map.c:89
sed -i '5cexport PMCheck="-d$3 -r1787250"' run.sh
timeout --preserve-status 240 ./run.sh ./data_store btree ./tmp.log 1 &> $PMDKRESDIR/btree-1.log
rm tmp.log PMCheckOutput*
####### Btree - Failed to open pool error
sed -i '5cexport PMCheck="-d$3"' run.sh
timeout --preserve-status 20 ./run.sh ./data_store btree tmp.log 2 &> $PMDKRESDIR/btree-2.log
rm PMCheckOutput* tmp.log
###### Hashmap_atomic - 1 ////heap.c:533
sed -i '5cexport PMCheck="-d$3 -e"' run.sh
./run.sh ./data_store hashmap_atomic tmp.log 2 &> $PMDKRESDIR/hashmap_atomic-1.log
rm PMCheckOutput* tmp.log
##### ctree ///obj.c:1523 pmemobj_type_num] assertion failure
sed -i '5cexport PMCheck="-d$3 -r1800000"' run.sh
./run.sh ./data_store ctree ./tmp.log 1 &> $PMDKRESDIR/ctree.log
rm tmp.log PMCheckOutput*
#### Hashmap_atomic ////pmalloc.c:270 palloc_operation] assertion failure
sed -i '5cexport PMCheck="-d$3 -e"' run.sh
sed -i '183d' data_store.c
sed -i '199ijaaru_enable_simulating_crash();' data_store.c
make
./run.sh ./data_store hashmap_atomic ./tmp.log 1 &> $PMDKRESDIR/hashmap_atomic-2.log
rm tmp.log PMCheckOutput*
#### hashmap_tx //// Illegal memory access obj.c:1528
sed -i '5cexport PMCheck="-d$3 -e"' run.sh
timeout --preserve-status 240 ./run.sh ./data_store hashmap_tx ./tmp.log 1 &> $PMDKRESDIR/hashmap_tx.log
rm tmp.log PMCheckOutput*
git checkout data_store.c
make
#### rbtree /// Illegal memory access at rbtree_map.c:137 or transaction assertion failure
sed -i '5cexport PMCheck="-d$3 -r1790000"' run.sh
timeout --preserve-status 240 ./run.sh ./data_store rbtree ./tmp.log 1 &> $PMDKRESDIR/rbtree.log
rm tmp.log PMCheckOutput*

