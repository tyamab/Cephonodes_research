#!/usr/bin/env python
#coding: utf-8

import sys
import re
import subprocess
import tempfile
import os
from decimal import Decimal, ROUND_HALF_UP, ROUND_HALF_EVEN
import numpy as np
from numpy.lib.arraysetops import _isin_dispatcher
from numpy.lib.utils import byte_bounds

def dec(x):
	return(Decimal(str(x)).quantize(Decimal('0.0001'), rounding=ROUND_HALF_UP))

def run_seqkit(input_fasta,sliding,window,output_fasta):
    # run seqkit
	sliding =str(sliding)
	window = str(window)
	cmd1='seqkit sliding -g -s '+ sliding +' -W ' + window + ' ' + input_fasta + ' > ' +  output_fasta
	subprocess.run(cmd1,shell=True)

def run_minimap2(input_ref,input_query,output,threads):
	cmd2='minimap2 -c -t ' + threads + ' --secondary=no ' + input_ref + ' ' + input_query + ' > ' +  output + ' 2> minimap.err'
	# run command
	subprocess.run(cmd2,shell=True)
def calculate_idenitity(pa_list):
	# Change to a specification that performs calculations as long as the queries on the first line are the same.
    # Combine alignments derived from the same query and calculate their identity.
	realmatch=0
	residue_match=0
	alignment_block=0
	N_region=0
	n = 0
    # calculate
#	nn_list = re.findall('nn:i:[0-9]+',pa_list)
#	for g in nn_list:
#		g = g.split(":")
#		N_region += int(g[2])
	realmatch_list = re.findall('[0-9]+M',pa_list[len(pa_list)-1])
	for r in realmatch_list:
		r = r.rstrip('M')
		realmatch += float(r)
	position = [int(pa_list[7]),int(pa_list[8])]
	residue_match = float(pa_list[9])
	alignment_block = float(pa_list[10])
	identity = dec(residue_match/alignment_block*100)
	realmatch_identity = dec(residue_match/realmatch*100)
	N_rate = dec(N_region/alignment_block*100)
	print(pa_list[5], position[0],position[1], realmatch_identity,sep="\t")

def main():
	if len(sys.argv) < 5:
		print("...purged.fa ...hap.fa ...purge_dups.bed ...threads")
		exit()
	ref=sys.argv[1]
	query=sys.argv[2]
	bed_file = sys.argv[3]
	threads = sys.argv[4]
	window = 100000
	# Corresponding to bed file
	bed_dict = {}
	with open(bed_file,"r") as bed:
		for data in bed:
			data_list = data.split()
			if data_list[3] == "HAPLOTIG":
				tig = data_list[0]
				bed_dict[tig] = data_list[4]

	# Run minimap2 and output paf file
	with tempfile.TemporaryDirectory() as dname:
#	dname = os.getcwd() # If you want to output intermediate files
		run_seqkit(query,window,window,os.path.join(dname,"query.window.fasta"))
		run_minimap2(ref,os.path.join(dname,"query.window.fasta"),os.path.join(dname,"out.paf"),threads)
		# Take out each alignment from the paf file line by line, while checking the correspondence with the bed file.
        # Remove sliding information
		with open(os.path.join(dname,"out.paf"),"r") as paf:
			for pa in paf:
				pa_list = pa.split()
				tigID = pa_list[0].split("_sliding")[0]
				if tigID in bed_dict.keys():
					if bed_dict[tigID] == pa_list[5]:
						calculate_idenitity(pa_list)
	# End
if __name__ == "__main__":
	main()
