ls */*.codon_align|while read line
do
    name=${line%%.*}
    awk '{if(NR%2==0&&$0!=""){print ">"$1}else{print $0}}' $line |tail -n+2 > ${line}.fa
    sed -e 's/\(Chylas_[0-9]\+\)/\1{Foreground,Foreground}/g' ${name}.trimmed.treefile > ${name}.labeled.treefile
    hyphy MEME --alignment ${line}.fa --tree  ${name}.labeled.treefile > ${line}.MEME.out 2>err
    hyphy Contrast-FEL --alignment ${line}.fa --tree ${name}.labeled.treefile --branch-set Foreground,Foreground > ${line}.FEL.out 2>err
done
