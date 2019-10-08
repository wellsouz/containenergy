#!/bin/bash
# Generic script for executing batch tasks
cd /home/wsilva/esl.lapps
pwd
./perfstat_20.sh videosJVT/*.yuv

cd /mnt/video-files
pwd
./perfstat_20.sh videosJVT/*.yuv

#cd /home/wsilva/esl.lapps
#pwd
#./perfstat_100.sh videosJVT/*.yuv

#cd /mnt/video-files
#pwd
#./perfstat_100.sh videosJVT/*.yuv
