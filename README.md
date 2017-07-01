
## skylake/kabylake HT bug detector

Excellent article on which this is based:

https://lists.debian.org/debian-devel/2017/06/msg00308.html

## Collecting the data for testing

These two pages were loaded into Excel vi data->from web.


* List of Intel processors code-named "Skylake":*
http://ark.intel.com/products/codename/37572/Skylake

* List of Intel processors code-named "Kaby Lake":*
http://ark.intel.com/products/codename/82879/Kaby-Lake

The column text was then copied to text files and the processer names retrieved:

(file names are skylake and kabylake)

Get all possible matches that are not E3 - E3 Xeon chips have versions V4,V5...

> grep -E -ho '[im][[:digit:]]-([[:digit:]]|[[:alpha:]])+' *ylake

> grep -E -ho 'E[[:digit:]]-([[:digit:]]|[[:alpha:]])+[[:space:]]v[[:digit:]]+' *ylake

All that do not match from previous command are the last word on the line

> grep -E -hv '[[:alpha:]][[:digit:]]-([[:digit:]]|[[:alpha:]])*' *ylake  | awk '{ print $NF }'

This includes all CPU chips - mobile, desktop and server

The ht-bug-cpus.txt file created:

> grep -E -o '[im][[:digit:]]-([[:digit:]]|[[:alpha:]])*' *ylake > ht-bug-cpus.txt

> grep -E -o 'E[[:digit:]]-([[:digit:]]|[[:alpha:]])+[[:space:]]v[[:digit:]]+' *ylake >> ht-bug-cpus.txt

> grep -E -v '[[:alpha:]][[:digit:]]-([[:digit:]]|[[:alpha:]])*' *ylake  | awk '{ print $NF }' >> ht-bug-cpus.txt


### Sanity Checks

'''jupiter $ wc -l ht-bug-cpus.txt
179 ht-bug-cpus.txt

jupiter $ wc -l *lake
77 kabylake
102 skylake
179 total

jupiter $ sort  -u ht-bug-cpus.txt | wc -l
179
'''

## Usage

ht-bug-chk.sh servername [username]

ssh is used if the server name is provided, otherwise the localhost is assumed
the username argument is optional for use with ssh

## Example usages

As I don't currently have access to a system with skylake or kabylake processer, these test just show machines that are not subject to the bug

$ ./ht-bug-chk.sh  japp
Host to check: jap
CPU Info : model name : Intel(R) Core(TM) i7-4790S CPU @ 3.20GHz
CPU Model: notaffected

CPU Architecture: notaffected

========================

This CPU is not affected by HyperThread bugs

$ ./ht-bug-chk.sh  oradns02
Host to check: oradns02
bash: lscpu: command not found
CPU Info : model name : Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz
CPU Model: notaffected

CPU Architecture: notaffected


This CPU is not affected by HyperThread bugs

========================

$ ./ht-bug-chk.sh  lestrade
Host to check: lestrade
CPU Info : model name : Intel(R) Core(TM) i5-4590 CPU @ 3.30GHz
CPU Model: notaffected

the model name  : Intel(R) Core(TM) i5-4590 CPU @ 3.30GHz is HyperThread capable
however HyperThreading is not enabled on this CPU



