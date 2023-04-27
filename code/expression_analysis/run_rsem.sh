#!/bin/bash
source activate RSEM
###mapping
genome="/data2/yamabe/Chylas/Assemble/Chylas_v3.1.fasta"
gtf=Chylas_lemon_modified.gtf
prefix=Chylas
threads=20
INDEX_dir=${prefix}_index

RSEM_prep=/data2/yamabe/miniconda2/envs/RSEM/bin/rsem-prepare-reference
RSEM_cal=/data2/yamabe/miniconda2/envs/RSEM/bin/rsem-calculate-expression
RSEM_gff2gtf=/data2/yamabe/miniconda2/envs/RSEM/bin/rsem-gff3-to-gtf

#make index file
mkdir $INDEX_dir
$RSEM_prep --gtf $gtf -p $threads $genome $INDEX_dir/RSEM_reference >RSEM_index.stdout 2>RSEM_index.stderr

#run RSEM
mkdir result
ls *Aligned.toTranscriptome.out.bam |while read line
do
	name=${line%_*}
	$RSEM_cal --paired-end --alignments -p $threads ${name}_Aligned.toTranscriptome.out.bam $INDEX_dir/RSEM_reference result/${prefix}_${name} > ${name}_RSEM.stdout 2> ${name}_RSEM.stderr

done

rm -rf $INDEX_dir

