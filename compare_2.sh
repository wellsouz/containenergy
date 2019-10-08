#!/bin/bash
clear;

counter=0;

for i in "$@";do 
	
	echo $i

	sumTotalCpuTime=0
	sumEncodingTime=0
	sumEncodingWallTime=0
	sumEncodingCpuUsage=0
	sumFps=0
	countTotalCpuTime=0
	countEncodingTime=0
	countEncodingWallTime=0
	countEncodingCpuUsage=0
	countFps=0
	minTotalCpuTime=0
	minEncodingTime=0
	minEncodingWallTime=0
	minEncodingCpuUsage=0
	minFps=0
	maxTotalCpuTime=0
	maxEncodingTime=0
	maxEncodingWallTime=0
	maxEncodingCpuUsage=0
	maxFps=0
	d2TotalCpuTime=0
	d2EncodingTime=0
	d2EncodingWallTime=0
	d2EncodingCpuUsage=0
	d2Fps=0

	
	OIFS="$IFS"
	
	stats="$(grep -e "Total CPU time" -e "Encoding time" -e "Encoding wall time" -e "Encoding CPU usage" -e "FPS" $i)"
	
	IFS=$'\n'

	for j in $stats;
#	for j in `grep -e "Total CPU time" -e "Encoding time" -e "Encoding wall time" -e "Encoding CPU usage" -e "FPS" $i`;
	do
		keys=$(echo $j|sed -e 's/^[ \t]*\(.*\):.*/\1/')
		value=$(echo $j|sed -e 's/[^0-9. ]//g' -e 's/ \+/ /g' -e 's/ .$//g'| tr -s ' '| tr -d '[:blank:]')
		key=""
		case $keys in
			"Total CPU time")
				key="TotalCpuTime"
#				if [[ $countTotalCpuTime -eq 0 ]]; then minTotalCpuTime=$value;maxTotalCpuTime=$value; fi
#				if (( $(echo "$value > $maxTotalCpuTime" | bc -l) )); then maxTotalCpuTime=$value; fi
#				if (( $(echo "$value < $minTotalCpuTime" | bc -l) )); then minTotalCpuTime=$value; fi
#				sumTotalCpuTime=$(echo "$sumTotalCpuTime+$value"|bc)
#				countTotalCpuTime=$(echo "$countTotalCpuTime + 1"|bc)
				;;
			"Encoding time")
				key="EncodingTime"
#				sumEncodingTime=$(echo "$sumEncodingTime+$value"|bc)
#				countEncodingTime=$(echo "$countEncodingTime+1"|bc)
				;;
			"Encoding wall time")
				key="EncodingWallTime"
#				sumEncodingWallTime=$(echo "$sumEncodingWallTime+$value"|bc)
#				countEncodingWallTime=$(echo "$countEncodingWallTime+1"|bc)
				;;
			"Encoding CPU usage")
				key="EncodingCpuUsage"
#				sumEncodingCpuUsage=$(echo "$sumEncodingCpuUsage+$value"|bc)
#				countEncodingCpuUsage=$(echo "$countEncodingCpuUsage+1"|bc)
				;;
			"FPS")
				key="Fps"
#				sumFps=$(echo "$sumFps+$value"|bc -l)
#				countFps=$(echo "$countFps+1"|bc)
				;;
		esac
	
		COMMAND="if [[ \$count$key -eq 0 ]]; then min$key=\$value;max$key=\$value; fi"
#		echo $COMMAND
		eval $COMMAND
		COMMAND="if (( \$(echo \"scale=10;\$value > \$max$key\" | bc -l) )); then max$key=\$value; fi"
#		echo $COMMAND
		eval $COMMAND
		COMMAND="if (( \$(echo \"scale=10;$value < \$min$key\" | bc -l) )); then min$key=$value; fi"
#		echo $COMMAND
		eval $COMMAND
		COMMAND="sum$key=\$(echo \"scale=10;\$sum$key+\$value\"|bc)"
#		echo $COMMAND
		eval $COMMAND
		COMMAND="count$key=\$(echo \"scale=10;\$count$key + 1\"|bc)"
