import sys
import re

# Open the input file
with open(sys.argv[1], "r") as codeml:
    # Initialize variables
    status = 0
    pairwise_data = []

    # Parse the input file
    for i in codeml:
        # Check if the pairwise comparison data has started
        if i.startswith("pairwise comparison, codon frequencies"):
            status = 1

        # Parse the pairwise comparison data
        if status == 1:
            if i[0].isdigit():
                # Extract gene names
                line = i.rstrip()
                line2 = re.sub("\(", "", line)
                line3 = re.sub("\)", "", line2)
                group = line3.split(" ")
                first = group[1]
                second = group[4]

            elif i.startswith("t="):
                # Extract dN and dS values
                line = i.rstrip().replace("=", "\t")
                _, _, _, _, _, _, _, dnds, _, dn, _, ds, *_ = line.split()

                # Store pairwise data
                pairwise_data.append((first, second, dnds, dn, ds))

    # Output the pairwise data
    # print("Gene_1\tGene_2\tdN/dS\tdN\tdS")
    for data in pairwise_data:
        if 0.01 < float(data[4]) < 2 and float(data[2]) < 10:
            print("\t".join(data))
