#!/bin/bash

INPUT=$1
OUTPUT=$2
FILENAME=$(basename -- "$INPUT")

#INPUTRES="--input-res=640x480"
INPUTRES="--input-res=$(echo $FILENAME|sed -n 's/[^_]*.*_\([0-9]*x[0-9]*\).*/\1/p')"
KVAZAAR_PARAMETERS=""

[[ "_$3" != "_" ]] && THREADS="$3" || THREADS="$(grep processor -c /proc/cpuinfo)"
[[ "_$4" != "_" ]] && CPUSET="$4" || CPUSET="0-$((`grep processor -c /proc/cpuinfo` - 1))"
[[ "_$5" != "_" ]] && CONTAINER_NAME="$5" || CONTAINER_NAME="kvazaar_$FILENAME"

echo RES: $INPUTRES
echo IN: $INPUT
echo OUT: $OUTPUT
echo THREADS: $THREADS
echo CPUSET: $CPUSET
echo

COMMAND="docker run --cgroup-parent=dockerkvazaaresl.slice --name $CONTAINER_NAME --cpuset-cpus=$CPUSET -i -a STDIN -a STDOUT -a STDERR kvazaar --threads $THREADS $INPUTRES $KVAZAAR_PARAMETERS -i - -o - < $INPUT > $OUTPUT"
echo $COMMAND
eval $COMMAND

docker rm -f $CONTAINER_NAME >> /dev/null
