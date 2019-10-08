#!/bin/bash

INPUT=$1
OUTPUT=$2
FILENAME=$(basename -- "$INPUT")

#INPUTRES="--input-res=640x480"
INPUTRES="--input-res=$(echo $FILENAME|sed -n 's/[^_]*.*_\([0-9]*x[0-9]*\).*/\1/p')"
KVAZAAR_PARAMETERS=""
PERF_EVENT_NATIVECGROUP="kvazaar_native.slice"



#PERF_EVENT_NATIVECGROUP="kvazaar_container.slice"
#[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_NATIVECGROUP" ] && \
#        echo a && sudo cgcreate -g cpu,cpuacct,net_cls,net_prio,devices,cpuset,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:$PERF_EVENT_NATIVECGROUP



[[ "_$3" != "_" ]] && THREADS="$3" || THREADS="$(grep processor -c /proc/cpuinfo)"

KVAZAAR=/mnt/video-files/kvazaar_$(hostname -s)/kvazaar/src/kvazaar

echo RES: $INPUTRES
echo IN: $INPUT
echo OUT: $OUTPUT
echo THREADS: $THREADS
echo
echo

#cgexec -g subsystems:path_to_cgroup command arguments

#COMMAND="cgexec -g cpu,cpuacct,net_cls,net_prio,devices,blkio,pids,perf_event,memory,hugetlb,freezer:$PERF_EVENT_NATIVECGROUP $KVAZAAR --threads $THREADS $INPUTRES $KVAZAAR_PARAMETERS -i - -o - < $INPUT > $OUTPUT"
COMMAND="cgexec -g cpu,net_cls,blkio,pids,perf_event,hugetlb,freezer:$PERF_EVENT_NATIVECGROUP $KVAZAAR --preset ultrafast --threads $THREADS $INPUTRES $KVAZAAR_PARAMETERS -i - -o - < $INPUT > $OUTPUT"
echo $COMMAND
eval $COMMAND
