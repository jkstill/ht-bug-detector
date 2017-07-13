#!/bin/bash

hostToChk=$1
hostUsername=$2

currentUsername=$(id -u -n)

: ${hostToChk:=$HOSTNAME}
: ${hostUsername:=$currentUsername}

echo Host to check: $hostToChk


cpuFile=ht-bug-cpus.txt
#cpuFile=test-cpu.txt

sshCmd=''
# use eval when on local server to deal with quoting
evalCmd='eval'

# the '-n' argument to ssh is used to redirect STDIN from /dev/null 
# this is important when calling from another script, as otherwise ssh will cause the loop in the calling script
# to end after the first iteration


[[ $hostToChk != $HOSTNAME ]] && {
	sshCmd="ssh -n $hostUsername@$hostToChk "
	evalCmd=''
}

$sshCmd grep -q '^flags.*[[:space:]]ht[[:space:]]' /proc/cpuinfo

: <<'HTDOC'

on a virtual machine the correct CPU will be shown in /proc/cpuingo
but there will be no ht flag even if the processor is capable
the ht flag will appear only on the OS for the physical server

in some cases a CPU may be capable of HT, but HT has not been enabled
the ht flag is then misleading 

example: the following CPU is shown to be ht capable, but ht is not enabled

$ grep 'model name' /proc/cpuinfo| uniq
model name      : Intel(R) Core(TM) i5-4590 CPU @ 3.30GHz

$ grep "flags" /proc/cpuinfo | uniq | grep -o ' ht '
ht

$ lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                4
On-line CPU(s) list:   0-3
Thread(s) per core:    1
Core(s) per socket:    4
Socket(s):             1
NUMA node(s):          1
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 60
Model name:            Intel(R) Core(TM) i5-4590 CPU @ 3.30GHz
Stepping:              3



HTDOC

htCapable=$?
#echo Result: $htCapable

# get CPU model
gcmd="grep -E 'model name' /proc/cpuinfo | sort -u"
#echo gcmd:"$gcmd"

cpuInfo=$($sshCmd $evalCmd $gcmd)

# ht enabled if result GT 1
htEnabled=$($sshCmd $evalCmd lscpu | grep "Thread.*per"| awk '{ print $NF }')

#echo htEnabled: $htEnabled

#get exact CPU
cpuModel=$(echo $cpuInfo | grep -of  <( cut -f2 -d: $cpuFile ))

: ${cpuModel:='notaffected'}

echo CPU Info : $cpuInfo
echo CPU Model: $cpuModel


[[ $htCapable -ne 0 ]] && {

  echo 
  echo "the $cpuInfo is not HyperThread capable on this machine"
  echo "the 'ht' flag will not be present on virtual machines regardless of processor"
  echo
  exit 0

}

[[ $htCapable -ge 0 && $htEnabled -eq 1 ]] && {
	echo 
	echo "the $cpuInfo is HyperThread capable"
	echo "however HyperThreading is not enabled on this CPU"
	echo 
	exit 0
}

# now determine the processor architecture

cpuArch=$(grep ":$cpuModel" $cpuFile | cut -f1 -d:)
: ${cpuArch:='notaffected'}

echo 
echo CPU Architecture: $cpuArch
echo

skylakeInfo () {
	echo 
	echo This is a skylake CPU
	echo There is a microcode fix available for some models of skylake
	echo Please see the following article, and/or contact the appropriate vendors
	echo "https://lists.debian.org/debian-devel/2017/06/msg00308.html"
	echo "https://lists.debian.org/debian-devel/2017/06/msg00351.html"
}

notAffected() {
	echo
	echo This CPU is not affected by HyperThread bugs
	echo
}

case $cpuArch in

	notaffected) notAffected;exit 0;;
	nolake) echo "This is a test system - comment out the test cpuFile"; exit 0;;
	kabylake) echo "This is Kaby Lake - Disable HT now!";exit 0;;
	skylake) skylakeInfo; echo "more to come - skylake has several choices";exit 0;;

esac



