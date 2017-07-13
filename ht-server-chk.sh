#!/bin/bash

# check for HT bug vulnerable CPUs 
# read the list of servers from a file

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
logfile="ht-chk_${timestamp}.log"

while read server username
do
	echo Server  : $server
	echo Username: $username
	./ht-bug-chk.sh $server $username 
	echo 
	echo "########################################"
	echo

done < <( cat server-list.txt ) | tee $logfile



