#!/bin/bash
# Script to profile a generic application inside a cgroup

RUNS=100
PERF_CGROUP=myappcgroup.slice
DUMMY_CGROUP=mydummycgroup.slice

[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_CGROUP" ] && \
	echo Creating PERF_CGROUP && sudo cgcreate -g cpu,cpuacct,net_cls,net_prio,devices,cpuset,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:$PERF_CGROUP

[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$DUMMY_CGROUP" ] && \
	echo Creating DUMMY_CGROUP && sudo cgcreate -g cpu,cpuacct,net_cls,net_prio,devices,cpuset,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:$DUMMY_CGROUP

COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses --cgroup=$PERF_CGROUP,$PERF_CGROUP,$PERF_CGROUP,$PERF_CGROUP,$PERF_CGROUP,$PERF_CGROUP,$PERF_CGROUP,$PERF_CGROUP,$PERF_CGROUP -a ./scripttorunapp.sh"

echo $COMMAND
eval $COMMAND


