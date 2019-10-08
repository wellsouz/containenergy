#!/bin/bash

SCRIPT_PID=$$

#sudo taskset -cp 1,2,3,5,6,7 $SCRIPT_PID

#for i in $(pgrep docker); do
#	sudo taskset -cp 1,2,3,5,6,7 $i
#	sudo chrt -r -p 1 $i
#	sudo chrt -p $i
#done

RUNS=10
TURNOFF_IDLECORES=0

#CORES=(0 1 2 3 4 5 6 7)
#CORES=(0 4 1 5 2 6 3 7)
#CORES=(1 5 2 6 3 7)
#CORES=(7 6 5 4 3 2 1)
#CORES=(1)
#CORES=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31)
#CORES=(0 16 1 17 2 18 3 19 4 20 5 21 6 22 7 23 8 24 9 25 10 26 11 27 12 28 13 29 14 30 15 31)
CORES=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127)

./resetgovernor.sh > /dev/null

for CPUON in /sys/devices/system/cpu/cpu*/online; do
	sudo sh -c "echo 1 > $CPUON"
done

N_PROC=`grep -c processor /proc/cpuinfo`
N_FILES=`ls -1 "$@" | wc -l`
DATE=`date '+%Y%m%d_%H%M%S'`
HOSTNAME=`hostname -s`
ID=$(whoami):root

MAX_THREADS="$(grep processor -c /proc/cpuinfo)"

THREADS=$MAX_THREADS

