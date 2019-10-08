#!/bin/bash
for j in _resourc _branch _l2 _mem; do
	unset A
	declare -A A
	counter=0
	counter_files=0
	for i in *"$j"*.csv; do
		counter_files=$(( $counter_files + 1 ))
		#echo $i
		header2="$(head -n 1 $i)"
		new=1
		for r in "${A[@]}"; do
			#echo $r
			#echo $header2
			if [ "$r" = "$header2" ]; then
				new=0
				break
			fi
		done
		if [ "$new" = "1" ]; then
			A[$counter]="$header2"
			echo novo
			counter=$(( $counter + 1 ))
		fi
	done
	echo files: $counter_files
	echo $j: $counter
	for r in "${A[@]}"; do
		echo "<>" $r "<>"
		echo
	done
	echo; echo; echo
done
	
