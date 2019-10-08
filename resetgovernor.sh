#!/bin/bash
# Script to reset CPUFreq, CPU online flag and stop/erase container instances

sudo docker stop $(docker ps -a -q) 2> /dev/null
sudo docker rm $(docker ps -a -q) 2> /dev/null

FREQUENCY=$(awk ' {print $2}' /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies)

for CPUON in /sys/devices/system/cpu/cpu*/online; do
	sudo sh -c "echo 1 > $CPUON"
	echo $CPUON $(cat $CPUON)
done

sudo cpupower frequency-set -g userspace
sudo cpupower frequency-set -d $FREQUENCY -u $FREQUENCY
sudo cpupower frequency-set -f $FREQUENCY
sudo cpupower frequency-info

echo Frequency: $FREQUENCY

