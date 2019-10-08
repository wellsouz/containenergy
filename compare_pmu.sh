#!/bin/bash
#export LC_ALL=C.UTF-8
export LC_ALL=en_US.UTF-8
export GDM_LANG=en_US
export LANGUAGE=en_US:en


#Flags
DEBUG=0
PRINT_TXT_POC_LINE_COUNTING=0
PRINT_CSV_SAMPLED_POC=0
PRINT_CSV_TOTAL_SAMPLED_POC=0
PRINT_CSV_PERF_INPUT_LINES=0
PRINT_CSV_INTRA_SAMPLING_STATISTICS=0
PRINT_CSV_INTER_SAMPLING_STATISTICS=1
PRINT_CSV_KVAZAAR_PER_RUN_STATISTICS=0
PRINT_CSV_KVAZAAR_ALL_RUN_STATISTICS=0


# Global variables
sampling_counter=0
max_sampling_counter=0
run_counter=0

declare -A matrix
declare -A matrix_inter
declare -A events_array

fullfilename=""
prefix=""
file=""
freq=""
cores=""
sufix=""

# Function to print statistics related to analysis of an event in different executions, but in the same order
# (event x on the same instant y of each execution). Output in in human readable (commented out) and CSV.
# It iterates through the associative matrix of parsed events, calculating the statistics and printing at end.
function printInterSamplingStatistics() {
	for r in "${matrix_inter[@]}"; do
		if [[ $r =~ .*event@.* ]]; then
			e_inter=$(echo $r | cut -f 2 -d '@')
			s_inter=$(echo $r | cut -f 3 -d '@')
			n_inter=$(echo $r | cut -f 5 -d '@')

			#n_inter="${matrix_inter[$e_inter@$s_inter,n]}"
			[ $DEBUG -eq 1 ] && echo r:$r e_inter:$e_inter s_inter:$s_inter r_inter:$r_inter n_inter:$n_inter >&2
			if [ $n_inter -gt 0 ]; then
				COMMAND="matrix_inter[$e_inter@$s_inter,mean]=\$(printf %0.9f \$(echo \"scale=10;\"\${matrix_inter[$e_inter@$s_inter,sum]}\"/\$n_inter\"|bc))"
				#echo $COMMAND
				eval $COMMAND

				COMMAND="matrix_inter[$e_inter@$s_inter\"_poc\",mean]=\$(printf %0.9f \$(echo \"scale=10;\"\${matrix_inter[$e_inter@$s_inter\"_poc\",sum]}\"/\$n_inter\"|bc))"
				#echo $COMMAND
				eval $COMMAND
			fi

			# Standard Deviation (std)
			# std - 1) Sum of the squared differences in relation to the mean
			for ((s=1; s<=$n_inter; s++)); do
			#for ((s=1; s<=$run_counter; s++)); do
				[ $DEBUG -eq 1 ] && echo s:$s d2:"${matrix_inter[$e_inter@$s_inter,d2]}" mean:"${matrix_inter[$e_inter@$s_inter,mean]}" value:"${matrix_inter[$e_inter@$s_inter,$s]}" >&2
				COMMAND="matrix_inter[$e_inter@$s_inter,d2]=\$(printf %0.9f \$(echo \"scale=10;\"\${matrix_inter[$e_inter@$s_inter,d2]}\" + ((\"\${matrix_inter[$e_inter@$s_inter,$s]}\" - \"\${matrix_inter[$e_inter@$s_inter,mean]}\") ^ 2)\" |bc))"
				#echo $COMMAND
				eval $COMMAND

				COMMAND="matrix_inter[$e_inter@$s_inter\"_poc\",d2]=\$(printf %0.9f \$(echo \"scale=10;\"\${matrix_inter[$e_inter@$s_inter\"_poc\",d2]}\" + ((\"\${matrix_inter[$e_inter@$s_inter\"_poc\",$s]}\" - \"\${matrix_inter[$e_inter@$s_inter\"_poc\",mean]}\") ^ 2)\" |bc))"
				#echo $COMMAND
				eval $COMMAND
			done

			# std - 2) Final result of Standard Deviation (absolute)
			COMMAND="if (( \$(echo \"scale=10;\"\${matrix_inter[$e_inter@$s_inter,d2]}\" > 0\" | bc -l) )); then matrix_inter[$e_inter@$s_inter,std]=\$(printf %0.9f \$(echo \"scale=10;sqrt(\"\${matrix_inter[$e_inter@$s_inter,d2]}\" / ($n_inter - 1))\"|bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//'));fi"
			#echo $COMMAND
			eval $COMMAND

			COMMAND="if (( \$(echo \"scale=10;\"\${matrix_inter[$e_inter@$s_inter\"_poc\",d2]}\" > 0\" | bc -l) )); then matrix_inter[$e_inter@$s_inter\"_poc\",std]=\$(printf %0.9f \$(echo \"scale=10;sqrt(\"\${matrix_inter[$e_inter@$s_inter\"_poc\",d2]}\" / ($n_inter - 1))\"|bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//'));fi"
			#echo $COMMAND
			eval $COMMAND


			# std - 3) Final result of Standard Deviation (percentual - more useful)
			COMMAND="if (( \$(echo \"scale=10;\"\${matrix_inter[$e_inter@$s_inter,mean]}\" != 0\" | bc -l) )); then matrix_inter[$e_inter@$s_inter,stdpct]=\$(printf %0.2f \$(echo \"scale=10;(\"\${matrix_inter[$e_inter@$s_inter,std]}\" * 100 / \"\${matrix_inter[$e_inter@$s_inter,mean]}\")\"|bc -l));fi"
			#echo $COMMAND
			eval $COMMAND

			COMMAND="if (( \$(echo \"scale=10;\"\${matrix_inter[$e_inter@$s_inter\"_poc\",mean]}\" != 0\" | bc -l) )); then matrix_inter[$e_inter@$s_inter\"_poc\",stdpct]=\$(printf %0.2f \$(echo \"scale=10;(\"\${matrix_inter[$e_inter@$s_inter\"_poc\",std]}\" * 100 / \"\${matrix_inter[$e_inter@$s_inter\"_poc\",mean]}\")\"|bc -l));fi"
			#echo $COMMAND
			eval $COMMAND


			#Human readable output
			if [ $DEBUG -eq 1 ]; then
				echo "$e""[name]" -- "${matrix_inter[$e_inter@$s_inter,name]}"     >&2
				echo "$e""[time]" -- "${matrix_inter[$e_inter@$s_inter,time]}"     >&2
				echo "$e""[poc]" -- "${matrix_inter[$e_inter@$s_inter,poc]}"       >&2
				echo "$e""[max]" -- "${matrix_inter[$e_inter@$s_inter,max]}"       >&2
				echo "$e""[min]" -- "${matrix_inter[$e_inter@$s_inter,min]}"       >&2
				echo "$e""[sum]" -- "${matrix_inter[$e_inter@$s_inter,sum]}"       >&2
				echo "$e""[mean]" -- "${matrix_inter[$e_inter@$s_inter,mean]}"     >&2
				echo "$e""[d2]" -- "${matrix_inter[$e_inter@$s_inter,d2]}"         >&2
				echo "$e""[std]" -- "${matrix_inter[$e_inter@$s_inter,std]}"       >&2
				echo "$e""[stdpct]" -- "${matrix_inter[$e_inter@$s_inter,stdpct]}" >&2
			fi
		fi
	done

	for e in "${events_array[@]}"; do
		for (( s=1; s<=$max_sampling_counter; s++ )); do
			for r in "${matrix_inter[@]}"; do
				if [[ $r =~ .*event@$e@$s@.* ]]; then
					e_inter=$(echo $r | cut -f 2 -d '@')
					s_inter=$(echo $r | cut -f 3 -d '@')
					r_inter=$(echo $r | cut -f 4 -d '@')
					n_inter="${matrix_inter[$e_inter@$s_inter,n]}"

					#Print inter sampling statistics - perf CSV style - if enabled
					if [ $PRINT_CSV_INTER_SAMPLING_STATISTICS -eq 1 ]; then
						[ $DEBUG -eq 1 ] && echo -e "\nInter-sampling statistics" >&2
						#echo "${matrix_inter[$e_inter@$s_inter,time]}","${matrix_inter[$e_inter@$s_inter,mean]}",_,"${matrix_inter[$e_inter@$s_inter,name]}",_,_,"${matrix_inter[$e_inter@$s_inter,stdpct]}","${matrix_inter[$e_inter@$s_inter,min]}","${matrix_inter[$e_inter@$s_inter,max]}","${matrix_inter[$e_inter@$s_inter,poc]}","${matrix_inter[$e_inter@$s_inter"_poc",mean]}","${matrix_inter[$e_inter@$s_inter"_poc",stdpct]}","${matrix_inter[$e_inter@$s_inter"_poc",min]}","${matrix_inter[$e_inter@$s_inter"_poc",max]}"
						echo $file,$freq,$cores,"${matrix_inter[$e_inter@$s_inter,time]}","${matrix_inter[$e_inter@$s_inter,name]}","${matrix_inter[$e_inter@$s_inter,mean]}","${matrix_inter[$e_inter@$s_inter,stdpct]}","${matrix_inter[$e_inter@$s_inter,min]}","${matrix_inter[$e_inter@$s_inter,max]}","${matrix_inter[$e_inter@$s_inter"_poc",mean]}","${matrix_inter[$e_inter@$s_inter"_poc",stdpct]}","${matrix_inter[$e_inter@$s_inter"_poc",min]}","${matrix_inter[$e_inter@$s_inter"_poc",max]}"
					fi
				fi
			done
		done
	done
}
			
			


