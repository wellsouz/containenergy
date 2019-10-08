#!/bin/bash
N_PROC=`grep -c processor /proc/cpuinfo`
N_FILES=`ls -1 "$@" | wc -l`
DATE=`date '+%Y%m%d_%H%M%S'`
RUNS=20
HOSTNAME=`hostname -s`

THREADS="$(grep processor -c /proc/cpuinfo)"
CPUSET="0-$((`grep processor -c /proc/cpuinfo` - 1))"

LOG=perfstat"_"$DATE"_"$HOSTNAME"_"$THREADS"_"$RUNS

PERF_EVENT_CGROUP="dockerkvazaaresl.slice"
[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_CGROUP" ] && \
	echo a && sudo cgcreate -g cpu,cpuacct,net_cls,net_prio,devices,cpuset,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:$PERF_EVENT_CGROUP

#PERF_EVENT_DUMMYCGROUP="dummycgroup4test.slice"
#[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_DUMMYCGROUP" ] && \
#	echo a && sudo cgcreate -g cpu,cpuacct,net_cls,net_prio,devices,cpuset,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:$PERF_EVENT_DUMMYCGROUP

echo N_PROC: $N_PROC 
echo N_FILE: $N_FILES 
echo 

#for i in "$@";
#do
#	rm -f  $i.hevc;
#done

for i in "$@"; 
do
	echo $i
	echo
	FILENAME=$(basename -- "$i")
	CONTAINER_NAME="kvazaar_$FILENAME"
	
	rm -f $LOG"_"$FILENAME".native.stat"
	rm -f $LOG"_"$FILENAME".container.stat"

	COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses ./kvazaar_native_2.sh    $i $i.hevc $THREADS                         2>/dev/null 2>> $LOG"_"$FILENAME".native.stat"    >> $LOG"_"$FILENAME".native.stat""
	echo $COMMAND
	eval $COMMAND
	echo

	#COMMAND="perf stat -r $RUNS -B -a ./kvazaar_native.sh    $i $i.hevc $THREADS         2>/dev/null 2>> $LOG"_"$FILENAME".native.system-wide.stat"    >> $LOG"_"$FILENAME".native.system-wide.stat""
	#echo $COMMAND
	#eval $COMMAND
	#echo

	COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses --cgroup=$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP -a ./kvazaar_container_2.sh $i $i.hevc $THREADS $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $LOG"_"$FILENAME".container.stat" >> $LOG"_"$FILENAME".container.stat""
	echo $COMMAND
	eval $COMMAND
	echo

	#COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses --cgroup=,,,,,,,, -a ./kvazaar_container.sh $i $i.hevc $THREADS $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $LOG"_"$FILENAME".container.system-wide.stat" >> $LOG"_"$FILENAME".container.system-wide.stat""
	#echo $COMMAND
	#eval $COMMAND
	#echo

	#COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses --cgroup=$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP -a ./kvazaar_container.sh $i $i.hevc $THREADS $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $LOG"_"$FILENAME".container.dummy.stat" >> $LOG"_"$FILENAME".container.dummy.stat""
	#echo $COMMAND
	#eval $COMMAND
	#echo


	echo -e "\n######################################################################################################################\n"

	[ -f $LOG"_"$FILENAME".native.stat" ] && tail -n 21 $LOG"_"$FILENAME".native.stat" && \
		echo -e "\n######################################################################################################################\n"

	[ -f $LOG"_"$FILENAME".native.system-wide.stat" ] && tail -n 21 $LOG"_"$FILENAME".native.system-wide.stat" && \
		echo -e "\n######################################################################################################################\n"

	[ -f $LOG"_"$FILENAME".container.stat" ] && tail -n 21 $LOG"_"$FILENAME".container.stat" && \
		echo -e "\n######################################################################################################################\n"


	[ -f $LOG"_"$FILENAME".container.system-wide.stat" ] && tail -n 21 $LOG"_"$FILENAME".container.system-wide.stat" && \
		echo -e "\n######################################################################################################################\n"

	[ -f $LOG"_"$FILENAME".container.system-wide.stat" ] && tail -n 21 $LOG"_"$FILENAME".container.dummy.stat" && \
		echo -e "\n######################################################################################################################\n"
done

