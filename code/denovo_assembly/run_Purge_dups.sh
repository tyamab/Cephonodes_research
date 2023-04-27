#cutoff
genome=$1
t=$2

subreads=/data2/yamabe/Chylas/PacBio/Chylas_subreads_down33.fastq
export PYTHONPATH=/data2/yamabe/tools/purge_dups/runner/lib/python3.7/site-packages/runner-0.0.0-py3.7.egg:$PYTHONPATH

mkdir base
mkdir base/coverage base/purge_dups base/seqs base/split_aln base/seqs/cal_cov

echo $subreads > reads.fofn


#calculate coverage and self-alignment
/data2/yamabe/tools/purge_dups/bin/split_fa $genome > base/split_aln/base.split.fa
minimap2 -xasm5 -DP base/split_aln/base.split.fa base/split_aln/base.split.fa > base/split_aln/base.split.paf
minimap2 -I 4G -x map-pb -t $t $genome $subreads >base/coverage/subreads.paf
/data2/yamabe/tools/purge_dups/bin/pbcstat -O base/coverage base/coverage/subreads.paf

#purge duplicates
/data2/yamabe/tools/purge_dups/bin/purge_dups -2 -c base/coverage/PB.base.cov -T manual_cutoff base/split_aln/base.split.paf > base/purge_dups/dups.bed
/data2/yamabe/tools/purge_dups/bin/get_seqs -e -p base/seqs/base base/purge_dups/dups.bed $genome
minimap2 -I 4G -x map-pb -t $t base/seqs/base.purged.fa $subreads >base/seqs/cal_cov/subreads.paf
/data2/yamabe/tools/purge_dups/bin/pbcstat -O base/seqs/cal_cov base/seqs/cal_cov/subreads.paf
/data2/yamabe/tools/purge_dups/bin/calcuts  base/seqs/cal_cov/PB.stat > base/seqs/cal_cov/cutoffs

cp base/seqs/base.purged.fa ${genome}.purged
cp base/seqs/base.hap.fa ${genome}hap
cp
rm reads.fofn
mv base ${genome%.*}.base

