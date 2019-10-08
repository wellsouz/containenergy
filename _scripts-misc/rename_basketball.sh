#!/bin/bash
for i in *; do 
	prefix=$(echo $i|cut -d '_' -f 1-4); 
	file=$(echo $i|cut -d '_' -f 10-11|cut -d '.' -f 1); 
	fps=$(echo $i|cut -d '_' -f 5);
	#sufix=$(echo $i|cut -d '_' -f 7|cut -d '.' -f 3-10);
	sufix=$(echo $i|cut -d '_' -f 8|cut -d '.' -f 2);
	ext=$(echo $i|cut -d '_' -f 11|cut -d '.' -f 2);
	freq=$(echo $i|cut -d '_' -f 6);
	coresrun=$(echo $i|cut -d '_' -f 7-8|cut -d '.' -f 1);
	mv $i $prefix"_D_"$file"_"$fps"_"$freq"_"$coresrun"."$sufix"."$ext; 
done

