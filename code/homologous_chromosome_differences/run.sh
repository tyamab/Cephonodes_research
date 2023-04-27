#!bin/sh
genome="Chylas_v3.fasta"
haplotig="hap.fa"
bed="dups.bed"
threads="20"
# Filter haplotigs and map them to Hi-C scaffolds

# 1. Execute minimap2 in haplotig mode, extract alignments with length >= 30,000 bp
minimap2 -cx asm5 --cs -t $threads $genome $haplotig |awk '$11 >= 30000' >  out_min30000.paf

# 2. Extract only those classified as HAPLOTIG by purge_dups
awk '$4=="HAPLOTIG"' $bed |cut -f1 > haplotig.txt
cat out_min30000.paf |awk '{print $1"\t"$3"\t"$4"\tHAPLOTIG\t"$6 }'|sort |uniq -w35|grep -f haplotig.txt  > dup_HiC.bed

bed="dup_HiC.bed"

./realmatch_identity_window.py $genome $haplotig $bed $threads > haplotigIdenitity.txt 2>realmatch.stderr

