#!/bin/bash

hostToChk=$1
hostUsername=$2

currentUsername=$(id -u -n)

: ${hostToChk:=$HOSTNAME}
: ${hostUsername:=$currentUsername}

echo Host to check: $hostToChk


cpuFile=ht-bug-cpus.txt
cpuFile=test-cpu.txt

sshCmd=''
# use eval when on local server to deal with quoting
evalCmd='eval'

[[ $hostToChk != $HOSTNAME ]] && {
	sshCmd="ssh $hostUsername@$hostToChk "
	evalCmd=''
}


$sshCmd grep -q '^flags.*[[:space:]]ht[[:space:]]' /proc/cpuinfo

# on a virtual machine this will report the correct CPU
# but there will be no ht flag even if the processor is capable
# the ht flag will appear only on the OS for the physical server

htCapable=$?
#echo Result: $htCapable

# get CPU model
gcmd="grep -E 'model name' /proc/cpuinfo | sort -u"
#echo gcmd:"$gcmd"

cpuInfo=$($sshCmd $evalCmd $gcmd)

#eval $gcmd

#get exact CPU

cpuModel=$(echo $cpuInfo | grep -of  <( cut -f2 -d: $cpuFile ))

echo CPU Info : $cpuInfo
echo CPU Model: $cpuModel


[[ $htCapable -ne 0 ]] && {

  echo 
  echo "the $cpuInfo is not HyperThread capable on this machine"
  echo "the 'ht' flag will not be present on virtual machines regardless of processor"
  echo
  exit 0

}

# now determine the processor architecture

cpuArch=$(grep ":$cpuModel" $cpuFile | cut -f1 -d:)

echo 
echo CPU Architecture: $cpuArch
echo


case $cpuArch in

	nolake) echo "This is a test system - comment out the test cpuFile";;
	kabylake) echo "This is Kaby Lake - Disable HT now!";;
	skylake) echo "more to come - skylake has several choices";;

esac