#		echo $COMMAND
		eval $COMMAND
	done

	meanTotalCpuTime=$(echo "scale=10;$sumTotalCpuTime/$countTotalCpuTime"|bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//')
	meanEncodingTime=$(echo "scale=10;$sumEncodingTime/$countEncodingTime"|bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//')
	meanEncodingWallTime=$(echo "scale=10;$sumEncodingWallTime/$countEncodingWallTime"|bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//')
	meanEncodingCpuUsage=$(echo "scale=10;$sumEncodingCpuUsage/$countEncodingCpuUsage"|bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//')
	meanFps=$(echo "scale=10;$sumFps/$countFps"|bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//')

	for k in $stats;
	do
		keys=$(echo $k|sed -e 's/^[ \t]*\(.*\):.*/\1/')
		value=$(echo $k|sed -e 's/[^0-9. ]//g' -e 's/ \+/ /g' -e 's/ .$//g'| tr -s ' '| tr -d '[:blank:]')
		key=""
		case $keys in
			"Total CPU time")
				key="TotalCpuTime"
				;;
			"Encoding time")
				key="EncodingTime"
				;;
			"Encoding wall time")
				key="EncodingWallTime"
				;;
			"Encoding CPU usage")
				key="EncodingCpuUsage"
				;;
			"FPS")
				key="Fps"
				;;
		esac
	
		COMMAND="d2$key=\$(echo \"scale=10;\$d2$key + (($value - \$mean$key) ^ 2)\" |bc)"
		#echo $COMMAND
		eval $COMMAND

	done

	IFS="$OIFS"

	stddevTotalCpuTime=$(echo "scale=10;$d2TotalCpuTime / ($countFps - 1)"|bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//')
	stddevEncodingTime=$(echo "scale=10;sqrt($d2EncodingTime / ($countFps - 1))"|bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//')
	stddevEncodingWallTime=$(echo "scale=10;sqrt($d2EncodingWallTime / ($countFps - 1))"|bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//')
	stddevEncodingCpuUsage=$(echo "scale=10;sqrt($d2EncodingCpuUsage / ($countFps - 1))"|bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//')
	stddevFps=$(echo "scale=10;sqrt($d2Fps / ($countFps - 1))"|bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//')

	stddevTotalCpuTimePercentil=$(echo "scale=2;($stddevTotalCpuTime * 100) / $meanTotalCpuTime"| bc -l)
	stddevEncodingTimePercentil=$(echo "scale=2;($stddevEncodingTime * 100) / $meanEncodingTime"| bc -l)
	stddevEncodingWallTimePercentil=$(echo "scale=2;($stddevEncodingWallTime * 100) / $meanEncodingWallTime"| bc -l)
	stddevEncodingCpuUsagePercentil=$(echo "scale=2;($stddevEncodingCpuUsage * 100) / $meanEncodingCpuUsage"| bc -l)
	stddevFpsPercentil=$(echo "scale=2;($stddevFps * 100) / $meanFps"| bc -l)

	#echo Sum/Count Total CPU time: $sumTotalCpuTime $countTotalCpuTime
	#echo Sum/Count Encoding time: $sumEncodingTime $countEncodingTime
	#echo Sum/Count Encoding wall time: $sumEncodingWallTime $countEncodingWallTime
	#echo Sum/Count Encoding CPU usage: $sumEncodingCpuUsage $countEncodingCpuUsage
	#echo Sum/Count FPS $sumFps $countFps

	#grep -e "time elapsed" $i | sed -e 's/[^0-9, ]//g' -e 's/ \+/ /g' -e 's/ ,$/ /g'| tr -s ' '| tr -d '[:blank:]'

	perfTimeElapsedResults=$(grep -e "time elapsed" $i | sed -e 's/^[ ]*//g' -e 's/[^0-9,\|. ]//g' -e 's/,/./g' | tr -s ' ')
	perfTimeElapsed=$(echo $perfTimeElapsedResults | sed 's/ .*//')
	perfTimeElapsedStdDev=$(echo $perfTimeElapsedResults | sed 's/.* //g')
	setupTime=$(echo "scale=10;$perfTimeElapsed - $meanEncodingWallTime" |bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//')


	echo -e "\nLast run (Kvazaar output):"
	#tail -n 20 $i|sed 8,21d
	tail -n 21 $i


	echo Statistics "($countFps runs)":
	echo " Total CPU Time: "$meanTotalCpuTime s. \( +- $stddevTotalCpuTimePercentil % \)  \( min=$minTotalCpuTime s.\; max=$maxTotalCpuTime s. \)
	echo " Encoding Time: "$meanEncodingTime s. \( +- $stddevEncodingTimePercentil % \)  \( min=$minEncodingTime s.\; max=$maxEncodingTime s. \)
	echo " Encoding wall time: "$meanEncodingWallTime s. \( +- $stddevEncodingWallTimePercentil % \) \( min=$minEncodingWallTime s.\; max=$maxEncodingWallTime s. \)
	echo " Encoding CPU usage: "$meanEncodingCpuUsage % \( +- $stddevEncodingCpuUsagePercentil % \)  \( min=$minEncodingCpuUsage %\; max=$maxEncodingCpuUsage % \)
	echo " FPS: "$meanFps \( +- $stddevFpsPercentil % \)  \( min=$minFps\; max=$maxFps \)
	echo " Time elapsed (perf): " $perfTimeElapsed \( +- $perfTimeElapsedStdDev \)
	echo " Setup time: " $setupTime
	
	counter=$(( (counter+1) % 2))
	if [[ "$counter" -eq 1 ]]; then
		echo -e "\n********************************************************************************************************\n"
	else
		echo -e "\n\n########################################################################################################\n"
		#read;
		#clear;
	fi
done

