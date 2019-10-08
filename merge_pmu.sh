#!/bin/bash

# Script to merge contents of timestamped (lines prefixed with [sssss.sssss] by 'ts') .stat files.
# The first argument is the application .stat file. The second argument is the Perf .stat file.
# The output is the content of both files interleaved line by line according to timestamp.
# Perf lines are grouped if their timestamp difference is under 50 ms, postponing application
# lines of the next sampling period that were generated before the end of Perf printing.
# The output is directed to stdout and can be saved with redirection ( > outputfile.stat)

#export LC_ALL=C.UTF-8
export LC_ALL=en_US.UTF-8
export GDM_LANG=en_US
export LANGUAGE=en_US:en

atotal=$(wc -l < $1)
ptotal=$(wc -l < $2)

OIFS="$IFS"
IFS=$'\n'

a=1
p=1
a_old=0
p_old=0
atime=0
ptime=0
atime_old=0
ptime_old=0
aline=0
atime=0
atext=0
pline=0
ptime=0
ptext=0
appllock=0
perflock=0

until (( $a > $atotal && $p > $ptotal )); do

	# Get appl line only if it isn't EOF and not previously fetched
	if (( $a <= $atotal && $a != $a_old )); then
		aline=$(sed -r "${a}q;d" $1)
		atime=$(echo $aline | sed -r 's/^\[([0-9]+\.[0-9]+)\]\ (.*)/\1/')
		atext=$(echo $aline | sed -r 's/^\[([0-9]+\.[0-9]+)\]\ (.*)/\2/')
	fi

	# Get perf line only if it isn't EOF and not previously fetched
	if (( $p <= $ptotal && $p != $p_old )); then
		pline=$(sed -r "${p}q;d" $2)
		ptime=$(echo $pline | sed -r 's/^\[([0-9]+\.[0-9]+)\]\ (.*)/\1/')
		ptext=$(echo $pline | sed -r 's/^\[([0-9]+\.[0-9]+)\]\ (.*)/\2/')
	fi
	
	# Activate a flag to group perf events within a difftime limit
	if (( $(echo "($ptime - $ptime_old) > 0.005" | bc -l) )); then
		perflock=0
	fi

	# Activate a flag to print appl lines if they were generated before perf lines
	# or if all perf lines were already printed
	if (( $(echo "$atime <= $ptime" | bc -l) || $p > $ptotal )); then
		appllock=1
	else
		appllock=0
	fi
	
	# Print appl lines if it isn't EOF and flags are set accordly
	if (( $a <= $atotal && $appllock == 1 && $perflock == 0 )); then
		echo $atext
		a_old=$a
		a=$(($a+1))

	
	# Print perf lines if it isn't EOF and flags are set accordly
	elif (( $p <= $ptotal )); then
		if (( $perflock == 1 && $appllock == 1 && $a < $atotal )); then
			echo -e "\nLine postponed (a:$a) by (b:$p):\nxxx>(a)$aline\n<xxx(b)$pline\n" >&2
		fi
		echo $ptext
		perflock=1
		p_old=$p
		p=$(($p+1))
	else
		perflock=0
	fi
	
	# Update timestamps for next comparison
	atime_old=$atime
	ptime_old=$ptime
done