# Function to print statistics related to one sampling period. Output in in human readable (commented out) and CSV.
# It iterates through the associative matrix of parsed events, calculating the statistics and printing at end.
function printIntraSamplingStatistics() {
	for r in "${matrix[@]}"; do
		if [[ $r =~ .*event@.* ]]; then
			e_intra=$(echo $r | cut -f 2 -d '@')
			s_intra=$(echo $r | cut -f 3 -d '@')
			n_intra=$(echo $r | cut -f 4 -d '@')
			if [ $n_intra -gt 0 ]; then
				COMMAND="matrix[$e_intra,mean]=\$(printf %0.9f \$(echo \"scale=10;\"\${matrix[$e_intra,sum]}\"/\$n_intra\"|bc))"
				#echo $COMMAND
				eval $COMMAND
			fi
			
			# Standard Deviation (std)
			# std - 1) Sum of the squared differences in relation to the mean
			for ((s=1; s<=$n_intra; s++)); do
				#echo "$e""[$s]" -- "${matrix[$e,$s]}"
				COMMAND="matrix[$e_intra,d2]=\$(printf %0.9f \$(echo \"scale=10;\"\${matrix[$e_intra,d2]}\" + ((\"\${matrix[$e_intra,$s]}\" - \"\${matrix[$e_intra,mean]}\") ^ 2)\" |bc))"
				#echo $COMMAND
				eval $COMMAND
			done

			# std - 2) Final result of Standard Deviation (absolute)
			COMMAND="if (( \$(echo \"scale=10;\"\${matrix[$e_intra,d2]}\" > 0\" | bc -l) )); then matrix[$e_intra,std]=\$(printf %0.9f \$(echo \"scale=10;sqrt(\"\${matrix[$e_intra,d2]}\" / ($n_intra - 1))\"|bc -l|sed '/\./ s/\.\{0,1\}0\{1,\}$//'));fi"
			#echo $COMMAND
			eval $COMMAND

			# std - 3) Final result of Standard Deviation (percentual - more useful)
			COMMAND="if (( \$(echo \"scale=10;\"\${matrix[$e_intra,mean]}\" != 0\" | bc -l) )); then matrix[$e_intra,stdpct]=\$(printf %0.2f \$(echo \"scale=10;(\"\${matrix[$e_intra,std]}\" * 100 / \"${matrix[$e_intra,mean]}\")\"|bc -l));fi"
			#echo $COMMAND
			eval $COMMAND

			#Human readable output
			if [ $DEBUG -eq 1 ]; then
				echo "$e_intra""[name]" -- "${matrix[$e_intra,name]}"     >&2
				echo "$e_intra""[time]" -- "${matrix[$e_intra,time]}"     >&2
				echo "$e_intra""[poc]" -- "${matrix[$e_intra,poc]}"       >&2
				echo "$e_intra""[max]" -- "${matrix[$e_intra,max]}"       >&2
				echo "$e_intra""[min]" -- "${matrix[$e_intra,min]}"       >&2
				echo "$e_intra""[sum]" -- "${matrix[$e_intra,sum]}"       >&2
				echo "$e_intra""[mean]" -- "${matrix[$e_intra,mean]}"     >&2
				echo "$e_intra""[d2]" -- "${matrix[$e_intra,d2]}"         >&2
				echo "$e_intra""[std]" -- "${matrix[$e_intra,std]}"       >&2
				echo "$e_intra""[stdpct]" -- "${matrix[$e_intra,stdpct]}" >&2
			fi

			#Print intra sampling statistics - perf CSV style - if enabled
			if [ $PRINT_CSV_INTRA_SAMPLING_STATISTICS -eq 1 ]; then
				[ $DEBUG -eq 1 ] && echo -e "\nIntra-sampling statistics" >&2
				echo "${matrix[$e_intra,time]}","${matrix[$e_intra,mean]}",_,"${matrix[$e_intra,name]}",_,_,"${matrix[$e_intra,stdpct]}","${matrix[$e_intra,min]}","${matrix[$e_intra,max]}","${matrix[$e_intra,poc]}"
			fi
			
			
			if [ $PRINT_CSV_INTER_SAMPLING_STATISTICS -eq 1 ]; then
				eventvalue="${matrix[$e_intra,mean]}"
				eventpoc="${matrix[$e_intra,poc]}"

				# Detects if the event 'e' at instant 't' is new in the matrix_inter
				# If not, add it the the associative matrix_inter in the next index
				newevent=1
				for r in "${matrix_inter[@]}"; do
					if [[ $r =~ .*event@$e_intra@$sampling_counter@.* ]]; then
						e_inter=$(echo $r | cut -f 2 -d '@')
						s_inter=$(echo $r | cut -f 3 -d '@')
						n_inter=$(echo $r | cut -f 5 -d '@')
						n_inter=$(($n_inter+1))
						
						[ $DEBUG -eq 1 ] && echo Old event in matrix_inter: current_run:$run_counter accumulated_samples:$n_inter time:"${matrix[$e_intra,time]}" value:$eventvalue event:$e_inter@$s_inter >&2
						matrix_inter[$e_intra@$sampling_counter,name]="event@$e_intra@$sampling_counter@x@$n_inter"
						matrix_inter[$e_intra@$sampling_counter,run_$run_counter]=$eventvalue
						matrix_inter[$e_intra@$sampling_counter,poc_$run_counter]=$eventpoc
						matrix_inter[$e_intra@$sampling_counter,n]=$n_inter
						matrix_inter[$e_intra@$sampling_counter,$n_inter]=$eventvalue
						matrix_inter[$e_intra@$sampling_counter"_poc",$n_inter]=$eventpoc

						COMMAND="if (( \$(echo \"scale=10;\$eventvalue > \"\${matrix_inter[$e_intra@$sampling_counter,max]}\"\" | bc -l) )); then matrix_inter[$e_intra@$sampling_counter,max]=\$eventvalue; fi"
						#echo $COMMAND
						eval $COMMAND

						COMMAND="if (( \$(echo \"scale=10;\$eventvalue < \"\${matrix_inter[$e_intra@$sampling_counter,min]}\"\" | bc -l) )); then matrix_inter[$e_intra@$sampling_counter,min]=\$eventvalue; fi"
						#echo $COMMAND
						eval $COMMAND

						COMMAND="matrix_inter[$e_intra@$sampling_counter,sum]=\$(echo \"scale=10;\"\${matrix_inter[$e_intra@$sampling_counter,sum]}\"+\$eventvalue\"|bc)"
						#echo $COMMAND
						eval $COMMAND


						COMMAND="if (( \$(echo \"scale=10;\$eventpoc > \"\${matrix_inter[$e_intra@$sampling_counter\"_poc\",max]}\"\" | bc -l) )); then matrix_inter[$e_intra@$sampling_counter\"_poc\",max]=\$eventpoc; fi"
						#echo $COMMAND
						eval $COMMAND

						COMMAND="if (( \$(echo \"scale=10;\$eventpoc < \"\${matrix_inter[$e_intra@$sampling_counter\"_poc\",min]}\"\" | bc -l) )); then matrix_inter[$e_intra@$sampling_counter\"_poc\",min]=\$eventpoc; fi"
						#echo $COMMAND
						eval $COMMAND

						COMMAND="matrix_inter[$e_intra@$sampling_counter\"_poc\",sum]=\$(echo \"scale=10;\"\${matrix_inter[$e_intra@$sampling_counter\"_poc\",sum]}\"+\$eventpoc\"|bc)"
						#echo $COMMAND
						eval $COMMAND
		
						newevent=0
						break
					fi
				done

				# If the line represents a new event in the period, creates a
				# new marker in the associative matrix
				if [ $newevent -eq 1 ]; then
					[ $DEBUG -eq 1 ] && echo New event in matrix_inter: current_run:$run_counter accumulated_samples:1 time:"${matrix[$e_intra,time]}" value:$eventvalue event:$e_intra@$sampling_counter >&2
					#echo $t,$POC,,POC 
					matrix_inter[$e_intra@$sampling_counter,name]="event@$e_intra@$sampling_counter@x@1"
					matrix_inter[$e_intra@$sampling_counter,run_$run_counter]=$eventvalue
					matrix_inter[$e_intra@$sampling_counter,n]=1
					matrix_inter[$e_intra@$sampling_counter,1]=$eventvalue
					matrix_inter[$e_intra@$sampling_counter,time]="${matrix[$e_intra,time]}"	#TO-DO: mean time
					matrix_inter[$e_intra@$sampling_counter,poc]="${matrix[$e_intra,poc]}"		#TO-DO: mean poc
					matrix_inter[$e_intra@$sampling_counter,min]=$eventvalue
					matrix_inter[$e_intra@$sampling_counter,max]=$eventvalue
					matrix_inter[$e_intra@$sampling_counter,sum]=$eventvalue
					matrix_inter[$e_intra@$sampling_counter,mean]=$eventvalue
					matrix_inter[$e_intra@$sampling_counter,d2]=0
					matrix_inter[$e_intra@$sampling_counter,std]=0
					matrix_inter[$e_intra@$sampling_counter,stdpct]=0

					matrix_inter[$e_intra@$sampling_counter"_poc",1]=$eventpoc
					matrix_inter[$e_intra@$sampling_counter"_poc",min]=$eventpoc
					matrix_inter[$e_intra@$sampling_counter"_poc",max]=$eventpoc
					matrix_inter[$e_intra@$sampling_counter"_poc",sum]=$eventpoc
					matrix_inter[$e_intra@$sampling_counter"_poc",mean]=$eventpoc
					matrix_inter[$e_intra@$sampling_counter"_poc",d2]=0
					matrix_inter[$e_intra@$sampling_counter"_poc",std]=0
					matrix_inter[$e_intra@$sampling_counter"_poc",stdpct]=0
				fi
			fi
		fi
	done

	return

	for e in "${events_array[@]}"; do
		for (( s=1; s<=$max_sampling_counter; s++ )); do
			for r in "${matrix[@]}"; do
				if [[ $r =~ .*event@$e@$s@.* ]]; then
					e_intra=$(echo $r | cut -f 2 -d '@')
					s_intra=$(echo $r | cut -f 3 -d '@')
					r_intra=$(echo $r | cut -f 5 -d '@')
					n_intra="${matrix_inter[$e_inter@$s_inter,n]}"

					#Print intra sampling statistics - perf CSV style - if enabled
					if [ $PRINT_CSV_INTER_SAMPLING_STATISTICS -eq 1 ]; then
						[ $DEBUG -eq 1 ] && echo -e "\nInter-sampling statistics" >&2
						echo "${matrix_inter[$e_inter@$s_inter,time]}","${matrix_inter[$e_inter@$s_inter,mean]}",_,"${matrix_inter[$e_inter@$s_inter,name]}",_,_,"${matrix_inter[$e_inter@$s_inter,stdpct]}","${matrix_inter[$e_inter@$s_inter,min]}","${matrix_inter[$e_inter@$s_inter,max]}","${matrix_inter[$e_inter@$s_inter,poc]}"
					fi
				fi
			done
		done
	done
}



