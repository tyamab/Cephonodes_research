import random
import pandas as pd
import numpy as np
from scipy.stats import gaussian_kde
from scipy import stats
from matplotlib import rcParams
import matplotlib.pyplot as plt
import seaborn as sns
from Bio import SeqIO

# plot from X masked FASTA files (the rest of genomes, focused chromosome)
def plot_resampling_TE_density(fasta_file, fasta_observation, ax):
    # font option
    rcParams['pdf.fonttype'] = 42

    # Step 1: Choose a window size
    window_size = 100000

    # Step 2: Random sampling
    input_file = fasta_file
    num_samples = 100000
    samples = []
    sequences = list(SeqIO.parse(input_file, "fasta"))
    for i in range(num_samples):
        seq_record = random.choice(sequences)
        start = random.randint(0, len(seq_record.seq) - window_size)
        end = start + window_size
        sample = str(seq_record.seq[start:end])
        samples.append(sample)
        # print("iteration", str(i), file = sys.stderr)

    # Step 3: Calculate element density
    element_counts = []
    for sequence in samples:
        count = sequence.count('X')
        element_counts.append(count)

    element_densities = [count / window_size for count in element_counts]

    # calculate mean of repeat density of observed sequence
    observed_sequence = list(SeqIO.parse(fasta_observation, "fasta"))[0]
    repeat_counts = []
    for i in range(0, len(observed_sequence.seq), window_size):
        window = observed_sequence.seq[i:i+window_size]
        repeat_counts.append(window.count('X'))

    observed_element_density = [count / window_size for count in repeat_counts]
    observed_mean = np.mean(observed_element_density)
    print("mean:",observed_mean)

    # perform Wilcoxon rank sum test for non-normally distributed data
    if not stats.normaltest(element_densities).pvalue > 0.05:
        t_stat, p_value = stats.ttest_ind(element_densities, observed_element_density, equal_var=False)
        print("t test")
    else:
        t_stat, p_value = stats.mannwhitneyu(element_densities, observed_element_density, alternative='two-sided')
        print("u test")
    print('p-value:', p_value)

    # Step 4: Generate the distributions
    # Set number of bins and range for histogram
    bins = 50
    # Plot histogram
    plt.style.use('ggplot')
    if "Chylas" in fasta_file:
        ax.hist(element_densities, bins=bins, color="#999999", label="Others", alpha = 0.5)
        ax.plot([observed_mean, observed_mean],[0,10000], linestyle = "-", label='C27', linewidth = 4, color = "#ee934f", alpha = 0.5)
    elif "Msexta" in fasta_file:
        ax.hist(element_densities, bins=bins, color="#999999", label="Others", alpha = 0.5)
        ax.plot([observed_mean, observed_mean],[0,10000], linestyle = "-", label='M28_S', linewidth = 4, color = "#b36de3", alpha = 0.5)
    ax.set_xlabel("Repeat Density (%)")
    ax.set_ylabel("Frequency")
    # plot observation
    if p_value <= 0.001:
        p_text = 'p < 0.001'
    else:
        p_text = f'p = {p_value:.3f}'
    ax.text(0.7, 0.9, p_text, fontsize=14, transform=ax.transAxes)
    ax.legend(loc='upper left', bbox_to_anchor=(0.8, 1.15))

# plot kimura distance from tsv file (repeat family \t kimura distance)
def plot_kde(input_file1, input_file2, ax):
    # font option
    rcParams['pdf.fonttype'] = 42
    xlabel = 'Kimura distance'

    # define the name of input file as a list 
    input_files = [input_file1, input_file2]

    # Process each file using a for loop
    num_samples = 100000
    sample_datas = []
    for input_file in input_files:
        # Load a tsv file
        data = pd.read_csv(input_file, delimiter="\t")
        # conduct resampling of 100k with replicate on the third column
        sample_data = data.iloc[:, 2].sample(n=num_samples, replace=True)
        # append the extracted data to a list
        sample_datas.append(sample_data)
    plt.style.use('ggplot')
    # Draw a histogram with kernel density estimation applied (seaborn)
    sns.histplot(sample_datas[0], bins=list(range(61)), kde=True, label="Others", color='#6C676E', alpha=0.5, ax=ax)
    if "Chylas" in input_file1:
        sns.histplot(sample_datas[1], bins=list(range(61)), kde=True, label="C27", color='#ee934f', alpha=0.5, ax=ax)
    elif "Msexta" in input_file2:
        sns.histplot(sample_datas[1], bins=list(range(61)), kde=True, label="M28_S", color='#b36de3', alpha=0.5, ax=ax)

    ax.set_xlabel(xlabel)
    ax.set_ylabel("Frequency")
    # Show a lengend
    # ax.legend()

def main():
    # Create a list that stores the argument information
    fig, axs = plt.subplots(nrows = 2, ncols=2, figsize = (8,8))
    # Call function plot_resampling_TE_density to plot the histogram for the first two data sets
    plot_resampling_TE_density("data/Msexta_rest_of.fasta", "data/Msexta_Chr28_SFC.masked", axs[0,0])
    plot_resampling_TE_density("data/Chylas_rest_of.fasta", "data/Chylas_Chr27.masked", axs[0,1])

    # Call function plot_kde to plot the histogram for the last two data sets
    plot_kde("data/Msexta_rest_of_genomes.align.tsv", "data/Msexta_Chr28_SFC.fasta.align.tsv", axs[1,0])
    plot_kde("data/Chylas_rest_of_genomes.align.tsv", "data/Chylas_Chr27.fasta.align.tsv", axs[1,1])
    # Adjust the padding between graphs
    # plt.tight_layout(pad=0.5)
    plt.show()
    # save the graphs
    plt.savefig('output2.pdf')

if __name__ =="__main__":
    main()