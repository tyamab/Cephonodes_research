#!/bin/sh
t=18

#branch
echo -n > LRTresult_branch.out
echo -n > LRTresult_branch-site.out
#function
func () {
	name=$1
	#branch model
    	./run_LRT.py branch/${name}.branch.out branch_null/${name}.branch_null.out branch |awk '$10!="nan"' >> LRTresult_branch.out
	#branch-site model
    	./run_LRT.py branch-site/${name}.branch-site.out branch-site_null/${name}.branch-site_null.out branch-site |awk '$10!="nan"' >> LRTresult_branch-site.out
}
export -f func
ls branch/*.branch.out |cut -f2 -d"/" |cut -f1 -d"." | xargs -P $t -I % bash -c "func %"
python FDR_codeml.py LRTresult_branch-site.out > LRTresult_branch-site_FDR.out
python FDR_codeml.py LRTresult_branch.out > LRTresult_branch_FDR.out
