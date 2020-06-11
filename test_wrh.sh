#!/bin/bash
make
make clean
#generate groundtruth
./qalsh -alg 0 -n 1000000 -qn 100 -d 128 -p 2 -ds /data/sdb/local/pqdata/bigann/sift100m.txt -qs /data/sdb/local/pqdata/bigann/query.txt -ts /data/sdb/local/pqdata/bigann/qalsh/sift1m/gtL2.txt
# generate index
./qalsh -alg 3 -n 1000000 -d 128 -B 4096 -p 2 -z 0.0 -c 1.5 -ds /data/sdb/local/pqdata/bigann/sift100m.txt -df /data/sdb/local/pqdata/bigann/qalsh/sift1m/ -of /data/sdb/local/pqdata/bigann/qalsh/sift1m/
# test
./qalsh -alg 4 -n 1000000 -qn 100 -d 128 -qs /data/sdb/local/pqdata/bigann/query.txt -ts /data/sdb/local/pqdata/bigann/qalsh/sift1m/gtL2.txt  -df /data/sdb/local/pqdata/bigann/qalsh/sift1m/ -of /data/sdb/local/pqdata/bigann/qalsh/sift1m/
# ------------------------------------------------------------------------------
#  Parameters
# ------------------------------------------------------------------------------
dname=Sift
n=1000000
qn=100
d=128
B=4096
leaf=20000
L=30
M=7
c=2.0
dPath=./data/${dname}/${dname}
dFolder=./data/${dname}/

# ------------------------------------------------------------------------------
#  Running Scripts
# ------------------------------------------------------------------------------
p_list=(2.0) 
z_list=(0.0)
length=`expr ${#p_list[*]} - 1`

for j in $(seq 0 ${length})
do 
    p=${p_list[j]}
    z=${z_list[j]}
    oFolder=./results${c}/${dname}/L${p}/

    # --------------------------------------------------------------------------
    #  Ground Truth
    # --------------------------------------------------------------------------
    ./qalsh -alg 0 -n ${n} -qn ${qn} -d ${d} -p ${p} -ds ${dPath}.ds \
        -qs ${dPath}.q -ts ${dPath}.gt${p}

    # --------------------------------------------------------------------------
    #  QALSH+
    # --------------------------------------------------------------------------
    ./qalsh -alg 1 -n ${n} -d ${d} -B ${B} -leaf ${leaf} -L ${L} -M ${M} \
        -p ${p} -z ${z} -c ${c} -ds ${dPath}.ds -df ${dFolder} -of ${oFolder}

    ./qalsh -alg 2 -qn ${qn} -d ${d} -qs ${dPath}.q -ts ${dPath}.gt${p} \
        -df ${dFolder} -of ${oFolder}

    # --------------------------------------------------------------------------
    #  QALSH
    # --------------------------------------------------------------------------
    ./qalsh -alg 3 -n ${n} -d ${d} -B ${B} -p ${p} -z ${z} -c ${c} \
        -ds ${dPath}.ds -df ${dFolder} -of ${oFolder}

    ./qalsh -alg 4 -qn ${qn} -d ${d} -qs ${dPath}.q -ts ${dPath}.gt${p} \
        -df ${dFolder} -of ${oFolder}

    # --------------------------------------------------------------------------
    #  Linear Scan
    # --------------------------------------------------------------------------
    ./qalsh -alg 5 -n ${n} -qn ${qn} -d ${d} -B ${B} -p ${p} -qs ${dPath}.q \
        -ts ${dPath}.gt${p} -df ${dFolder} -of ${oFolder}
done
