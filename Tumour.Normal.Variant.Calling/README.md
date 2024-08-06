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

# Annotation

## Normalisation 

GATKs LeftAlignAndTrimVariants is run on each VCF from the callers above to esure that indel positions are left aligned. At this stage multiallelic sites are also split into separate rows.

## Annotation
Annotation is carried out using Ensembl's [Variant Effect Predictor (VEP)](https://www.ensembl.org/info/docs/tools/vep/index.html). By default this will use the data for Homo Sapiens GRCh38, release 112, though this can be changed in the config options. 

### COSMIC annotation

Due to licencing restrictions, the [Catalogue Of Somatic Mutations In Cancer (COSMIC)](https://cancer.sanger.ac.uk/cosmic/) versions later than v70 (Aug 2014) cannot be provided by tools. As such tools like Annovar come with the outdated version 70, whilst tools like VEP contain a more recent version of COSMIC, but cannot do allele matching (i.e. some of the annotated COSMIC IDs will not match the called variant allele). One solution to this is to download a copy of COSMIC and annotate from it directly.

Here BCFtools is used to annotate the variant calls with the COSMIC ID from a provided VCF file. By default this is a merged copy of the genome, non coding and targeted calls from version 100, using GRCh38 coordinates. These IDs will be added to the 3rd (ID) column of the VCF files.

**NB** As these calls were manually downloaded you should double check your annotated IDs to make sure they have been processed correctly. They will also not match *all* of the "EXISTING VARIANTS" called by VEP as some of these will be called with the wrong allele.

# Config options:
