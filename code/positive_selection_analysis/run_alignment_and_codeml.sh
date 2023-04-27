#!/bin/sh
t=19
today=$(date "+%Y%m%d")
PYTHON="/data2/yamabe/miniconda2/bin/python"

source activate orthofinder
mkdir gene_tree

######run iq-tree
run_iqtree () {
	fasta=$1
	mafft --auto protein/${fasta}.pep > protein/${fasta}.mafft
	trimal -in protein/${fasta}.mafft -out gene_tree/${fasta}.trimmed -automated1
	iqtree -s gene_tree/${fasta}.trimmed -bb 1000 -nt 1

}
export -f run_iqtree
cat OG_list_filtered.txt|xargs -P $t -I % bash -c "run_iqtree %"

#######codon alignment
mkdir codon_align_trimal
echo -n > trimal.stderr
run_trimal () {
	line2=$1
	cds=cds/${line2}.cds
	trimal -in protein/${line2}.mafft -out codon_align_trimal/${line2}.codon_align -nogaps -backtrans $cds -phylip_paml 2>>trimal.stderr || exit 0
	cat codon_align_trimal/${line2}.codon_align |awk 'NR==1 {print $0};NR >1 {print $1"\n"$2}' > codon_align_trimal/${line2}_temp.codon_align
	mv codon_align_trimal/${line2}_temp.codon_align codon_align_trimal/${line2}.codon_align
}
export -f run_trimal
cat OG_list_filtered.txt |xargs -P $t -I % bash -c "run_trimal %"

######edit gene tree
mkdir modified_gene_tree
for tree in `ls gene_tree/*.trimmed.treefile`
do
	line=${tree%%.*}
	line2=${line##*/}
	num=`grep Chylas $tree |wc -l`
	if [ $num -eq 1 ]; then
		$PYTHON ./modify_genetree.py $tree > modified_gene_tree/${line2}.modified.treefile 2>modified.err
	fi
done

for MODEL in branch branch_null branch-site branch-site_null
do
    #######run codeml
    mkdir $MODEL
    export MODEL
    #codeml branch model function
    func () {
    	line=$1
    	mkdir run_${line} #make directory
    	cat codon_align_trimal/${line}.codon_align > run_${line}/${line}.codon_align #copy and modified pal2nal codon alignment file to run directory
    	cp modified_gene_tree/${line}.modified.treefile run_${line} #copy treefile to run directory
    	echo seqfile = ${line}.codon_align > run_${line}/codeml.ctl #echo seqfile to codeml.ctl
    	echo treefile = ${line}.modified.treefile >> run_${line}/codeml.ctl #echo treefile to codeml.ctl
    	echo outfile = ${line}.${MODEL}.out >> run_${line}/codeml.ctl #echo outfile to codeml.ctl
    	cat ${MODEL}_base.ctl >> run_${line}/codeml.ctl #echo other control information to codeml.ctl
    	cd run_${line}
    	/data2/yamabe/tools/paml4.9j/bin/codeml > ${line}.${MODEL}.log
    	cd ..
    	mv run_${line}/${line}.${MODEL}.log run_${line}/${line}.${MODEL}.out ${MODEL}
    	rm -r run_${line}
    }
    export -f func
    cat OG_list_filtered.txt | xargs -P $t -I % bash -c "func %"
done

