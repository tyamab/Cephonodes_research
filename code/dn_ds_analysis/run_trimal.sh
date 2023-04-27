#!/bin/bash
source activate orthofinder
today=$(date "+%Y%m%d")
t=20

base_dir=$PWD
work_dir=/scratch/yamabe/$$
mkdir -p $work_dir
mv * $work_dir
cd $work_dir

#codon alignment
mkdir codon_align_trimal
mkdir $MODEL
echo -n > trimal.stderr
export PYTHON
func () {
	fasta=$1
	fasta2=${fasta#*/}
	line=${fasta2%%.*}
	mafft --auto protein/${line}.pep.faa > protein/${line}.maffted.fa 2>>mafft.stderr
	trimal -in protein/${line}.maffted.fa -out codon_align_trimal/${line}.codon_align -nogaps -backtrans cds/${line}.cds.fna -phylip_paml 2>>trimal.stderr || exit 0
	cat codon_align_trimal/${line}.codon_align |awk 'NR==1 {print $0};NR >1 {print $1"\n"$2}' > codon_align_trimal/${line}_temp.codon_align
	mv codon_align_trimal/${line}_temp.codon_align codon_align_trimal/${line}.codon_align 2>mv.err
}
export -f func
ls cds/*cds.fna| xargs -P $t -I % bash -c "func %"

mv $work_dir/* $base_dir
rm -r $work_dir
