#!/bin/bash
###mapping
STAR=/data2/yamabe/miniconda2/envs/RSEM/bin/STAR
SAMTOOLS="samtools"
RSEM_gff2gtf=/data2/yamabe/miniconda2/envs/RSEM/bin/rsem-gff3-to-gtf

genome="/data2/yamabe/Chylas/Assemble/Chylas_v3.1.fasta"
gff="Chylas_lemon.gff"
prefix=Chylas
threads=20
INDEX_dir=${prefix}_index

#gff2gtf
python3 ./lemonfmt2gff3.py $gff ${gff%.*}_modified.gff3

## --genomeSAindexNbasesに関して (from manual)
##   default: 14 int: length (bases) of the SA pre-indexing string.
##   Typically between 10 and 15. Longer strings will use much more memory, but allow faster searches.
##   For small genomes, the parameter –genomeSAindexNbases must be scaled down to min(14, log2(GenomeLength)/2 - 1).
## calculate min(14, log2(GenomeLength)/2 - 1)
GenomeLength=` seqkit stats --quiet -T $genome |tail -n 1 |cut -f 5 `
x=` echo " l( $GenomeLength )/l(2)/2 - 1 " |bc -l | awk '{printf("%d",$1 + 0.5)}' `
genomeSAindexNbases=$( echo "if( $x < 15 ) $x else 15 " |bc )
##genomeSAindexNbases=14
echo GenomeLength: $GenomeLength
echo genomeSAindexNbases: $genomeSAindexNbases

##run

source activate RSEM
#gff2gtf
$RSEM_gff2gtf ${gff%.*}_modified.gff3 ${gff%.*}_modified.gtf

#make star index
name="0"
echo STAR indexing
mkdir $INDEX_dir
$STAR --runMode genomeGenerate \
	--runThreadN $threads \
	--genomeDir $INDEX_dir \
	--genomeSAindexNbases $genomeSAindexNbases \
	--sjdbGTFfile ${gff%.*}_modified.gtf \
	--genomeFastaFiles $genome > STAR_index.stdout 2>STAR_index.stderr

#run star
ls *trimmed |while read line
do
	if [ $name = ${line%R*} ]; then
		continue
	fi
	name=${line%S*}
	read_1=${name}S1_L001_R1_001.fastq.trimmed
	read_2=${name}S1_L001_R2_001.fastq.trimmed
	echo STAR mapping
	$STAR --runThreadN $threads \
	--limitBAMsortRAM 20000000000 \
	--genomeDir $INDEX_dir \
	--readFilesIn $read_1 $read_2 \
	--outSAMtype BAM SortedByCoordinate \
	--quantMode TranscriptomeSAM \
	--outSAMstrandField intronMotif \
	--outFileNamePrefix ${name} > ${name}STAR.stdout 2> ${name}STAR.stderr

done

rm -rf $INDEX_dir ${gff%.*}_modified.gff3

