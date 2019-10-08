#!/bin/bash
export LC_ALL="en_US.UTF-8"
#export LC_ALL=C.UTF-8
export GDM_LANG=en_US
export LANGUAGE=en_US:en

# Execution parameters
RUNS=5
TURNOFF_IDLECORES=0
SAMPLING_INTERVAL=100
SHOW_TOPOLOGY=0
N_EVENTS=10
PERF_EVENT_CONTAINERCGROUP="kvazaar_container.slice"

# Global variables
EVENT=""
EVENT_ARRAY=()
CORES=()
N_PROC=`grep -c processor /proc/cpuinfo`
N_FILES=`ls -1 "$@" | wc -l`
DATE=`date '+%Y%m%d_%H%M%S'`
HOSTNAME=`hostname -s`
ID=$(whoami):root
MAX_THREADS="$(grep processor -c /proc/cpuinfo)"
CPUSET="0-$((`grep processor -c /proc/cpuinfo` - 1))"

# Define the number of threads (tunable), but limited to the amount of cores
THREADS=$MAX_THREADS
if [ ${#CORES[@]} -lt $MAX_THREADS ]; then THREADS=${#CORES[@]}; fi

# Logging parameters
DIR=_results/$DATE"_"$HOSTNAME"_"$THREADS"_"$RUNS
LOGGENERAL=perfstat"_"$DATE"_"$HOSTNAME"_"$THREADS"_"$RUNS

# Set execution according host characteristics (cores, events, ...)
if [ "$HOSTNAME" == "eslpc39" ]; then
	N_EVENTS=10
	CORES=(0 1 2 3 4 5 6 7)
	#CORES=(0 4 1 5 2 6 3 7)

	#two counters test on eslpc39
	EVENT_ARRAY+=(branch-misses:u,bus-cycles:u)
	EVENT_ARRAY+=(fp_arith_inst_retired.scalar_double:u,instructions:u)
	EVENT_ARRAY+=(l2_rqsts.all_demand_references:u,l2_rqsts.pf_miss:u)
	EVENT_ARRAY+=(l2_rqsts.all_pf:u,mem_load_retired.l1_miss:u)
	EVENT_ARRAY+=(mem_load_retired.l2_miss:u,mem_load_retired.l3_miss:u)
	EVENT_ARRAY+=(offcore_response.demand_data_rd.l3_miss_local_dram.any_snoop:u,offcore_requests.l3_miss_demand_data_rd)
	EVENT_ARRAY+=(resource_stalls.any:u,uops_executed.core:u)

	#all counters test, and counters in 3 groups  on eslpc39 - Katza test
	#EVENT_ARRAY+=(uops_executed.core:u,branch-misses:u,bus-cycles:u,fp_arith_inst_retired.scalar_double:u,instructions:u,l2_rqsts.all_pf:u,l2_rqsts.all_demand_references:u,l2_rqsts.pf_miss:u,mem_load_retired.l1_miss:u,mem_load_retired.l2_miss:u,mem_load_retired.l3_miss:u,offcore_response.demand_data_rd.l3_miss_local_dram.any_snoop:u,offcore_requests.l3_miss_demand_data_rd:u,resource_stalls.any:u,unc_arb_trk_requests.writes:u)
	#EVENT_ARRAY+=(branch-misses:u,bus-cycles:u,fp_arith_inst_retired.scalar_double:u,instructions:u,l2_rqsts.all_pf:u)
	#EVENT_ARRAY+=(l2_rqsts.all_demand_references:u,l2_rqsts.pf_miss:u,mem_load_retired.l1_miss:u,mem_load_retired.l2_miss:u,mem_load_retired.l3_miss:u)
	#EVENT_ARRAY+=(offcore_response.demand_data_rd.l3_miss_local_dram.any_snoop:u,offcore_requests.l3_miss_demand_data_rd:u,resource_stalls.any:u,unc_arb_trk_requests.writes:u,uops_executed.core:u)

	#Individual multiple run test on eslpc39
	#EVENT_ARRAY+=(branch-misses:u)								#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(bus-cycles:u)								#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(fp_arith_inst_retired.scalar_double:u)					#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(instructions:u)								#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(l2_rqsts.all_demand_references:u)					#eslpc39 and eslsrv10

	#EVENT_ARRAY+=(l2_rqsts.all_pf:u)							#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(l2_rqsts.pf_miss:u)							#eslpc39 specific
	#EVENT_ARRAY+=(mem_load_retired.l1_miss:u)						#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(mem_load_retired.l2_miss:u)						#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(mem_load_retired.l3_miss:u)						#eslpc39 and eslsrv10

	#EVENT_ARRAY+=(offcore_response.demand_data_rd.l3_miss_local_dram.any_snoop:u)		#eslpc39 specific
	#EVENT_ARRAY+=(offcore_requests.l3_miss_demand_data_rd:u)				#eslpc39 specific
	#EVENT_ARRAY+=(resource_stalls.any:u)							#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(unc_arb_trk_requests.writes:u)						#eslpc39 specific

	#EVENT_ARRAY+=(uops_executed.core:u)							#eslpc39 and eslsrv10

elif [ "$HOSTNAME" == "eslsrv10" ]; then
	N_EVENTS=1
	CORES=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31)
	#CORES=(0 16 1 17 2 18 3 19 4 20 5 21 6 22 7 23 8 24 9 25 10 26 11 27 12 28 13 29 14 30 15 31)
	
	#Individual multiple run test on eslsrv10
	#EVENT_ARRAY+=(branch-misses:u)								#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(bus-cycles:u)								#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(fp_arith_inst_retired.scalar_double:u)					#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(instructions:u)								#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(l2_rqsts.all_demand_references:u)					#eslpc39 and eslsrv10 - not in Trello list
	#EVENT_ARRAY+=(l2_rqsts.all_pf:u)							#eslpc39 and eslsrv10 - not in Trello list
	#EVENT_ARRAY+=(l2_rqsts.l2_pf_miss:u)							#eslsrv10 specific

	#EVENT_ARRAY+=(l2_trans.all_pf:u)							#eslsrv10 specific
	#EVENT_ARRAY+=(llc_misses.mem_read:u)							#eslsrv10 specific
	#EVENT_ARRAY+=(llc_misses.mem_write:u)							#eslsrv10 specific
	#EVENT_ARRAY+=(llc_references.code_llc_prefetch:u)					#eslsrv10 specific
	#EVENT_ARRAY+=(mem_load_retired.l1_miss:u)						#eslpc39 and eslsrv10

	#EVENT_ARRAY+=(mem_load_retired.l2_miss:u)						#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(mem_load_retired.l3_miss:u)						#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(offcore_response.all_code_rd.llc_miss.local_dram:u)			#eslsrv10 specific
	#EVENT_ARRAY+=(resource_stalls.any:u)							#eslpc39 and eslsrv10
	#EVENT_ARRAY+=(uops_executed.core:u)							#eslpc39 and eslsrv10

	#Load_Miss_Real_Latency, \ 			# not working

	# Katza test on server 10
	#EVENT_ARRAY+=(branch-misses:u,bus-cycles:u,fp_arith_inst_retired.scalar_double:u,instructions:u,l2_rqsts.l2_pf_miss:u)
	#EVENT_ARRAY+=(l2_trans.all_pf:u,llc_misses.mem_read,llc_misses.mem_write,llc_references.code_llc_prefetch,mem_load_uops_retired.l1_miss:u)
	#EVENT_ARRAY+=(mem_load_uops_retired.l2_miss:u,mem_load_uops_retired.l3_miss:u,offcore_response.all_code_rd.llc_miss.local_dram:u,resource_stalls.any:u,uops_executed.core:u)
	#EVENT_ARRAY+=(uops_executed.core:u,branch-misses:u,bus-cycles:u,fp_arith_inst_retired.scalar_double:u,instructions:u,l2_rqsts.l2_pf_miss:u,l2_trans.all_pf:u,llc_misses.mem_read,llc_misses.mem_write,llc_references.code_llc_prefetch,mem_load_uops_retired.l1_miss:u,mem_load_uops_retired.l2_miss:u,mem_load_uops_retired.l3_miss:u,offcore_response.all_code_rd.llc_miss.local_dram:u,resource_stalls.any:u)

	# Profiling -> Correlated Filter
	EVENT_ARRAY+=(branch-misses:u,bus-cycles:u,fp_arith_inst_retired.scalar_double:u,l2_rqsts.l2_pf_miss:u,instructions:u)
	#EVENT_ARRAY+=(resource_stalls.any:u,uops_executed.core:u,power/energy-pkg/,power/energy-ram/,instructions:u)
	#EVENT_ARRAY+=(l2_trans.all_pf:u,llc_misses.mem_read,llc_misses.mem_write,llc_references.code_llc_prefetch,instructions:u)
	#EVENT_ARRAY+=(mem_load_uops_retired.l1_miss:u,mem_load_uops_retired.l2_miss:u,mem_load_uops_retired.l3_miss:u,offcore_response.all_code_rd.llc_miss.local_dram:u,instructions:u)
else
	echo HOST events not defined in script >&2
	exit 1
fi

# Allowing gathering of perf event to regular user and disabling Non-maskable interrupts (NMI) as it interfers in perf execution
sudo sh -c "echo -1 > /proc/sys/kernel/perf_event_paranoid"
sudo sh -c "echo 0 > /proc/sys/kernel/nmi_watchdog"

# CPUFreq, CPU online and container reset
./resetgovernor.sh > /dev/null

# CGROUPS reset
sudo cgdelete -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:$PERF_EVENT_CONTAINERCGROUP
[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_CONTAINERCGROUP" ] && \
	echo Creating cgroup $PERF_EVENT_CONTAINERCGROUP && \
	sudo cgcreate -a $ID -t $ID -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:$PERF_EVENT_CONTAINERCGROUP

# Logging initialization
mkdir -p $DIR
date >>  $DIR/$LOGGENERAL.config
echo "CORES=("$CORES")" >>  $DIR/$LOGGENERAL.config
echo "TURNOFF_IDLECORES="$TURNOFF_IDLECORES >> $DIR/$LOGGENERAL.config
sudo cpupower frequency-info >> $DIR/$LOGGENERAL.config


# Processing
echo N_PROC: $N_PROC 
echo N_FILE: $N_FILES 
echo 

for (( m=0; m < ${#EVENT_ARRAY[@]} ; m++ )); do
	EVENT=${EVENT_ARRAY[$m]}
	EVENT_LIST=""
	EVENT_LIST_TEMP=""
	EVENT_LIST_ARRAY=()
	EVENT_LIST_ARRAY_TEMP=()
	CGROUP_LIST=""

	for (( n=0; n < $N_EVENTS; n++ )); do
		EVENT_LIST_ARRAY+=($EVENT)
	done

	OIFS=$IFS;
	IFS=",";
	EVENT_LIST_ARRAY_TEMP=($EVENT_LIST_ARRAY)
	IFS=$OIFS

	for (( o=0; o < ${#EVENT_LIST_ARRAY_TEMP[@]} ; o++ )); do
		if [ $o -gt 0 ]; then 
			EVENT_LIST="$EVENT_LIST "
		fi
		EVENT_LIST=$EVENT_LIST"-e "${EVENT_LIST_ARRAY_TEMP[$o]}
	done
	
	#EVENT_COUNTER=$(echo $EVENT_LIST_TEMP | tr -d -c ',' | wc -m)


	#for (( p=0; p <= $EVENT_COUNTER; p++)); do
	#	if [ $p -gt 0 ]; then
	#		EVENT_LIST="$CGROUP_LIST,"
	#	fi
        #        EVENT_LIST=$CGROUP_LIST""$PERF_EVENT_CONTAINERCGROUP
	#done

	#for (( p=0; p <= $EVENT_COUNTER; p++)); do
	#	if [ $p -gt 0 ]; then
	#		CGROUP_LIST="$CGROUP_LIST,"
	#	fi
        #        CGROUP_LIST=$CGROUP_LIST""$PERF_EVENT_CONTAINERCGROUP
	#done

	for i in "$@"; do
		FILENAME=$(basename -- "$i")
		CONTAINER_NAME="kvazaar_$FILENAME"
		echo $i
		echo

	#	for FREQUENCYRAW in 1200000 2200000 3200000; do
		for FREQUENCYRAW in $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies); do
	#	for FREQUENCYRAW in $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies | cut -f 2 -d ' '); do
			#for CPUON in /sys/devices/system/cpu/cpu*/online; do
			#	sudo sh -c "echo 1 > $CPUON"
			#done
			./resetgovernor.sh > /dev/null

			sync
			sudo cpupower frequency-set -d $FREQUENCYRAW -u $FREQUENCYRAW > /dev/null
			sudo cpupower frequency-set -f $FREQUENCYRAW > /dev/null
			sync
			#sudo systemctl restart docker
			sleep 2

			echo "Frequency (set):" $FREQUENCYRAW
			echo -n "Frequency (measured):" $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq) " /"
			sudo cpupower frequency-info|grep current.*asserted
			
			if [ $SHOW_TOPOLOGY -eq 1 ]; then
				lstopo --no-io >/dev/null &
				LSTOPO_PID1=$!
			fi

			
	#		for THREADSRAW in 32 16 1; do	
			for (( THREADSRAW=$MAX_THREADS; THREADSRAW>0; THREADSRAW-- )); do	
	#		for (( THREADSRAW=$MAX_THREADS; THREADSRAW>$MAX_THREADS-1; THREADSRAW-- )); do	

				printf -v FREQUENCY "%07d" $FREQUENCYRAW;
				printf -v THREADS "%02d" $THREADSRAW;
				
				LOG=$(echo perfstat"_"$DATE"_"$HOSTNAME"_"$FILENAME"_"$FREQUENCY"_"$THREADS"_"$RUNS"_"$(echo $EVENT|cut -c1-20) | sed -r 's/\//_/g')
				CPUSET="0"
				

				for (( CPU=1; CPU < $MAX_THREADS; CPU++ )); do 
					if [ $CPU -ge $THREADSRAW ]; 
						then
							if [ $TURNOFF_IDLECORES -eq 1 ]; then
								sudo sh -c "echo 0 > /sys/devices/system/cpu/cpu${CORES[$CPU]}/online";
							fi
						else
							sudo sh -c "echo 1 > /sys/devices/system/cpu/cpu${CORES[$CPU]}/online";
							CPUSET=$CPUSET,${CORES[$CPU]}
					fi
				done

				sync

				for PRESET in ultrafast; do
					echo "File: " $FILENAME
					echo
					echo "Frequency (set):" $FREQUENCYRAW
					sudo cpupower frequency-info|grep current.*asserted
					echo "Threads:" $THREADSRAW
					echo 
					echo "CPUset:" $CPUSET | grep --color $CPUSET
					echo 
					echo "Preset:" $PRESET
					echo

					{
						echo CPU0: 1
						for (( CPU=1; CPU < $MAX_THREADS; CPU++ )); do 
							echo CPU$CPU: $(cat /sys/devices/system/cpu/cpu$CPU/online)
						done 
					} | column
					echo

					if [ $SHOW_TOPOLOGY -eq 1 ]; then
						#sudo likwid-topology -g
						lstopo --no-io 2>/dev/null > /dev/null &
						LSTOPO_PID2=$!
						sync
						sleep 0.05
						kill $LSTOPO_PID1 2>/dev/null > /dev/null
						wait $LSTOPO_PID1 2>/dev/null
						LSTOPO_PID1=$LSTOPO_PID2
						echo
						#read
					fi


					for (( RUN=0; RUN<$RUNS; RUN++ )); do


			#			sudo cgdelete -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:kvazaar_container.slice
			#
			#			PERF_EVENT_CONTAINERCGROUP="kvazaar_container.slice"
			#			[ ! -d "$(grep cgroup /proc/mounts|grep perf_event| cut -f 2 -d ' ')/$PERF_EVENT_CONTAINERCGROUP" ] && \
			#				echo Creating cgroup $PERF_EVENT_CONTAINERCGROUP && sudo cgcreate -a $ID -t $ID -g cpu,cpuset,net_cls,blkio,pids,perf_event,hugetlb,freezer:$PERF_EVENT_CONTAINERCGROUP
			#
			#			echo

			#			COMMAND="perf stat -r $RUNS -I $SAMPLING_INTERVAL -C $CPUSET -a ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $DIR/$LOG"."container.stat" >> $DIR/$LOG"."container.stat""
			#			COMMAND="perf stat -r $RUNS -I $SAMPLING_INTERVAL -e task-clock,context-switches,cpu-migrations,page-faults,cycles,cycles:u,instructions,branches,branch-misses,power/energy-cores/,power/energy-pkg/,power/energy-ram/,power/energy-cores/,power/energy-pkg/,power/energy-ram/ --cgroup=$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP -a ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $DIR/$LOG"."container.stat" >> $DIR/$LOG"."container.stat""
			#			COMMAND="perf stat -r $RUNS -I $SAMPLING_INTERVAL -e power/energy-cores/,power/energy-pkg/,power/energy-ram/,power/energy-cores/,power/energy-pkg/,power/energy-ram/ --cgroup=$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP,$PERF_EVENT_CONTAINERCGROUP -a ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $DIR/$LOG"."container.stat" >> $DIR/$LOG"."container.stat""
			#			COMMAND="perf stat -r $RUNS -I $SAMPLING_INTERVAL -e L1-dcache-load-misses,mem_load_uops_retired.l1_miss,mem_load_uops_retired.l2_miss,mem_load_uops_retired.l3_miss,Instructions,uops_executed.core,bus-cycles,resource_stalls.any,branch-misses,fp_arith_inst_retired.scalar_double,fp_arith_inst_retired.scalar_single -a ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $DIR/$LOG"."container.stat" >> $DIR/$LOG"."container.stat""
			#			COMMAND="perf stat -r $RUNS -e other_assists.avx_to_sse,other_assists.sse_to_avx,L1-dcache-load-misses,mem_load_uops_retired.l1_miss,mem_load_uops_retired.l2_miss,mem_load_uops_retired.l3_miss,Instructions,uops_executed.core,bus-cycles,resource_stalls.any,branch-misses,fp_arith_inst_retired.scalar_double,fp_arith_inst_retired.scalar_single,fp_assist.any -a ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $DIR/$LOG"."container.stat" >> $DIR/$LOG"."container.stat""
						#COMMAND="perf stat -x',' -a -I $SAMPLING_INTERVAL -e \"$EVENT_LIST\" ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $DIR/$LOG"."container.stat" >> $DIR/$LOG"."container.stat""
						#COMMAND="perf stat -x',' -a -I $SAMPLING_INTERVAL -e \"$EVENT_LIST\" ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME 2>/dev/null >> $DIR/$LOG"."container.stat 2>&1"
						#COMMAND="perf stat -x',' -a -I $SAMPLING_INTERVAL -e \"$EVENT_LIST\" ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME 2>/dev/null 2>&1 | tee -a $DIR/$LOG"."container.stat > /dev/null"
						#COMMAND="{ { perf stat --log-fd 1 -x',' -a -I $SAMPLING_INTERVAL -e \"$EVENT_LIST\" ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME ; } > >(tee -a $DIR/$LOG"."container.stat > /dev/null); } 2> >(tee -a $DIR/$LOG"."container.stat > /dev/null)"
						#COMMAND="{ { perf stat --log-fd 1 -x',' -a -I $SAMPLING_INTERVAL -e \"$EVENT_LIST\" ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME ; } >> $DIR/$LOG"."container.stat; } 2>> $DIR/$LOG"."container.stat"
						#COMMAND="{ { perf stat --log-fd 1 -x',' -a -I $SAMPLING_INTERVAL -e \"$EVENT_LIST\" ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME 2>&1; } } | cat >> $DIR/$LOG"."container.stat"
						#COMMAND="{ { perf stat --log-fd 1 -x',' -a -I $SAMPLING_INTERVAL -e \"$EVENT_LIST\" ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME ; } &> >(cat >>$DIR/$LOG"."container.stat); }"

	#xargs -n1 -P$(nproc) myprogram < inputs.txt | cat > outputs.csv

			#			COMMAND="{ { perf stat --log-fd 1 -x',' -a -I $SAMPLING_INTERVAL -e \"$EVENT_LIST\" ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME ; } > >(ts '[%Y-%m-%d_%H:%M:%S.%.S]' >>$DIR/$LOG"."perfts.container.stat); } 2> >(ts '[%Y-%m-%d_%H:%M:%S.%.S]' >>$DIR/$LOG"."applts.container.stat)"
						COMMAND="{ { perf stat --log-fd 1 -x',' -a -I $SAMPLING_INTERVAL $EVENT_LIST --cgroup=$PERF_EVENT_CONTAINERCGROUP ./kvazaar_container_ultrafast.sh $i $i.container.hevc $THREADSRAW $CPUSET $CONTAINER_NAME $PRESET; } > >(ts '[%.s]' >>$DIR/$LOG"."$PRESET"."perfts.container.stat); } 2> >(ts '[%.s]' >>$DIR/$LOG"."$PRESET"."applts.container.stat)"

	#					{ { echo stdout; echo stderr >&2; } > >(tee stdout.txt ); } \
	#                                   2> >(tee stderr.txt )

						echo $COMMAND | grep --color " $CPUSET "
						eval $COMMAND
						echo
					done

					./merge_pmu.sh $DIR/$LOG"."$PRESET"."applts.container.stat $DIR/$LOG"."$PRESET"."perfts.container.stat >> $DIR/$LOG"."$PRESET"."container.stat 2>>$DIR/$LOG"."$PRESET"."container.mergedebug
					cat $DIR/$LOG"."$PRESET"."applts.container.stat $DIR/$LOG"."$PRESET"."perfts.container.stat | sort >> $DIR/$LOG"."$PRESET"."container.merged
					rm -f $DIR/$LOG"."$PRESET"."applts.container.stat $DIR/$LOG"."$PRESET"."perfts.container.stat

					echo -e "\n**********************************************************************************************************************\n"


					[ -f $DIR/$LOG"."native.stat ] && echo $DIR/$LOG"."native.stat" && tail -n 27 $DIR/$LOG"."native.stat" && \
						echo -e "\n######################################################################################################################\n"

					[ -f $DIR/$LOG"."native.cgroup.stat ] && echo $DIR/$LOG"."native.cgroup.stat" && tail -n 27 $DIR/$LOG"."native.cgroup.stat" && \
						echo -e "\n######################################################################################################################\n"

					[ -f $DIR/$LOG"."$PRESET"."container.stat ] && echo $DIR/$LOG"."$PRESET"."container.stat && tail -n 27 $DIR/$LOG"."$PRESET"."container.stat && \
						echo -e "\n######################################################################################################################\n"

					sleep 2
				done

				if [ $SHOW_TOPOLOGY -eq 1 ]; then
					kill -9 $LSTOPO_PID1 2>/dev/null > /dev/null
					wait $LSTOPO_PID1 2>/dev/null
					kill -9 $LSTOPO_PID2 2>/dev/null > /dev/null
					wait $LSTOPO_PID2 2>/dev/null
				fi
			done

			echo -e "\n######################################################################################################################\n"

		done
	done
done

date >>  $DIR/$LOGGENERAL.config
exit 0
