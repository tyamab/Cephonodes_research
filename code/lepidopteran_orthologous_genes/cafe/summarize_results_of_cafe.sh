#!/bin/sh

# make species tree with annotations

TMP=$(mktemp)
grep "TREE 1 =" results/Base_asr.tre > ${TMP}.tree
for i in `awk '{print $1"[\\\&!name=\"+"$2"/-"$3"\"]"}' results/Base_clade_results.txt`
do
    first=${i%%[*}
    second=${i}
    sed -i 's|'${first}'|'${second}'|g' ${TMP}.tree

done
cat ${TMP}.tree |awk '{print $4}'|perl -pe  's/_\d+//g;s/\*//g'
rm ${TMP}*
