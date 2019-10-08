#!/bin/bash
#for i in $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies); do 
for i in 3201000 3200000 3100000 2900000 2800000 2600000 2500000 2300000 2200000 2100000 1900000 1800000 1600000 1500000 1300000 1200000; do
	echo $i
	(for j in perfstat_*_$i*.stat; do ../../../_python/compare_pmu.py $j > $j.csv 2>$j.csv.err; done) &
#	(for j in perfstat_*_$i*.stat; do ../../../_python/compare_pmu_arman.py $j 2>$j.csv.err; done) &
done
