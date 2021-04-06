#!/bin/bash
for i in {1..10000}
do
    echo "$i"
    my_job_statistics 18849220 | grep "CPU Efficiency\|Memory Efficiency"
    sleep 5
done