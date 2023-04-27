#!/usr/bin/env python
#input .gff, .collinerarity
#output link.txt

import sys

def main():
    args = sys.argv
    if len(args) < 3:
        print(" ...gff ...collinearity")
        exit()
    else:
        gff = args[1]
        collinearity = args[2]
        #import gff file and make dict
        gene_dict ={}
        with open(gff,"r") as data:
            for da in data:
                da = da.split()
                gene_dict[da[1]] = [da[0],da[2],da[3]]
#import collinearity file and make link text
        with open(collinearity,"r") as data:
            for da in data:
                if da[0] == "#":
                    continue
                else:
                    da = da.split("\t")
                    list_1 = gene_dict[da[1]]
                    list_2 = gene_dict[da[2]]
                    print(' '.join([str(i) for i in list_1]),' '.join([str(i) for i in list_2]))

if __name__ =="__main__":
    main()