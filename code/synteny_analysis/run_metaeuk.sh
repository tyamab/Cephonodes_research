#!/bin/sh
today=$(date "+%Y%m%d")
genome="Egrisescens.chr.fasta"
protein="Chylas.pep"
prefix=Egrisescens_results
threads=18

metaeuk easy-predict $genome $protein $prefix tmp --threads $threads >metaeuk.stdout 2>metaeuk.stderr

