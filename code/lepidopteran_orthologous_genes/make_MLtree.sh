#!/bin/sh
today=$(date "+%Y%m%d")
SINGLECOPY=single-copy_groups.tsv
PROTEIN="Bmandarina.pep  Bmori_RefSeq.pep  Chylas.pep  Gmellonella.pep  Harmigera.pep  Hvespertilio.pep  Msexta_RefSeq.pep  Pxuthus.pep  Pxylostella.pep  Slitura.pep"
PYTHON=/data2/yamabe/miniconda2/bin/python
t=18

TMP=$(mktemp)

base_dir=$PWD
work_dir=/scratch/yamabe/$$
mkdir -p $work_dir
mv * $work_dir
cd $work_dir

source activate orthofinder
#make fasta
cp $SINGLECOPY  ${TMP}.singlecopy
cat $PROTEIN > ${TMP}.all.fasta
$PYTHON /data2/yamabe/script/python_scripts/sonicparanoid_to_speciestree_edit.py ${TMP}.singlecopy ${TMP}.all.fasta 2>> ERR
#align multiplefasta
echo -n > trimal.stderr
func () {
        fasta=$1
        line=${fasta%%.*}
      	mafft --auto $fasta > ${line}.maffted.fa 2>>mafft.stderr
        trimal -in ${line}.maffted.fa -out ${line}.maffted.trimmed.fa -automated1 2>>trimal.stderr
}
export -f func
ls *pep.faa| xargs -P $t -I % bash -c "func %"

#change OTU
head -1 ${TMP}.singlecopy |cut -f1 --complement |sed 's/.pep//g'|tr '\t' '\n' > ${TMP}.specieslist.txt 2>> ERR
ls *pep.faa > ${TMP}.oglist.txt
$PYTHON /data2/yamabe/script/python_scripts/change_OTU.py ${TMP}.oglist.txt ${TMP}.specieslist.txt 2>>ERR
#run IQ-TREE
iqtree -sp run.nex -nt AUTO -bb 1000 >tree.stdout 2>tree.stderr


rm ${TMP}*
mv $work_dir/* $base_dir
rm -r $work_dir
