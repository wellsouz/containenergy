#!/bin/bash

INPUT=$1
OUTPUT=$2
FILENAME=$(basename -- "$INPUT")

#INPUTRES="--input-res=640x480"
INPUTRES="--input-res=$(echo $FILENAME|sed -n 's/[^_]*.*_\([0-9]*x[0-9]*\).*/\1/p')"
KVAZAAR_PARAMETERS=""

[[ "_$3" != "_" ]] && THREADS="$3" || THREADS="$(grep processor -c /proc/cpuinfo)"

KVAZAAR=/mnt/video-files/kvazaar_$(hostname -s)/kvazaar/src/kvazaar

echo RES: $INPUTRES
echo IN: $INPUT
echo OUT: $OUTPUT
echo THREADS: $THREADS
echo
echo

COMMAND="$KVAZAAR --threads $THREADS $INPUTRES $KVAZAAR_PARAMETERS -i - -o - < $INPUT > $OUTPUT"
echo $COMMAND
eval $COMMAND
