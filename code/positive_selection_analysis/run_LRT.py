#!/usr/bin/env python

# Scripts for likelihood ratio tests on branch and branch-site models
# input codeml.out codeml_null.out model_type[branch,branch-site]
# output [gene ID] [model] [#1 omega] [other omega] [null omega] [Likelihood of Model (Ln0)] [Likelihood of Model (Ln1)] [2lnL] [np1 - np0] [p-value]

import sys
from scipy.stats import chi2

def Extract_Branch(outfile):
    with open(outfile,"r") as data:
        for da in data:
            da_list = da.split()
            if "lnL(ntime:" in da:
                np = int(da_list[3].split(")")[0])
                Ln1 = float(da_list[4])
            elif "w (dN/dS) for branches:" in da:
                omega_0 = float(da_list[4])
                omega_1 = float(da_list[5])
        return_list = [omega_1,omega_0,Ln1,np]
        return(return_list)

def Extract_Branch_null(outfile):
     with open(outfile,"r") as data:
        for da in data:
            da_list = da.split()
            if "lnL(ntime:" in da:
                np = int(da_list[3].split(")")[0])
                Ln0 = float(da_list[4])
            elif "omega (dN/dS)" in da:
                omega_null = float(da_list[3])
        return_list = [omega_null,Ln0,np]
        return(return_list)

def Extract_BranchSite(outfile):
    with open(outfile,"r") as data:
        for da in data:
            da_list = da.split()
            if "lnL(ntime:" in da:
                np = int(da_list[3].split(")")[0])
                Ln1 = float(da_list[4])
        return_list = [Ln1,np]
        return(return_list)

def Extract_BranchSite_null(outfile):
    with open(outfile,"r") as data:
        for da in data:
            da_list = da.split()
            if "lnL(ntime:" in da:
                np = int(da_list[3].split(")")[0])
                Ln0 = float(da_list[4])
        return_list = [Ln0,np]
        return(return_list)

def main():
    args = sys.argv
    if len(args) < 4:
         print("codeml.out codeml_null.out model_type[branch,branch-site]")
         exit()
    else:
        file = args[1]
        file_name = args[1].split(".")[0]
        file_null = args[2]
        model = args[3]
        if model == "branch":
            branch = Extract_Branch(file)
            branch_null = Extract_Branch_null(file_null)
	    #print("[geneID]\t[model]\t[#1_omega]\t[other_omega]\t[null_omega]\t[LikelihoodOfModel(Ln0)]\t[LikelihoodOfModel(Ln1)]\t[2lnL]\t[np1-np0]\t[p-value]")
            lnL =  2*(branch[2] - branch_null[1])
            np = branch[3] - branch_null[2]
            pvalue = chi2.sf(x = lnL,df = np)
            print(file_name,model,branch[0],branch[1],branch_null[0],branch_null[1],branch[2],lnL,np,pvalue,sep="\t")
        elif model == "branch-site":
            branch_site = Extract_BranchSite(file)
            branch_site_null = Extract_BranchSite_null(file_null)
            #print("[geneID]\t[model]\t[#1_omega]\t[other_omega]\t[null_omega]\t[LikelihoodOfModel(Ln0)]\t[LikelihoodOfModel(Ln1)]\t[2lnL]\t[np1-np0]\t[p-value]")
            lnL = 2*(branch_site[0] -branch_site_null[0])
            np = branch_site[1] - branch_site_null[1]
            pvalue = chi2.sf(x = lnL,df = np)
            print(file_name,model,"na","na","na",branch_site_null[0],branch_site[0],lnL,np,pvalue,sep="\t")
        else:
            exit()

if __name__ == "__main__":
    main()
