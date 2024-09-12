# UMI consensus alignment

## Contents
1. [Overview](#overview)
   1. [Pipeline Steps](#pipeline-steps)
   2. [Quality Control](#quality-control)
   3. [First Alignment](#First-Alignment)
   4. [UMI collapsing](#UMI-collapsing)
   5. [Consensus Alignment](#Consensus-Alignment)
1. [Output](#Output)
2. [Config Options](#config-options)

# Overview

This pipeline will run from unaligned fastq files to consensus bam files using UMIs. First the samples are aligned to the genome. Then UMIs are added to identify PCR duplicates. These are then collapsed into consensus reads which should 1. remove all true PCR duplicates and 2. help to reduce the error of the reads by building the consensus of the duplicate reads. These consensus reads are converted back to fastq format prior to being aligned once again against the reference genome.

## Pipeline Steps

![Rulegraph for UMI consensus alignment](Alignment.With.UMI.Collapsing.svg)

## Quality Control

*fastp version: 0.23.4*\
*fastq screen version: 0.15.3*

1. **[fastp](https://github.com/OpenGene/fastp)** is used to check the raw fastq files as well as running adapter and quality trimming. The pipeline uses the trimmed files downstream by default.
2. **[fastq_screen](https://www.bioinformatics.babraham.ac.uk/projects/fastq_screen/)** screens the raw fastq for reads aligning to other genomes. This allows you to test for contaimination in your samples.
	1. The file: /data/BCI-OkosunLab/Ref/FASTQ_Screen/fastq_screen.conf controls which genomes are used.
	2. By default it uses the following genomes:

Genome | Version | Origin
--- | --- | ---
Human | GRCh38 (hg38) | Ensembl
Mouse | GRCm39 (mm10) | Ensembl
Mycobacterium tuberculosis | H37Rv | NCBI
Escherichia coli | MG1655 | NCBI
Staphylococcus aureus | NCTC 8325 | NCBI

## First Alignment

*bwa version: 0.7.17*\
*samtools version: 1.20*

1. Trimmed fastq files are aligned to the reference geneome (set in the config file) using [**bwa mem**](https://github.com/lh3/bwa).
2. [**Samtools**](http://www.htslib.org/) flagstat extracts the alignment stats from the raw bam.

## UMI collapsing

*fgbio version: 2.2.1-0*\
*samtools version: 1.20*

1. [fgbio](https://github.com/fulcrumgenomics/fgbio) is used to add UMIs to the bam file with [**AnnotateBamWithUmis**](http://fulcrumgenomics.github.io/fgbio/tools/latest/AnnotateBamWithUmis.html).
2. The bam file is sorted with [**SortBam**](http://fulcrumgenomics.github.io/fgbio/tools/latest/SortBam.html).
3. Mate info is set with [**SetMateInformation**](http://fulcrumgenomics.github.io/fgbio/tools/latest/SetMateInformation.html).
4. Reads are grouped by their UMIs with [**GroupReadsByUmi**](http://fulcrumgenomics.github.io/fgbio/tools/latest/GroupReadsByUmi.html) (the number of UMIs per family is recorded at this step. This is found in QC/fgbio/{sample}.family_size_histogram.txt). 
5. The consensus is called for UMI marked PCR duplicates with [**CallMolecularConsensusReads**](http://fulcrumgenomics.github.io/fgbio/tools/latest/CallMolecularConsensusReads.html).
6. samtools is used to convert this bam file back into a consensus fastq file.

## Consensus Alignment

*bwa version: 0.7.17*\
*samtools version: 1.20*\
*GATK version: 4.5.0*

1. Consensus fastq files are aligned to the reference geneome (set in the config file) using bwa mem.
   1. The resulting file is coordinate sorted by samtools
2. samtools flagstat is used to get the alignment stats from the consensus bam file
3. **[GATK DepthOfCoverage](https://gatk.broadinstitute.org/hc/en-us/articles/21905133224859-DepthOfCoverage-BETA)** is used to generate the coverage across the intervals (with per base coverage turned off).
4. multiqc collects all the QC metrics from the pipeline.

# Output

The pipeline will output the aligned bams in a folder called Alignment. QC files will be stored in the folder QC, with a subfolder called MultiQC which contains a summary of all the QC records

# Config options

Option | Description | Default| Notes
--- | --- | --- | ---
reference | reference fasta | /data/BCI-OkosunLab/Ref/GRCh38/GATK_resource_bundle/Homo_sapiens_assembly38.fasta |
bwa_index | index for BWA | /data/BCI-OkosunLab/Ref/GRCh38/GATK_resource_bundle/Homo_sapiens_assembly38.fasta |
intervals | bed file of targeted positions | /data/BCI-OkosunLab/Ed/Ref/Bed-Files/PCNSL_ctDNA_panel_v6/PCNSL_ctDNA_panel_v6_covered.bed |
rawFolder | location of raw files | FASTQ_Raw |
sampleString | string to target the samples (change this to sample sheet) | "{sample}_S{number}_{lane}_R1_001.fastq.gz" |
consensusReads | minimum number of reads to call consensus from (1 is low, but OK with high complexity libraries) | 1 |
multiqcThreads | threads | 1 |
multiqcMem | memory | 4G |
combineThreads | threads | 1 |
combineMem | memory | 8G |
fastqScreenThreads | threads | 8 |
fastqScreenMem | memory | 8G |
fastpThreads | threads | 1 |
fastpMem | memory | 8G |
bwaThreads | threads | 8 |
bwaMem | memory | 4G |
fgbioThreads | threads | 1 |
fgbioMem | memory | 26G |
fgbioJavaMem | memory (passed to fgbio) | -Xmx24g |
consensusFastqThreads | threads | 3 |
consensusFastqMem | memory | 8G |
gatkThreads | threads | 1 |
gatkMem | memory | 16G |
gatkRunMem | memory (passed to java) | 12288 |
samtoolsStatThreads | threads | 1 |
samtoolsStatMem | memory | 8G |
samtoolsIdxThreads | threads | 4 |
samtoolsIdxMem | memory | 8G |



