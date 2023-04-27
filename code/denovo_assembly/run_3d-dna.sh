#!/bin/sh
DRAFT="/data1/common/C.hylas/Assemble/Canu_v2.1.1_hetero/Chylas_v2.1.fasta"
FASTQ1="/data1/common/C.hylas/HiC/*_R1_001.fastq"
FASTQ2="/data1/common/C.hylas/HiC/*_R2_001.fastq"
JUICER="/data2/yamabe/tools/juicer/CPU/juicer.sh"
DRAFTLABEL="${DRAFT##*/}"
RESTRICTION="Arima"
FASTQLABEL="arima"
t=16

source activate 3D-DNA

ln -s /data2/yamabe/tools/juicer/CPU scripts

mkdir fastq

cat $FASTQ1 > fastq/ArimaHiC_R1.fastq
cat $FASTQ2 > fastq/ArimaHiC_R2.fastq


##### bwa index ########
mkdir references
cd references

ln -s $DRAFT
bwa index -p ${DRAFTLABEL} ${DRAFT}

cd ..

mkdir restriction_sites
cd restriction_sites
python /data2/yamabe/tools/juicer/misc/generate_site_positions.py ${RESTRICTION} draft ${DRAFT}
awk 'BEGIN{OFS="\t"}{print $1, $NF}' draft_${RESTRICTION}.txt > draft.chrom.sizes
cd ..//

mkdir fastq
cd fastq
index=0
for fq in ${FASTQ1}
do
	if [ ${FASTQ1:${#FASTQ1}-2} = "gz" ]; then
	  ln -s ${fq} ${FASTQLABEL}${index}_R1.fastq.gz
	else
	  ln -s ${fq} ${FASTQLABEL}${index}_R1.fastq
	fi
	((index++))
done
index=0
for fq in ${FASTQ2}
do
	if [ ${FASTQ2:${#FASTQ2}-2} = "gz" ]; then
	  ln -s ${fq} ${FASTQLABEL}${index}_R2.fastq.gz
	else
	  ln -s ${fq} ${FASTQLABEL}${index}_R2.fastq
	fi
	((index++))
done

$JUICER -g draft -z references/${DRAFTLABEL} -p restriction_sites/draft.chrom.sizes -y restriction_sites/draft_${RESTRICTION}.txt -D ./ -S early -t $t >juicer.stdout 2>juicer.stderr

mkdir work
cd work

##### run 3D-DNA pipeline ##############
/data2/yamabe/tools/3d-dna/run-asm-pipeline.sh ../references/${DRAFTLABEL} ../aligned/merged_nodups.txt >3D-DNA.stdout 2> 3D-DNA.stderr

cd ..//
rm -r fastq
