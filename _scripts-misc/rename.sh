#!/bin/bash
for i in *; do 
	prefix=$(echo $i|cut -d '_' -f 1-4); 
	file=$(echo $i|cut -d '_' -f 8-10); 
	fps=$(echo $i|cut -d '_' -f 11-15|cut -d '.' -f 1-2); 
	sufix=$(echo $i|cut -d '_' -f 11-15|cut -d '.' -f 3-10);
	printf -v freq "%07d" $(echo $i|cut -d '_' -f 5);
	coresrun=$(echo $i|cut -d '_' -f 6-7);
	echo mv $i $prefix"_"$file"_"$fps"_"$freq"_"$coresrun"."$sufix; 
done

