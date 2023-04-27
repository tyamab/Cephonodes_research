#!/bin/sh
T=4
for genome in `ls Chylas_v3.1.fasta`
do

	spec=${genome%.*}_db
	#builddatabase
	/usr/bin/time /data1/common/bin/RepeatModeler-2.0/BuildDatabase -name $spec $genome >BuildDatabase.out 2>BuildDatabase.err

	#repeatmodeler
	/usr/bin/time /data1/common/bin/RepeatModeler-2.0/RepeatModeler -database $spec -LTRStruct -pa $T > RepeatModeler.out 2>RepeatModeler.err

done

