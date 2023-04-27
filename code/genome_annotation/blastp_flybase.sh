#1/bin/sh
T=18
DB=flybase
database=/data2/yamabe/db/blastDB/flybase210316/flybase210316
line=$1

for line in `ls *pep`
do

	blastp -query $line -db $database -out ${line}_${DB}.out -evalue 1e-5 -seg no -outfmt "6 std stitle" -num_threads $T

done
