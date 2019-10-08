#!/bin/bash
N_PROC=`grep -c processor /proc/cpuinfo`
N_FILES=`ls -1 "$@" | wc -l`
DATE=`date '+%Y%m%d_%H%M%S'`
RUNS=1
HOSTNAME=`hostname -s`

THREADS="$(grep processor -c /proc/cpuinfo)"
CPUSET="0-$((`grep processor -c /proc/cpuinfo` - 1))"

LOG=perfstat"_"$DATE"_"$HOSTNAME"_"$THREADS"_"$RUNS


#PERF_EVENT_CGROUP=$(grep perf_event /proc/$TEMP1/cgroup | sed 's/[^/]*[/]//')
#PERF_EVENT_CGROUP="system.slice"
#TEMP1=$(docker inspect -f '{{.State.Pid}}' $CONTAINER_NAME)
PERF_EVENT_CGROUP="dockerkvazaaresl.slice"
PERF_EVENT_DUMMYCGROUP="dummycgroup4test.slice"

[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_CGROUP" ] && \
	echo a && sudo cgcreate -g cpu,cpuacct,net_cls,net_prio,devices,cpuset,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:$PERF_EVENT_CGROUP

[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_DUMMYCGROUP" ] && \
	echo a && sudo cgcreate -g cpu,cpuacct,net_cls,net_prio,devices,cpuset,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:$PERF_EVENT_DUMMYCGROUP

echo N_PROC: $N_PROC 
echo N_FILE: $N_FILES 
echo 

for i in "$@";
do
	rm -f  $i.hevc;
done


for i in "$@"; 
do
	echo $i
	FILENAME=$(basename -- "$i")
	
	rm -f $LOG"_"$FILENAME".native.stat"
	rm -f $LOG"_"$FILENAME".container.stat"

	#COMMAND="perf stat -r $RUNS -B ./kvazaar_native.sh    $i $i.hevc $THREADS         2>/dev/null 2>> $LOG"_"$FILENAME".native.stat"    >> $LOG"_"$FILENAME".native.stat""
	#echo $COMMAND
	#eval $COMMAND

	#COMMAND="perf stat -r $RUNS -B -a ./kvazaar_native.sh    $i $i.hevc $THREADS         2>/dev/null 2>> $LOG"_"$FILENAME".native.system-wide.stat"    >> $LOG"_"$FILENAME".native.system-wide.stat""
	#echo $COMMAND
	#eval $COMMAND

	#COMMAND="perf stat -r $RUNS -B ./kvazaar_container.sh $i $i.hevc $THREADS $CPUSET -G \":cpu,cpuacct:/\" 2>/dev/null 2>> $LOG"_"$FILENAME".container.stat" >> $LOG"_"$FILENAME".container.stat""

	CONTAINER_NAME="kvazaar_$FILENAME"

	#COMMAND="perf stat -r $RUNS -B ./kvazaar_container.sh $i $i.hevc $THREADS $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $LOG"_"$FILENAME".container.stat" >> $LOG"_"$FILENAME".container.stat""
	#echo $COMMAND
	#eval $COMMAND &
	
	#sleep 1
	




#      240,105758      task-clock (msec)         #    0,037 CPUs utilized            ( +-  0,13% )
#             9 039      context-switches          #    0,038 M/sec                    ( +-  0,34% )
#             1 648      cpu-migrations            #    0,007 M/sec                    ( +-  0,31% )
#             5 451      page-faults               #    0,023 M/sec                    ( +-  0,05% )
#       672 436 078      cycles                    #    2,801 GHz                      ( +-  0,08% )
#       352 956 443      instructions              #    0,52  insn per cycle           ( +-  0,06% )
#        68 572 513      branches                  #  285,593 M/sec                    ( +-  0,06% )
#         2 412 837      branch-misses             #    3,52% of all branches          ( +-  0,10% )

	COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses --cgroup=,,,,,,,, -a ./kvazaar_container.sh $i $i.hevc $THREADS $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $LOG"_"$FILENAME".container.stat1" >> $LOG"_"$FILENAME".container.stat1""
	echo $COMMAND
	eval $COMMAND

	COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses --cgroup=$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP,$PERF_EVENT_CGROUP -a ./kvazaar_container.sh $i $i.hevc $THREADS $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $LOG"_"$FILENAME".container.stat2" >> $LOG"_"$FILENAME".container.stat2""
	echo $COMMAND
	eval $COMMAND
	
	COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses --cgroup=$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP,$PERF_EVENT_DUMMYCGROUP -a ./kvazaar_container.sh $i $i.hevc $THREADS $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $LOG"_"$FILENAME".container.stat3" >> $LOG"_"$FILENAME".container.stat3""
	echo $COMMAND
	eval $COMMAND
	
	tail -n 20 $LOG"_"$FILENAME".container.stat1"
	echo -e "\n######################################################################################################################\n"
	tail -n 20 $LOG"_"$FILENAME".container.stat2"
	echo -e "\n######################################################################################################################\n"
	tail -n 20 $LOG"_"$FILENAME".container.stat3"

	
done


