#!/bin/bash
# Generic script to move an application into a cgroup, in order to count events in a more precise way. Doesn't work, in fact, as after leaving the cgroup, the counters leave also.
PID=$$
MYAPP=./myapp.sh
PERF_CGROUP=myappcgroup.slice
DUMMY_CGROUP=mydummycgroup.slice

$MYAPP | grep -e START -e STOP | while read line ; do 
	if [[ $line =~ .*START.* ]]; then
		
		# "perfing" started
		
		sudo cgclassify -g cpu,cpuacct,net_cls,net_prio,devices,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:$PERF_CGROUP $PID
		
		:
	else
		
		# "perfing" stop
		# disabled, as it seems that 'perf' only counts  at the end of the execution, not taking in consideration
		# a temporary "trip" inside the cgroup
		
		#sudo cgclassify -g cpu,cpuacct,net_cls,net_prio,devices,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:$DUMMY_CGROUP $PID
		
		:
	fi
done


