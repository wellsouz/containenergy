#!/bin/bash
for i in *; do 
	prefix=$(echo $i|cut -d '_' -f 1-4); 
	file=$(echo $i|cut -d '_' -f 5-6); 
	fps=$(echo $i|cut -d '_' -f 7 |cut -d '.' -f 1-2);
	sufix=$(echo $i|cut -d '_' -f 7|cut -d '.' -f 3-10);
	#sufix=$(echo $i|cut -d '_' -f 12-15);
	freq=$(echo $i|cut -d '_' -f 9);
	coresrun=$(echo $i|cut -d '_' -f 10-11|cut -d '.' -f 1);
	mv $i $prefix"_B_"$file"_"$fps"_"$freq"_"$coresrun"."$sufix; 
done

