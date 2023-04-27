#!/usr/bin/env python

import sys
import re

species = "Chylas"
words = ""
add_words = ""
with open(sys.argv[1],"r") as data:
	for tree in data:
		test_list = re.split('[,)]',tree)
		for test in test_list:
			if species in test:
				words = test
				add_words = test + " #1"

		if len(add_words) != 0:
			tree = tree.replace(words,add_words)
print(tree.rstrip())