if [ ${#CORES[@]} -lt $MAX_THREADS ]; then THREADS=${#CORES[@]}; fi


CPUSET="0-$((`grep processor -c /proc/cpuinfo` - 1))"

DIR=$DATE"_"$HOSTNAME"_"$THREADS"_"$RUNS
LOG=perfstat"_"$DATE"_"$HOSTNAME"_"$THREADS"_"$RUNS


#sudo cgdelete -g cpu,net_cls,blkio,pids,perf_event,hugetlb,freezer:kvazaar_container.slice

#PERF_EVENT_CONTAINERCGROUP="kvazaar_container.slice"
#[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_CONTAINERCGROUP" ] && \
#        echo Creating cgroup $PERF_EVENT_CONTAINERCGROUP && sudo cgcreate -a $ID -t $ID -g cpu,net_cls,blkio,pids,perf_event,hugetlb,freezer:$PERF_EVENT_CONTAINERCGROUP



#sudo cgdelete -g cpu,net_cls,devices,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:kvazaar_container.slice
#sudo cgdelete -g cpu,net_cls,devices,blkio,pids,perf_event,memory,rdma,hugetlb,freezer:kvazaar_native.slice


sudo cgdelete -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:kvazaar_container.slice

#sudo cgdelete -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:kvazaar_container.slice
#sudo cgdelete -g cpu,net_cls,blkio,pids,perf_event,hugetlb,freezer:kvazaar_native.slice

PERF_EVENT_CONTAINERCGROUP="kvazaar_container.slice"
[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_CONTAINERCGROUP" ] && \
	echo Creating cgroup $PERF_EVENT_CONTAINERCGROUP && sudo cgcreate -a $ID -t $ID -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:$PERF_EVENT_CONTAINERCGROUP

#PERF_EVENT_NATIVECGROUP="kvazaar_native.slice"
#[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_NATIVECGROUP" ] && \
#	echo Creating cgroup $PERF_EVENT_NATIVECGROUP  && sudo cgcreate -a $ID -t $ID -g cpu,net_cls,blkio,pids,perf_event,hugetlb,freezer:$PERF_EVENT_NATIVECGROUP


mkdir $DIR


sudo cpupower frequency-set -g userspace > /dev/null
sudo cpupower frequency-info >> $DIR/$LOG.config
date >>  $DIR/$LOG.config
echo -n CORES=>>$DIR/$LOG.config
printf "%s " "${CORES[@]}" >> $DIR/$LOG.config
echo >> $DIR/$LOG.config
echo "TURNOFF_IDLECORES="$TURNOFF_IDLECORES >> $DIR/$LOG.config

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
		
		for CPUON in /sys/devices/system/cpu/cpu*/online; do
			sudo sh -c "echo 1 > $CPUON"
		done

		sync
		sudo cpupower frequency-set -d $FREQUENCYRAW -u $FREQUENCYRAW > /dev/null
		sudo cpupower frequency-set -f $FREQUENCYRAW > /dev/null
		sync
#		sudo systemctl restart docker
		sleep 2

		echo "Frequency (set):" $FREQUENCYRAW
		echo -n "Frequency (measured):" $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq) " /"
		sudo cpupower frequency-info|grep current.*asserted

#		lstopo --no-io >/dev/null &
#		LSTOPO_PID1=$!

		
		for (( THREADSRAW=$THREADS; THREADSRAW>0; THREADSRAW-- )); do	

			printf -v FREQUENCYPRINT "%07d" $FREQUENCYRAW;
			printf -v THREADSPRINT "%02d" $THREADSRAW;
			
			LOG=perfstat"_"$DATE"_"$HOSTNAME"_"$FILENAME"_"$FREQUENCYPRINT"_"$THREADSPRINT"_"$RUNS
			CPUSET=""
			
			#CPUSET="0-$(($THREADSRAW - 1))"

			for (( CPU=0; CPU < $MAX_THREADS; CPU++ )); do 
				if [ $CPU -ge $THREADSRAW ]; 
					then
						if [ $TURNOFF_IDLECORES -eq 1 ]; then
							sudo sh -c "echo 0 > /sys/devices/system/cpu/cpu${CORES[$CPU]}/online";
						fi
					else
						sudo sh -c "echo 1 > /sys/devices/system/cpu/cpu${CORES[$CPU]}/online";
						if [ $CPU -eq 0 ];
							then CPUSET=${CORES[$CPU]};
							else CPUSET=$CPUSET,${CORES[$CPU]};
						fi
				fi
			done

			sync

			clear

			echo "File: " $FILENAME
			echo
			echo "Frequency (set):" $FREQUENCYRAW
			#echo -n "Frequency (measured):" $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq) " /"
			#echo -n "Frequency (measured):" 
			sudo cpupower frequency-info|grep current.*asserted
			echo "Threads:" $THREADSRAW
			echo 
			echo "CPUset:" $CPUSET | grep --color $CPUSET
			echo CPU0: 1
			for (( CPU=1; CPU < $MAX_THREADS; CPU++ )); do 
				echo CPU$CPU: $(cat /sys/devices/system/cpu/cpu$CPU/online)
			done

			#sudo likwid-topology -g

#			lstopo --no-io 2>/dev/null > /dev/null &
#			LSTOPO_PID2=$!
#			sync
#			sleep 0.05
#			kill $LSTOPO_PID1 2>/dev/null > /dev/null
#			wait $LSTOPO_PID1 2>/dev/null
#			LSTOPO_PID1=$LSTOPO_PID2
#			echo

			#read

#			sudo cgdelete -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:kvazaar_container.slice
#			#sudo cgdelete -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:kvazaar_native.slice
#
#			PERF_EVENT_CONTAINERCGROUP="kvazaar_container.slice"
#			[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_CONTAINERCGROUP" ] && \
#				echo Creating cgroup $PERF_EVENT_CONTAINERCGROUP && sudo cgcreate -a $ID -t $ID -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:$PERF_EVENT_CONTAINERCGROUP
#
#			#PERF_EVENT_NATIVECGROUP="kvazaar_native.slice"
#			#[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_NATIVECGROUP" ] && \
#			#	echo Creating cgroup $PERF_EVENT_NATIVECGROUP  && sudo cgcreate -a $ID -t $ID -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:$PERF_EVENT_NATIVECGROUP
#
#			echo

			#COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses,power/energy-cores/,power/energy-pkg/,power/energy-ram/,power/energy-cores/,power/energy-pkg/,power/energy-ram/ ./kvazaar_native_2.sh $i $i.native.hevc $THREADS 2>/dev/null 2>> $DIR/$LOG"_"$FILENAME".native.stat" >> $DIR/$LOG"_"$FILENAME".native.stat""
			#echo $COMMAND
			#eval $COMMAND
			#echo

			#COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses,power/energy-cores/,power/energy-pkg/,power/energy-ram/,power/energy-cores/,power/energy-pkg/,power/energy-ram/ --cgroup=$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP,$PERF_EVENT_NATIVECGROUP -a ./kvazaar_native_cgroup_ultrafast.sh $i $i.native.cgroup.hevc $THREADS 2>/dev/null 2>> $DIR/$LOG"_"$FILENAME".native.cgroup.stat" >> $DIR/$LOG"_"$FILENAME".native.cgroup.stat""
		#	echo $COMMAND
		#	eval $COMMAND
		#	echo

			#COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses,power/energy-cores/,power/energy-pkg/,power/energy-ram/,power/energy-cores/,power/energy-pkg/,power/energy-ram/ --cgroup=$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP -a ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $DIR/$LOG"."container.stat" >> $DIR/$LOG"."container.stat""


			COMMAND="perf stat -r $RUNS -B -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses,power/energy-cores/,power/energy-pkg/,power/energy-ram/,power/energy-cores/,power/energy-pkg/,power/energy-ram/ --cgroup=$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP -a ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $DIR/$LOG"."container.stat" >> $DIR/$LOG"."container.stat""


			echo $COMMAND | grep --color " $CPUSET "
			eval $COMMAND
			echo

			

			echo -e "\n**********************************************************************************************************************\n"


			[ -f $DIR/$LOG"."native.stat ] && echo $DIR/$LOG"."native.stat" && tail -n 27 $DIR/$LOG"."native.stat" && \
				echo -e "\n######################################################################################################################\n"

			[ -f $DIR/$LOG"."native.cgroup.stat ] && echo $DIR/$LOG"."native.cgroup.stat" && tail -n 27 $DIR/$LOG"."native.cgroup.stat" && \
				echo -e "\n######################################################################################################################\n"

			[ -f $DIR/$LOG"."container.stat ] && echo $DIR/$LOG"."container.stat && tail -n 27 $DIR/$LOG"."container.stat && \
				echo -e "\n######################################################################################################################\n"


			sleep 2
		done
		kill -9 $LSTOPO_PID1 2>/dev/null > /dev/null
		wait $LSTOPO_PID1 2>/dev/null
		kill -9 $LSTOPO_PID2 2>/dev/null > /dev/null
		wait $LSTOPO_PID2 2>/dev/null
	done

	echo -e "\n######################################################################################################################\n"

done

date >>  $DIR/$LOG.config

./resetgovernor.sh > /dev/null

