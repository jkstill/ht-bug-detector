
Script to detect if processors are affected by skylake/kabylake HT bug.

Excellent article on which this is based:

https://lists.debian.org/debian-devel/2017/06/msg00308.html

These two pages were loaded into Excel vi data->from web.


* List of Intel processors code-named "Skylake":
http://ark.intel.com/products/codename/37572/Skylake

* List of Intel processors code-named "Kaby Lake":
http://ark.intel.com/products/codename/82879/Kaby-Lake

The column text was then copied to text files and the processer names retrieved:

(file names are skylake and kabylake)


Get all possible matches that are not E3 - E3 Xeon chips have versions V4,V5...

  grep -E -ho '[im][[:digit:]]-([[:digit:]]|[[:alpha:]])+' *ylake

  grep -E -ho 'E[[:digit:]]-([[:digit:]]|[[:alpha:]])+[[:space:]]v[[:digit:]]+' *ylake

All that do not match from previous command are the last word on the line

  grep -E -hv '[[:alpha:]][[:digit:]]-([[:digit:]]|[[:alpha:]])*' *ylake  | awk '{ print $NF }'


This includes all CPU chips - mobile, desktop and server

The ht-bug-cpus.txt file created:

  grep -E -o '[im][[:digit:]]-([[:digit:]]|[[:alpha:]])*' *ylake > ht-bug-cpus.txt

  grep -E -o 'E[[:digit:]]-([[:digit:]]|[[:alpha:]])+[[:space:]]v[[:digit:]]+' *ylake >> ht-bug-cpus.txt

  grep -E -v '[[:alpha:]][[:digit:]]-([[:digit:]]|[[:alpha:]])*' *ylake  | awk '{ print $NF }' >> ht-bug-cpus.txt


== Sanity Checks

jupiter $ wc -l ht-bug-cpus.txt
179 ht-bug-cpus.txt

jupiter $ wc -l *lake
77 kabylake
102 skylake
179 total

jupiter $ sort  -u ht-bug-cpus.txt | wc -l
179






