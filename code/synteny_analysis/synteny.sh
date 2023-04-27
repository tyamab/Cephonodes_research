#!/bin/sh
TMP=$(mktemp)
if [ $# -lt 3 ]; then
	echo "$1 ...GFF $2 ...ALL_PROTEIN $3 ...prefix $4 ...threads"
	exit 1
fi

GFF=$1
PROTEIN=$2
OUT=$3
T=$4

#make gff file
mkdir $OUT

cat $GFF |awk ' { if($3 == "mRNA"){ print $1"\t"$9"\t"$4"\t"$5 } }'|sed 's/ID=//g'| sort -k1,1 -k3,3n > $OUT/${OUT}.gff

##metaeuk option
#cat Egrisescens.gff > $OUT/${OUT}.gff
#cat Pxylostella.gff >> $OUT/${OUT}.gff

#run blast-all
makeblastdb -in $PROTEIN -out ${TMP}_gene_list -dbtype prot -parse_seqids > makeblastdb.log 2>&1
blastp -evalue 1e-5 -query $PROTEIN -db ${TMP}_gene_list -outfmt 6 -num_threads $T -max_target_seqs 5 -out $OUT/${OUT}.blast > blast.log 2>&1
rm -r ${TMP}*

#make ctl file
#echo "800" > $OUT/${OUT}.ctl
#cut -f1 $OUT/${OUT}.gff |sort|uniq|sed -z 's/\n/,/g' >> $OUT/${OUT}.ctl
