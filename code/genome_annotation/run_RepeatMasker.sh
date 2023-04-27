#!/bin/sh
genome="Chylas_v3.1.fasta"
RM_lib="consensi.fa.classified"

/data1/common/bin/RepeatMasker/util/queryRepeatDatabase.pl -species lepidoptera |cat $RM_lib - > RepeatLibrary.fa
lib=RepeatLibrary.fa
/data1/common/bin/RepeatMasker/RepeatMasker -x -a -pa 16 -lib $lib $genome >Repeatmasker.log 2>RepeatMasker.err

