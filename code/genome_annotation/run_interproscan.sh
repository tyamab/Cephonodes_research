#!/bin/sh
today=$(date "+%Y%m%d")
line=Chylas
threads=19


	sed 's/*//g' ${line}.pep > ${line}.modified.pep
	/data2/yamabe/tools/interproscan-5.51-85.0/interproscan.sh -f tsv -pa -goterms -cpu $threads -i ${line}.modified.pep -o ${line}_interproscan >${line}.stdout 2>${line}.stderr
