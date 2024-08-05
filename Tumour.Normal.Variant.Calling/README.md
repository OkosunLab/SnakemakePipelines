# Tumour normal variant calling

This snakemake pipeline takes a sample sheet of matched tumour/normal samples and run a selection of somatic variant calling pipelines. 

# Overview of the pipeline:

![Pipeline overview](somatic.variant.calling.svg)

## Mutect2

GATK's somatic caller

## Strelka2

The SV caller Manta is run first to generate candidate indels for Strelka2

## Varscan2

Pileup files are created using samtools. The snakemake wrapper for this ONLY allows gzipped outputs, but varscan somatic fails if given compressed pileup files. The gunzip intermediate step ungzips the pileup file so Varscan can run on it.

## Fourth caller

# Config options:
