#!/bin/bash
N_PROC=`grep -c processor /proc/cpuinfo`
N_FILES=`ls -1 "$@" | wc -l`
DATE=`date '+%Y%m%d_%H%M%S'`
RUNS=100
HOSTNAME=`hostname -s`

THREADS="$(grep processor -c /proc/cpuinfo)"
CPUSET="0-$((`grep processor -c /proc/cpuinfo` - 1))"

LOG=perfstat"_"$DATE"_"$HOSTNAME"_"$THREADS"_"$RUNS


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
	FILENAME=$(basename -- "$i")
	CONTAINER_NAME="kvazaar_$FILENAME"
	
	rm -f $LOG"_"$FILENAME".native.stat"
	rm -f $LOG"_"$FILENAME".container.stat"

	COMMAND="perf stat -r $RUNS -B ./kvazaar_native.sh    $i $i.hevc $THREADS                         2>/dev/null 2>> $LOG"_"$FILENAME".native.stat"    >> $LOG"_"$FILENAME".native.stat""
	echo $COMMAND
	eval $COMMAND

	COMMAND="perf stat -r $RUNS -B ./kvazaar_container.sh $i $i.hevc $THREADS $CPUSET $CONTAINER_NAME 2>/dev/null 2>> $LOG"_"$FILENAME".container.stat" >> $LOG"_"$FILENAME".container.stat""
	echo $COMMAND
	eval $COMMAND 
done


