#!/bin/bash
N_PROC=`grep -c processor /proc/cpuinfo`
N_FILES=`ls -1 "$@" | wc -l`
R_PROCSFILE=`expr $N_PROC / $N_FILES`
R_PROCSFILE=32
DATE=`date '+%Y%m%d_%H%M%S'`
LOG="$DATE"_"$R_PROCSFILE"."time"

echo N_PROC: $N_PROC 
echo N_FILE: $N_FILES 
echo R_PROCSFILE: $R_PROCSFILE
echo 

#perf stat -r 10 -B sleep 1

CPUBEGIN=0
#TIMEFORMAT="%e %P"
TIMEFORMAT="%R"

touch $LOG

for i in "$@";
do
	rm -f  $i.hevc;
done

for i in "$@"; 
do
	CPUSET="$CPUBEGIN-$(($CPUBEGIN + $R_PROCSFILE - 1))"

	filename=$(basename -- "$i")

#	TIME="$( time ( ./kvazaarc.sh $i $i.hevc $CPUSET 2>/dev/null 1>&2 ) 2>&1 )"
	( time ( ./kvazaar_container.sh $i $i.hevc $CPUSET 2>/dev/null 1>&2 ) 2>$LOG"_"$filename )&
#	TIME=$( time (wget http://www.example.com 2>/dev/null 1>&2)  2>&1 )

#	echo  "$TIME ./kvazaarc.sh $i $i.hevc $CPUSET" >> $LOG

#	echo -e "\n\n" >> $LOG

#	CPUBEGIN="$(($CPUBEGIN + $R_PROCSFILE))"

done

cat $LOG


