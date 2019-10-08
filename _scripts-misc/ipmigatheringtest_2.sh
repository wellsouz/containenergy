#!/bin/bash
while read -r line; do if [[ $line =~ ^.*event3 ]]; then sensors|ts '[%.s]' >> $1; fi; done

