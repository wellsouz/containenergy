#!/bin/bash
N_PROC=`grep -c processor /proc/cpuinfo`
N_FILES=`ls -1 "$@" | wc -l`
DATE=`date '+%Y%m%d_%H%M%S'`
RUNS=20
HOSTNAME=`hostname -s`
ID=$(whoami):root

THREADS="$(grep processor -c /proc/cpuinfo)"
CPUSET="0-$((`grep processor -c /proc/cpuinfo` - 1))"

DIR=$DATE"_"$HOSTNAME"_"$THREADS"_"$RUNS
LOG=perfstat"_"$DATE"_"$HOSTNAME"_"$THREADS"_"$RUNS

#sudo cgdelete -g cpu,net_cls,devices,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:kvazaar_container.slice
#sudo cgdelete -g cpu,net_cls,devices,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:kvazaar_native.slice

sudo cgdelete -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:kvazaar_container.slice
sudo cgdelete -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:kvazaar_native.slice

PERF_EVENT_CONTAINERCGROUP="kvazaar_container.slice"
[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_CONTAINERCGROUP" ] && \
	echo Creating cgroup $PERF_EVENT_CONTAINERCGROUP && sudo cgcreate -a $ID -t $ID -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:$PERF_EVENT_CONTAINERCGROUP

PERF_EVENT_NATIVECGROUP="kvazaar_native.slice"
[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_NATIVECGROUP" ] && \
	echo Creating cgroup $PERF_EVENT_NATIVECGROUP  && sudo cgcreate -a $ID -t $ID -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:$PERF_EVENT_NATIVECGROUP

#PERF_EVENT_CONTAINERCGROUP="kvazaar_container.slice"
#[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_CONTAINERCGROUP" ] && \
#	echo Creating cgroup $PERF_EVENT_CONTAINERCGROUP && sudo cgcreate -a $ID -t $ID -g cpu,net_cls,devices,blkio,pids,perf_event,memory,hugetlb,freezer:$PERF_EVENT_CONTAINERCGROUP

#PERF_EVENT_NATIVECGROUP="kvazaar_native.slice"
#[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_NATIVECGROUP" ] && \
#	echo Creating cgroup $PERF_EVENT_NATIVECGROUP  && sudo cgcreate -a $ID -t $ID -g cpu,net_cls,devices,blkio,pids,perf_event,memory,hugetlb,freezer:$PERF_EVENT_NATIVECGROUP


#PERF_EVENT_DUMMYCGROUP="dummycgroup4test.slice"
#[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_DUMMYCGROUP" ] && \
#	echo a && sudo cgcreate -g cpu,cpuacct,net_cls,net_prio,devices,cpuset,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:$PERF_EVENT_DUMMYCGROUP

mkdir $DIR

sudo cpupower frequency-info > $DIR/$LOG.config
date >>  $DIR/$LOG.config

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
	
	rm -f $DIR/$LOG"_"$FILENAME".native.stat"
	rm -f $DIR/$LOG"_"$FILENAME".container.stat"

	#COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses,Turbo_Utilization,power/energy-cores/,power/energy-gpu/,power/energy-pkg/,power/energy-psys/,power/energy-ram/,Turbo_Utilization ./kvazaar_native_2.sh    $i $i.native.hevc $THREADS                         2>/dev/null 2>> $LOG"_"$FILENAME".native.stat"    >> $LOG"_"$FILENAME".native.stat""
	#OMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses,power/energy-cores/,power/energy-gpu/,power/energy-pkg/,power/energy-psys/,power/energy-ram/ -a ./kvazaar_native_cgroup.sh    $i $i.native.hevc $THREADS                         2>/dev/null 2>> $LOG"_"$FILENAME".native.stat"    >> $LOG"_"$FILENAME".native.stat""

	#COMMAND=" perf stat -r $RUNS -B -e power/energy-cores/,power/energy-gpu/,power/energy-pkg/,power/energy-psys/,power/energy-ram/ ./kvazaar_native_2.sh    $i $i.native.hevc $THREADS                         2>/dev/null 2>> $LOG"_"$FILENAME".native.stat""


	COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses,power/energy-cores/,power/energy-pkg/,power/energy-ram/,power/energy-cores/,power/energy-pkg/,power/energy-ram/ ./kvazaar_native_2.sh $i $i.native.hevc $THREADS 2>/dev/null 2>> $DIR/$LOG"_"$FILENAME".native.stat" >> $DIR/$LOG"_"$FILENAME".native.stat""
#	echo $COMMAND
#	eval $COMMAND
	#echo

	COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses,power/energy-cores/,power/energy-pkg/,power/energy-ram/,power/energy-cores/,power/energy-pkg/,power/energy-ram/ --cgroup=$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP -a ./kvazaar_native_cgroup.sh $i $i.native.cgroup.hevc $THREADS 2>/dev/null 2>> $DIR/$LOG"_"$FILENAME".native.cgroup.stat" >> $DIR/$LOG"_"$FILENAME".native.cgroup.stat""
	#echo $COMMAND
	#eval $COMMAND
	#echo

	COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses,power/energy-cores/,power/energy-pkg/,power/energy-ram/,power/energy-cores/,power/energy-pkg/,power/energy-ram/ --cgroup=$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP -a ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADS $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $DIR/$LOG"_"$FILENAME".container.stat" >> $DIR/$LOG"_"$FILENAME".container.stat""
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

	[ -f $DIR/$LOG"_"$FILENAME".native.stat" ] && echo $DIR/$LOG"_"$FILENAME".native.stat" && tail -n 27 $DIR/$LOG"_"$FILENAME".native.stat" && \
		echo -e "\n######################################################################################################################\n"

	[ -f $DIR/$LOG"_"$FILENAME".native.cgroup.stat" ] && echo $DIR/$LOG"_"$FILENAME".native.cgroup.stat" && tail -n 27 $DIR/$LOG"_"$FILENAME".native.cgroup.stat" && \
		echo -e "\n######################################################################################################################\n"

	[ -f $DIR/$LOG"_"$FILENAME".container.stat" ] && echo $DIR/$LOG"_"$FILENAME".container.stat" && tail -n 27 $DIR/$LOG"_"$FILENAME".container.stat" && \
		echo -e "\n######################################################################################################################\n"


	[ -f $DIR/$LOG"_"$FILENAME".container.system-wide.stat" ] && echo $DIR/$LOG"_"$FILENAME".container.stat" && tail -n 27 $DIR/$LOG"_"$FILENAME".container.system-wide.stat" && \
		echo -e "\n######################################################################################################################\n"

	[ -f $DIR/$LOG"_"$FILENAME".container.system-wide.stat" ] && echo $DIR/$LOG"_"$FILENAME".container.dummy.stat" && tail -n 27 $DIR/$LOG"_"$FILENAME".container.dummy.stat" && \
		echo -e "\n######################################################################################################################\n"
done

date >>  $DIR/$LOG.config

