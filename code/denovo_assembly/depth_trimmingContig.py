#!/usr/bin/env python

import sys
from Bio import SeqIO
import tempfile

def depth_cut(file_name,min_depth,tmp_file):
    with open(tmp_file,"w") as out:
        with open(file_name,"r") as data:
            for da in data:
                depth = int(da.split()[2])
                if depth >= min_depth:
                    print(da.rstrip(),file=out)

def defineContigEdge(tmp_file):
    tigEdge_dict = {}
    last_tigname =""
    last_base = 0
    n = 0
    with open(tmp_file,"r") as data:
        for da in data:
            tig_name = da.split()[0]
            base = int(da.split()[1])
            if tig_name not in tigEdge_dict.keys():
                if n == 0:
                        n += 1
                else:
                    tigEdge_dict[last_tigname].append(last_base)
                tigEdge_dict[tig_name] = []
                tigEdge_dict[tig_name].append(base)
            last_tigname = tig_name
            last_base = base
        tigEdge_dict[last_tigname].append(last_base)
    return(tigEdge_dict)

def CutFasta(fasta_file,contig_dict,out_fasta):
    sum_len = 0
    sum_cutlength = 0
    print("ID","fasta_length","start","end","cut_length",sep='\t')
    with open(fasta_file,"r") as infa ,open(out_fasta,"w") as outfa:
        for seq_record in SeqIO.parse(infa,"fasta"):
            ID = seq_record.id
            if ID in contig_dict.keys():
                start = contig_dict[ID][0] -1
                end = contig_dict[ID][1]
                newSeq = seq_record.seq[start:end]
                #log
                fasta_length = len(seq_record.seq)
                cut_length = fasta_length - len(newSeq)
                sum_len += fasta_length
                sum_cutlength += cut_length
                print(ID,fasta_length,start+1,end,cut_length,sep='\t')
                #out_fasta
                print(">"+ID,file=outfa)
                print(newSeq,file=outfa)
    print("total_length: ",sum_len)
    print("cutlength: ",sum_cutlength)
    print("trimmed_length: ",str(sum_len - sum_cutlength))

def main():
    args =sys.argv
    if len(args) < 9:
        print ('-d depth_file -i input.fasta -o output.fasta -c cutoff[0,1,2,3...]')
        exit()
    for i in range(len(args)):
            if args[i] == "-d":
                depth_file = args[i+1]
            elif args[i] == "-i":
                input_fasta = args[i+1]
            elif args[i] == "-o":
                out_fasta = args[i+1]
            elif args[i] == "-c":
                cutoff = int(args[i+1])
    with tempfile.NamedTemporaryFile() as tmp:
        depth_cut(depth_file,cutoff,tmp.name)
        cut_dict = defineContigEdge(tmp.name)
    CutFasta(input_fasta,cut_dict,out_fasta)

if __name__=='__main__':
    main()
