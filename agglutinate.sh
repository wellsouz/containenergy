#!/bin/bash

prefixes=$(ls *.csv|cut -d '_' -f 1-4|sort|uniq)

for prefix in $prefixes; do

	files=$(ls $prefix"_"*.csv|cut -d '_' -f 5-8|sort|uniq)

	for file in $files; do

		sufixes=$(ls $prefix"_"$file"_"*.csv|cut -d '_' -f 12-| rev | cut -d. -f2- | rev | sort | uniq)
		
		for sufix in $sufixes; do

			headerfile=$(ls $prefix"_"$file"_"*"_"$sufix""*.csv|head -n 1)
			#echo $headerfile
			resultfile=$prefix"_"$file"_"$sufix"_ALL.csv"
			echo $resultfile
			head -n 1 $headerfile > $resultfile
			for i in $prefix"_"$file"_"*"_"$sufix".csv"; do
				tail -n +2 $i | grep -v ",,,,,," >> $resultfile 
			done
		done
	done
done
