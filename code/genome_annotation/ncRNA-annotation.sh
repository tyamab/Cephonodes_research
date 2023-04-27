#!/bin/sh
T=14
today=$(date "+%Y%m%d")
genome="Chylas_v3.1.fasta"
masked="Chylas_v3.1.fasta.out"

cmpress Rfam.cm
cmscan --cpu 18 --rfam --cut_ga --nohmmonly --tblout Chylas-genome.tblout --fmt 2 --clanin Rfam.clanin Rfam.cm $genome > Chylas-genome.cmscan 2>cmscan.stderr

# make SINE masked genome sequences
ClassMasker $genome $masked SINE.masked.fasta SINE

genome="SINE.masked.fasta"
PREFIX="Chylas_SINE.maksed_tRNAscanSE"
## run tRNAscan-SE

tRNAscan-SE $genome -H -y -o ${PREFIX}.out -a ${PREFIX}.fasta -f ${PREFIX}.strc.for.tbl --detail --thread $T > tRNAscanSE.log 2> tRNAscanSE.err

# high confidencial filter
EukHighConfidenceFilter -i ${PREFIX}.out -s ${PREFIX}.strc.for.tbl -o . -p ${PREFIX}.HighConfidence -r > EukHighConfidenceFilter.log 2>&1

rm Rfam.cm.*
