#!/bin/sh
t=20
genome_size=380m
fastq=/data2/yamabe/Chylas/PacBio/Chylas_subreads.fastq


/usr/bin/time canu useGrid=false maxThreads=$t -p assembly -d result genomeSize=$genome_size -pacbio-raw $fastq corOutCoverage=200 correctedErrorRate=0.035 "batOptions=-dg 3 -db 3 -dr 1 -ca 500 -cp 50" >canu.stdout 2>canu.stderr

