#!/bin/bash
N_PROC=`grep -c processor /proc/cpuinfo`
N_FILES=`ls -1 "$@" | wc -l`
DATE=`date '+%Y%m%d_%H%M%S'`
RUNS=1
HOSTNAME=`hostname -s`
ID=$(whoami):root

MAX_THREADS="$(grep processor -c /proc/cpuinfo)"
THREADS=$MAX_THREADS
CPUSET="0-$((`grep processor -c /proc/cpuinfo` - 1))"

DIR=$DATE"_"$HOSTNAME"_"$THREADS"_"$RUNS
LOG=perfstat"_"$DATE"_"$HOSTNAME"_"$THREADS"_"$RUNS

#sudo cgdelete -g cpu,net_cls,devices,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:kvazaar_container.slice
#sudo cgdelete -g cpu,net_cls,devices,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:kvazaar_native.slice

sudo cgdelete -g cpu,net_cls,blkio,pids,perf_event,hugetlb,freezer:kvazaar_container.slice
sudo cgdelete -g cpu,net_cls,blkio,pids,perf_event,hugetlb,freezer:kvazaar_native.slice

PERF_EVENT_CONTAINERCGROUP="kvazaar_container.slice"
[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_CONTAINERCGROUP" ] && \
	echo Creating cgroup $PERF_EVENT_CONTAINERCGROUP && sudo cgcreate -a $ID -t $ID -g cpu,net_cls,blkio,pids,perf_event,hugetlb,freezer:$PERF_EVENT_CONTAINERCGROUP

PERF_EVENT_NATIVECGROUP="kvazaar_native.slice"
[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_NATIVECGROUP" ] && \
	echo Creating cgroup $PERF_EVENT_NATIVECGROUP  && sudo cgcreate -a $ID -t $ID -g cpu,net_cls,blkio,pids,perf_event,hugetlb,freezer:$PERF_EVENT_NATIVECGROUP

mkdir $DIR

sudo cpupower frequency-info > $DIR/$LOG.config
date >>  $DIR/$LOG.config

echo N_PROC: $N_PROC 
echo N_FILE: $N_FILES 
echo 


for i in "$@"; 
do
	echo $i
	echo

	FILENAME=$(basename -- "$i")
	CONTAINER_NAME="kvazaar_$FILENAME"

	for FREQUENCYRAW in $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies); do
		for (( THREADSRAW=$MAX_THREADS; THREADSRAW>0; THREADSRAW-- )); do
			printf -v FREQUENCY "%07d" $FREQUENCYRAW;
			printf -v THREADS "%02d" $THREADSRAW;
			CPUSET="0-$(($THREADSRAW - 1))"
			LOG=perfstat"_"$DATE"_"$HOSTNAME"_"$FILENAME"_"$FREQUENCY"_"$THREADS"_"$RUNS
			echo "Frequency (set):" $FREQUENCYRAW
			sudo cpupower frequency-set -d $FREQUENCYRAW -u $FREQUENCYRAW > /dev/null
			echo -n "Frequency (measured):" $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq) " /"
			sudo cpupower frequency-info|grep current.*asserted
			echo "Threads:" $THREADS
			echo "CPUset:" $CPUSET
			echo

			#COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses,power/energy-cores/,power/energy-pkg/,power/energy-ram/,power/energy-cores/,power/energy-pkg/,power/energy-ram/ ./kvazaar_native_2.sh $i $i.native.hevc $THREADS 2>/dev/null 2>> $DIR/$LOG"_"$FILENAME".native.stat" >> $DIR/$LOG"_"$FILENAME".native.stat""
			#echo $COMMAND
			#eval $COMMAND
			#echo

			#COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses,power/energy-cores/,power/energy-pkg/,power/energy-ram/,power/energy-cores/,power/energy-pkg/,power/energy-ram/ --cgroup=$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP -a ./kvazaar_native_cgroup_ultrafast.sh $i $i.native.cgroup.hevc $THREADS 2>/dev/null 2>> $DIR/$LOG"_"$FILENAME".native.cgroup.stat" >> $DIR/$LOG"_"$FILENAME".native.cgroup.stat""
		#	echo $COMMAND
		#	eval $COMMAND
		#	echo

			COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses,power/energy-cores/,power/energy-pkg/,power/energy-ram/,power/energy-cores/,power/energy-pkg/,power/energy-ram/ --cgroup=$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP -a ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $DIR/$LOG"."container.stat" >> $DIR/$LOG"."container.stat""
			echo $COMMAND
			eval $COMMAND
			echo

			echo -e "\n**********************************************************************************************************************\n"


			[ -f $DIR/$LOG"."native.stat ] && echo $DIR/$LOG"."native.stat" && tail -n 27 $DIR/$LOG"."native.stat" && \
				echo -e "\n######################################################################################################################\n"

			[ -f $DIR/$LOG"."native.cgroup.stat ] && echo $DIR/$LOG"."native.cgroup.stat" && tail -n 27 $DIR/$LOG"."native.cgroup.stat" && \
				echo -e "\n######################################################################################################################\n"

			[ -f $DIR/$LOG"."container.stat ] && echo $DIR/$LOG"."container.stat" && tail -n 27 $DIR/$LOG"."container.stat" && \
				echo -e "\n######################################################################################################################\n"
		done
	done

	echo -e "\n######################################################################################################################\n"

done

date >>  $DIR/$LOG.config

