import argparse
from statsmodels.stats.multitest import multipletests
argparser = argparse.ArgumentParser(description='multiple testing corrections using the Benjamini-Hochberg method')
argparser.add_argument('tsv', type=str, action="store", help = "test_result_branch-site.tsv")
args = argparser.parse_args()

lines = list()
p_vals = list()
with open(args.tsv, "r") as data:
    for ln in data:
        if ln[0] == "#":
            continue
        lnlist = ln.strip().split("\t")
        p_val = float(lnlist[9])
        p_vals.append(p_val)
        lines.append(ln.strip())

pvals_corr = multipletests(p_vals, alpha=0.05, method='fdr_bh')[1]

print("[geneID]\t[model]\t[#1_omega]\t[other_omega]\t[null_omega]\t[LnL(null)]\t[LnL(Alt)]\t[chi^2]\t[df]\t[p-value]\t[FDR q value]")
for line, pval_corr in zip(lines, pvals_corr):
    print(line + "\t" + str(pval_corr))
