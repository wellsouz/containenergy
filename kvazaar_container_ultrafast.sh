#!/bin/bash

INPUT=$1
OUTPUT=$2
FILENAME=$(basename -- "$INPUT")

#INPUTRES="--input-res=640x480"
INPUTRES="--input-res=$(echo $FILENAME|sed -n 's/[^_]*.*_\([0-9]*x[0-9]*\).*/\1/p')"
KVAZAAR_PARAMETERS=""
PERF_EVENT_CONTAINERCGROUP="kvazaar_container.slice"

[[ "_$3" != "_" ]] && THREADS="$3" || THREADS="$(grep processor -c /proc/cpuinfo)"
[[ "_$4" != "_" ]] && CPUSET="$4" || CPUSET="0-$((`grep processor -c /proc/cpuinfo` - 1))"
[[ "_$5" != "_" ]] && CONTAINER_NAME="$5" || CONTAINER_NAME="kvazaar_$FILENAME"
[[ "_$6" != "_" ]] && KVAZAAR_PARAMETERS="--preset $6" || KVAZAAR_PARAMETERS=="--preset ultrafast"

echo 
echo RES: $INPUTRES
echo IN: $INPUT
echo OUT: $OUTPUT
echo THREADS: $THREADS
echo CPUSET: $CPUSET
echo KVAZAAR_PARAMETERS: $KVAZAAR_PARAMETERS

#COMMAND="docker run --cap-add=sys_nice --cgroup-parent=$PERF_EVENT_CONTAINERCGROUP --name $CONTAINER_NAME --cpuset-cpus=$CPUSET -i -a STDIN -a STDOUT -a STDERR kvazaar --preset ultrafast --threads $THREADS $INPUTRES $KVAZAAR_PARAMETERS -i - -o - < $INPUT > $OUTPUT"
COMMAND="docker run --log-driver none --cgroup-parent=$PERF_EVENT_CONTAINERCGROUP --name $CONTAINER_NAME --cpuset-cpus=$CPUSET -i -a STDIN -a STDOUT -a STDERR kvazaar --threads $THREADS $INPUTRES $KVAZAAR_PARAMETERS -i - -o - < $INPUT > $OUTPUT"
echo $COMMAND
eval $COMMAND

docker rm -f $CONTAINER_NAME >> /dev/null
