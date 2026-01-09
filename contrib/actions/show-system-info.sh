#!/usr/bin/env bash

echo "-- CPU --"
cat /proc/cpuinfo

echo "-- Memory --"
cat /proc/meminfo

echo "-- Disk --"
df -h

echo "-- Kernel --"
uname -a

echo "-- Network --"
ip addr
