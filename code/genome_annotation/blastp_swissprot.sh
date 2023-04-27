#1/bin/sh
T=18
DB=swissprot
database=/data2/yamabe/db/blastDB/swissprot20210316/swissprot

for line in `ls *.pep`
do
	blastp -query $line -db $database -out ${line}_${DB}.out -evalue 1e-5 -seg no -outfmt "6 std stitle" -num_threads $T
done
