#!/bin/bash
# Script to run a dummy application, with START and STOP marking the ROI
echo "Stuppid math operations"

echo "100 * 100" | bc
echo "sqrt (2)" | bc
echo "1 * 2 * 3 * 4 * 5 * 6 * 7 * 8 * 9" | bc

echo -e "\nDo the magic: START\n"

echo "100 * 100" | bc
echo "sqrt (2)" | bc
echo "1 * 2 * 3 * 4 * 5 * 6 * 7 * 8 * 9" | bc

echo -e "\nSTOP this bullshit\n"

echo "100 * 100" | bc
echo "sqrt (2)" | bc
echo "1 * 2 * 3 * 4 * 5 * 6 * 7 * 8 * 9" | bc


