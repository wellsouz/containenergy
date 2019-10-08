#!/bin/bash
FILES=$1
for i in {01..16}; do
	clear
	echo -e "NATIVE:\n"
	#tail -n 20 $FILES$i.yuv.native.stat | sed '9,17d'
	tail -n 20 $FILES$i.yuv.native.stat
	echo -e "\n********************************************************************************************************"
	echo -e "CONTAINER:\n"
	#tail -n 20 $FILES$i.yuv.container.stat | sed '9,17d'
	tail -n 20 $FILES$i.yuv.container.stat
	read
done

