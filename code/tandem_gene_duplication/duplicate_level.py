#!/usr/bin/env python
### input file flat.ortholog_groups.tsv (sonicparanoid) , gene_type (duplicate_gene_classifier output) ,header name (*.pep)

from os import dup
import sys

def Definecolumn(headername,filename):
    n = 0
    with open(filename,"r") as data:
        line = data.readline()
        da_list = line.split()
        for da in da_list:
            if da == headername:
                break
            else:
                n += 1
    return(n)

def Countduplicate(dup_dict,gene_list):
    singleton = 0
    dispersed = 0
    proximal = 0
    tandem = 0
    wsd = 0
    for g in gene_list:
        if g in dup_dict.keys():
            if dup_dict[g] == 0:
                singleton += 1
            elif dup_dict[g] == 1:
                dispersed += 1
            elif dup_dict[g] == 2:
                proximal += 1
            elif dup_dict[g] == 3:
                tandem += 1
            elif dup_dict[g] == 4:
                wsd += 1
    print_list = [singleton,dispersed,proximal,tandem,wsd]
    return(print_list)

def main():
    args = sys.argv
    if len(args) != 4:
        print("flat.ortholog_groups.tsv (sonicparanoid) , gene_type (duplicate_gene_classifier output) ,header name (*.pep)")
        exit()
    else:
        ortholog_file = args[1]
        gene_type = args[2]
        header = args[3]
        gene_type_dict = {}
        readcolumn = Definecolumn(header,ortholog_file)
        with open(gene_type,"r") as data: #make dictionary of gene_type
            for da in data:
                da_list = da.split()
                gene = da_list[0]
                type = int(da_list[1])
                gene_type_dict[gene] = type
        FirstRow = True
        with open(ortholog_file,"r") as data:
            for da in data:
                if FirstRow == True:
                    print("group_id\tnum_gene\tsingleton\tdispersed\tproximal\ttandem\tWSD/segmental")
                    FirstRow = False
                    continue
                else:
                    da_list = da.split()
                    group_id = da_list[0]
                    if da_list[0] == "*":
                        print(group_id,0,0,0,0,0,0,sep="\t")
                        continue
                    else:
                        orthogroup = da_list[readcolumn].split(",")
                        num_gene = len(orthogroup)
                        gene_type_list = Countduplicate(gene_type_dict,orthogroup)
                        print_list = [group_id,num_gene]
                        print_list.extend(gene_type_list)
                        print('\t'.join([str(i) for i in print_list ]))

if __name__ =="__main__":
    main()


