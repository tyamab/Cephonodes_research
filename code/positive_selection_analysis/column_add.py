#!/usr/bin/env python
#coding:utf-8
import sys

if len(sys.argv) < 13:
	print ('-i input_file -k key_column[int] -f dictionary_file -dk key_column[int] -dv key_value[int] -None [int](0...Off 1~ On) ')
	exit()
for i in range(len(sys.argv)):
	if sys.argv[i] == "-i":
		inp = open(sys.argv[i+1],"r")
	elif sys.argv[i] == "-k":
		key_inp = int(sys.argv[i+1])
	elif sys.argv[i] == "-f":
		add = open(sys.argv[i+1],"r")
	elif sys.argv[i] == "-dk":
		key_add = int(sys.argv[i+1])
	elif sys.argv[i] == "-dv":
		value_add = int(sys.argv[i+1])
	elif sys.argv[i] == "-None":
		none = int(sys.argv[i+1])

dic={}
for g in add:
	if none != 0:
		g = g.split(None,none)
	else:
		g = g.split()
	if len(g) < key_add + 1 or g[0][0] == "#":
		continue
	dic[g[key_add]]=g[value_add].rstrip()

for r in inp:
	if r[0] =="#":
		print(r.rstrip())
	else:
		rsp = r.split()
		switch = rsp[key_inp] in dic.keys()
		if switch == True:
			print(r.rstrip(),dic[rsp[key_inp]],sep='\t')
		elif switch == False:
			print(r.rstrip(),"NA",sep='\t')
exit()
