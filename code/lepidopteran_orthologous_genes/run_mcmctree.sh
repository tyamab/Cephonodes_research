#!/bin/sh

#export path
export PATH=/data2/yamabe/tools/paml4.9j/bin:$PATH

#run_first
/usr/bin/time /data2/yamabe/tools/paml4.9j/src/mcmctree mcmctree.ctl >mcmctree.1st.log 2>mcmctree.1st.err
rm out.BV rst

#dat copy
cp /data2/yamabe/tools/paml4.9j/dat/wag.dat .
# make control file
head -n3 tmp0001.ctl > tmp1.ctl
echo -e 'model = 2 * 2: Empirical\naaRatefile = wag.dat\nfix_alpha = 0\nalpha = .5\nncatG = 4\nSmall_Diff = 0.1e-6\ngetSE = 2\nmethod = 1' >> tmp1.ctl

#run codeml
/usr/bin/time codeml tmp1.ctl > codeml.log 2>codeml.err

#rename
mv rst2 in.BV

#run 2nd
/usr/bin/time /data2/yamabe/tools/paml4.9j/src/mcmctree mcmctree_2nd.ctl >mcmctree.2nd.log 2>mcmctree.2nd.err
