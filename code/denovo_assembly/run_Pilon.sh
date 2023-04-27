#!/bin/bash
###mapping
##pilon
genome=/data2/yamabe/Chylas/assemble/Canu_v2.1.1_hetero/remove_LowCoverage/Canu_removeEdge_cov10.fasta
PREFIX=Canu_removeEdge_cov10
T=14
read_1=/data2/yamabe/Chylas/Illumina/Chylas_hiseq_1.fastq.trimmed.gz
read_2=/data2/yamabe/Chylas/Illumina/Chylas_hiseq_2.fastq.trimmed.gz
PacBio=/data2/yamabe/Chylas/PacBio/Chylas_subreads_down33.bam

num_polish=3
ITERNUM=0
pilon_dir=/data2/yamabe/tools/pilon

mkdir PacBio_reads
#PacBio reads
samtools fasta -@ $T $PacBio > PacBio_reads/reads.fa

for i in `seq 1 $num_polish `
do
	ITERNUM=$((++ITERNUM))
	##bwa
	bwa index -p reference $genome
	bwa mem -t $T -o ${PREFIX}.pilon${ITERNUM}.sam reference $read_1 $read_2
	samtools view -@ $T -bS ${PREFIX}.pilon${ITERNUM}.sam|samtools sort -@ $T -O bam -o ${PREFIX}.pilon${ITERNUM}.sorted.bam
	samtools index ${PREFIX}.pilon${ITERNUM}.sorted.bam
	rm ${PREFIX}.pilon${ITERNUM}.sam
	##mininap2
	minimap2 -ax map-pb -t $T $genome PacBio_reads/reads.fa > ${PREFIX}.PacBio.pilon${ITERNUM}.sam
	##samtools
	samtools view -@ $T -bS ${PREFIX}.PacBio.pilon${ITERNUM}.sam |samtools sort -@ $T -O bam -o ${PREFIX}.PacBio.pilon${ITERNUM}.sorted.bam >samtools.pb.stdlog 2> samtools.pb.stderr
	samtools index ${PREFIX}.PacBio.pilon${ITERNUM}.sorted.bam
	rm *.pilon${ITERNUM}.sam reference*

	##pilon
	/usr/bin/time -v java -Xmx180g -jar $pilon_dir/pilon-1.24.jar --genome $genome --bam ${PREFIX}.pilon${ITERNUM}.sorted.bam --pacbio ${PREFIX}.PacBio.pilon${ITERNUM}.sorted.bam  --verbose --changes --output ${PREFIX}.pilon${ITERNUM} > ${PREFIX}.pilon${ITERNUM}.stdlog 2>${PREFIX}.pilon${ITERNUM}.stderr
	genome=${PREFIX}.pilon${ITERNUM}.fasta
	rm *bam *bam.bai
done

rm -r PacBio_reads

