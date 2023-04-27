#!/bin/sh
today=$(date "+%Y%m%d")
threads=18
k=32
max=1000000000
READS="/data1/common/C.hylas/Illumina/Trimmed/[B]*.trimmed"

	jellyfish count -C -s $max -m $k -t $threads -o read.jf $READS
	jellyfish histo -t 10 -h $max read.jf > read.histo
	genomescope2.0.R -i read.histo -o Scope2.0 -p2 -k $k
	rm reads.jf
