#!/bin/bash
today=$(date "+%Y%m%d")
t=20

TMP=$(mktemp)
base_dir=$PWD
work_dir=/scratch/yamabe/$$
mkdir -p $work_dir
mv * $work_dir
cd $work_dir

#codon alignment
#mkdir pairwise
#codeml function
func () {
	line=$1
#	mkdir run_${line}
#	cp codon_align_trimal/${line}.codon_align run_${line}
#	echo seqfile = ${line}.codon_align > run_${line}/codeml.ctl
#	cat base.ctl >> run_${line}/codeml.ctl
#	cd run_${line}
#	/data2/yamabe/tools/paml4.9j/bin/codeml
#    cd ..
#    cp run_${line}/codeml.txt pairwise/${line}.codeml.txt
    python parse_codeml.py pairwise/${line}.codeml.txt
#	rm -r run_${line}
}

export -f func
ls cds/*fna|cut -f2 -d"/" |cut -f1 -d"." | xargs -P $t -I % bash -c "func %" > ${TMP}_result.txt
mv ${TMP}_result.txt result_all_nofiltered.txt
rm ${TMP}*
mv $work_dir/* $base_dir
rm -r $work_dir
