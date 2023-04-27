#!/bin/sh
query=$1
db=/data1/common/NCBI_DB/nr_dmnd_20200804/nr.dmnd
DB_name=nr
threads=18

/usr/bin/time diamond blastp --query $query \
 --db $db \
 --threads $threads \
 --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle \
 --evalue 1e-5 \
 --sensitive --out ${query}_${DB_name}.diamond.out > diamond.stdout 2>diamond.stderr

