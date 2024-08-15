# UMI consensus alignment

## Contents
1. [Overview](#overview)
1. [Config Options](#config-options)

# Overview

This pipeline will run from unaligned fastq files to consensus bam files using UMIs.

![Rulegraph for UMI consensus alignment](Alignment.With.UMI.Collapsing.svg)

1. Quality Check
	1. fastp is used to check the raw fastq files as well as running adapter and quality trimming.
	1. fastq_screen screens the raw fastq for reads aligning to other genomes.
2. trimmed fastq files are aligned to the reference geneome (set in the config file) using bwa mem.
3. samtools flagstat extracts the alignment stats from the raw bam.
4. fgbio is used to add UMIs to the bam files.
	1. UMIs are added.
	2. The bam file is sorted.
	3. Mate info is set.
 	4. Reads are grouped by their UMIS (the number of UMIs per family is recorded at this step).
  	5. The consensus is called for UMI marked PCR duplicates.
5. samtools is used to convert this bam file back into a consensus fastq file.
6. Consensus fastq files are aligned to the reference geneome (set in the config file) using bwa mem.
   1. The resulting file is coordinate sorted by samtools
7. multiqc collects all the QC metrics from the pipeline.

# Config options

Option | Description | Default| Notes
--- | --- | --- | ---
reference | reference fasta | /data/BCI-OkosunLab/Ref/GRCh38/GATK_resource_bundle/Homo_sapiens_assembly38.fasta |
bwa_index | index for BWA | /data/BCI-OkosunLab/Ref/GRCh38/GATK_resource_bundle/Homo_sapiens_assembly38.fasta |
intervals | bed file of targeted positions | /data/home/hfx472/BCI-OkosunLab/Ed/Ref/Bed-Files/PCNSL_ctDNA_panel_v6/PCNSL_ctDNA_panel_v6_covered.bed |
rawFolder | location of raw files | FASTQ_Raw |
sampleString | string to target the samples (change this to sample sheet) | "{sample}_S{number}_{lane}_R1_001.fastq.gz" |
consensusReads | minimum number of reeds to call consensus from (1 is low, but OK with high complexity libraries) | 1 |
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



