#!/bin/sh
query=$1
db="/data1/common/NCBI_DB/nt_20200804/nt"
DB_name=nt
threads=16
filter_name="Arthropoda"

source activate centrifuge

#extract top hit
cut -f1,3 ${query}_${DB_name}.blastn.out |awk '$2!=""' > fastaid2taxid.txt

#extract taxonomy information
cut -f3 ${query}_${DB_name}.blastn.out > taxid.txt
taxonkit lineage -j 8 -t taxid.txt --data-dir /data1/common/NCBI_DB/taxonomy_20200804 > taxid2names.txt

#extract phylum information
taxonkit reformat -j 8 -f "{p}" taxid2names.txt --data-dir /data1/common/NCBI_DB/taxonomy_20200804 |cut -f1,4|awk '$2!=""' > taxid2phylum.txt
column_add.py -i fastaid2taxid.txt -k 1 -f taxid2phylum.txt -dk 0 -dv 1 -None 0 > fasta2phylum.txt
rm fastaid2taxid.txt taxid.txt taxid2phylum.txt

awk -v foo=${filter_name} '$3==foo' fasta2phylum.txt|cut -f1|uniq > fileterd_list.txt