echo file,frequency,cores,event,mean,stdev,min,max,poc,poc_mean,poc_stdev,poc_min,poc_max
# Main loop, iterates through each input file
for i in "$@";do 
	echo -e "\nInput: $i\n">&2

	fullfilename=$(basename -- "$i")
	prefix=$(echo $fullfilename|cut -d '_' -f 1-4); 
	file=$(echo $fullfilename|cut -d '_' -f 5-8); 
	freq=$(echo $fullfilename|cut -d '_' -f 9);
	cores=$(echo $fullfilename|cut -d '_' -f 10);
	sufix=$(echo $fullfilename|cut -d '_' -f 11-15);

	unset matrix_inter
	declare -A matrix_inter
	
	POC=0
	TOTAL_POC=0
	t=0
	key=""
	keys=""
	value=""
	TotalCpuTime=0
	EncodingTime=0
	EncodingWallTime=0
	EncodingCpuUsage=0
	Fps=0
	BeginNextSamplePeriod=2


	# Fix of intraline mixed outputs of container and perf
	# It locates a "POC" line inside a perf CSV line and splits the contents into separate lines
	# The 'N' flag in sed is used to concatenate the mixed line with the next one (remaining of the content)
	# changing the line separator (\n) by a token (€). After that, a sed 's' command is used to match the
	# combined line, splitting the contents in fields:
	# (^-1)(beginning of perf CSV contents-2)(POC contents-3)(token €-4)(remaining of perf CSV contents-5).
	# The output is structured to print: ^(POC contents-3)\n(CSV contents)$.
	
	stats="$(sed -e 's/^ *//;/\(^\)\(.\+\)\(POC.*$\)/N;s/\n/€/;s/\(^\)\(.\+\)\(POC.*\)\(€\)\(.*\)\($\)/\1\3\n\2\5/;s/owf/\n@@@@\n/;$s/$/\n@@@@\n____\n>/' $i)"
	
	OIFS="$IFS"
	IFS=$'\n'

	for j in $stats;
	do
		#j=$(echo $j|sed -e 's/^ *//')

		if [[ $j =~ .*@@@@.* ]] || [[ $j =~ .*____.* ]] || [[ $j =~ ^POC.* ]]; then

			if [ $BeginNextSamplePeriod -eq 0 ]; then
				printIntraSamplingStatistics
				((TOTAL_POC+=POC))
				POC=0
				unset matrix
				declare -A matrix
				BeginNextSamplePeriod=1;
			fi
			
			#Counts transcoded frames
			if [[ $j =~ ^POC.* ]]; then
				((POC++))
				[ $PRINT_TXT_POC_LINE_COUNTING -eq 1 ] && echo POC: $POC
				continue
			fi

			if [[ $j =~ .*@@@@.* ]]; then
				[ $PRINT_TXT_POC_LINE_COUNTING -eq 1 ] && echo TOTAL POC: $TOTAL_POC
				[ $PRINT_CSV_SAMPLED_POC -eq 1 ] && echo $t,$TOTAL_POC,,TOTAL_POC
				if [ $max_sampling_counter -lt $sampling_counter ]; then
					max_sampling_counter=$sampling_counter
				fi
				#sampling_counter=0
				run_counter=$(($run_counter+1))
				#TOTAL_POC=0
				continue
			fi


			## CSV output of Kvazaar stats 
			#if [[ $j =~ .*@@@@.* ]]; then
			#	[ $DEBUG -eq 1 ] && \
			#		echo sampling_counter $sampling_counter &&
			#		echo run_counter $run_counter
			#	printIntraSamplingStatistics
			#	if [ $PRINT_CSV_KVAZAAR_PER_RUN_STATISTICS -eq 1 ] && [[ ! -z "${key// }" ]]; then
			#		[ $DEBUG -eq 1 ] && echo KvazaarStats
			#		echo $t,$TotalCpuTime,,TotalCpuTime
			#		echo $t,$EncodingTime,,EncodingTime
			#		echo $t,$EncodingWallTime,,EncodingWallTime
			#		echo $t,$EncodingCpuUsage,,EncodingCpuUsage
			#		echo $t,$Fps,,Fps
			#	fi
			#	[ $DEBUG -eq 1 ] && echo -e "\nNew RUN"
			#	sampling_counter=0
			#	POC=0
			#	run_counter=$(($run_counter+1))
			#	BeginNextSamplePeriod=1;
			#	unset matrix
			#	declare -A matrix
			#fi
			#continue

			if [[ $j =~ .*____.* ]]; then
				[ $PRINT_CSV_INTER_SAMPLING_STATISTICS -eq 1 ] && printInterSamplingStatistics
				continue
			fi

		fi

		# Parses perf CSV outputs, registering also the total amount of frames since last sampling period
		if [[ $j =~ ^\ *.*\,\,.* ]]; then 
			new_t=$(echo $j | cut -f 1 -d ',')
			eventname=$(echo $j | cut -f 4 -d ',')
			eventvalue=$(echo $j | cut -f 2 -d ',')

			#New sampling period
			if (( $(echo "$t != $new_t" | bc -l) )); then 
				[ $DEBUG -eq 1 ] && \
					echo t: $t new_t: $new_t &&
					echo New perf sampling period

				if [ $BeginNextSamplePeriod -eq 0 ]; then
					printIntraSamplingStatistics
					((TOTAL_POC+=POC))
					POC=0
					unset matrix
					declare -A matrix
				elif [ $PRINT_CSV_SAMPLED_POC -eq 1 ]; then
					echo $new_t,$POC,,POC
				fi

				if (( $(echo "$t > $new_t" | bc -l) )); then
					sampling_counter=0
	                                #run_counter=$(($run_counter+1))	
	                                TOTAL_POC=0
				fi
				
				t=$new_t
				sampling_counter=$(($sampling_counter+1))
				
				#echo ,, $POC
				#POC=0
				BeginNextSamplePeriod=0;
			fi


			# Ignores input lines with <not counted> and displays a warning message in stderr
			if [[ $j =~ .*not\ counted.* ]]; then
				echo Ignoring line in input: $j >&2
				continue
			fi

			#Print perf input lines, if enabled
			[ $PRINT_CSV_PERF_INPUT_LINES -eq 1 ] && echo $j

			# Detects if the line represents a new event in the period
			# If not, add it the the associative matrix in the next index
			newevent=1
			for r in "${matrix[@]}"; do
				if [[ $r =~ .*event@$eventname@$sampling_counter.* ]]; then
					e_intra=$(echo $r | cut -f 2 -d '@')
					s_intra=$(echo $r | cut -f 3 -d '@')
					n_intra=$(echo $r | cut -f 4 -d '@')
					#echo N=$n_intra
					n_intra=$(($n_intra+1))
					[ $DEBUG -eq 1 ] && echo Old event:$e_intra iteration:$_intra n:$n_intra value:$eventvalue >&2
					matrix[$e_intra,name]="event@$e_intra@$s_intra@$n_intra"
					matrix[$e_intra,$n_intra]=$eventvalue

					COMMAND="if (( \$(echo \"scale=10;\$eventvalue > \"\${matrix[$e_intra,max]}\"\" | bc -l) )); then matrix[$e_intra,max]=\$eventvalue; fi"
					#echo $COMMAND
					eval $COMMAND

					COMMAND="if (( \$(echo \"scale=10;\$eventvalue < \"\${matrix[$e_intra,min]}\"\" | bc -l) )); then matrix[$e_intra,min]=\$eventvalue; fi"
					#echo $COMMAND
					eval $COMMAND

					COMMAND="matrix[$e_intra,sum]=\$(echo \"scale=10;\"\${matrix[$e_intra,sum]}\"+\$eventvalue\"|bc)"
					#echo $COMMAND
					eval $COMMAND
	
					newevent=0
					break
				fi
			done

			# If the line represents a new event in the period, creates a
			# new marker in the associative matrix
			if [ $newevent -eq 1 ]; then
				[ $DEBUG -eq 1 ] && echo New event:$eventname n:1 value:$eventvalue POC:$POC >&2
				events_array[$eventname]=$eventname
				matrix[$eventname,name]="event@$eventname@$sampling_counter@1"
				matrix[$eventname,time]=$t
				matrix[$eventname,poc]=$POC
				matrix[$eventname,min]=$eventvalue
				matrix[$eventname,max]=$eventvalue
				matrix[$eventname,sum]=$eventvalue
				matrix[$eventname,mean]=$eventvalue
				matrix[$eventname,d2]=0
				matrix[$eventname,std]=0
				matrix[$eventname,stdpct]=0
				matrix[$eventname,1]=$eventvalue
			fi

			continue
		fi

		# Parsing of Kvazaar stats
		k=$(echo $j | grep -e "Total CPU time" -e "Encoding time" -e "Encoding wall time" -e "Encoding CPU usage" -e "FPS")
		if [[ ! -z "${k// }" ]]; then
			keys=$(echo $k|sed -e 's/^[ \t]*\(.*\):.*/\1/')
			value=$(echo $k|sed -e 's/[^0-9. ]//g' -e 's/ \+/ /g' -e 's/ .$//g'| tr -s ' '| tr -d '[:blank:]')
			key=""
			case $keys in
				"Total CPU time")
					key="TotalCpuTime"
					TotalCpuTime=$value;
					;;
				"Encoding time")
					key="EncodingTime"
					EncodingTime=$value
					;;
				"Encoding wall time")
					key="EncodingWallTime"
					EncodingWallTime=$value
					;;
				"Encoding CPU usage")
					key="EncodingCpuUsage"
					EncodingCpuUsage=$value
					;;
				"FPS")
					key="Fps"
					Fps=$value
					;;
			esac
			continue
		fi

	done
	IFS="$OIFS"
done

exit 0
