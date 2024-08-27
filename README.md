# Snakemake Pipelines

## UNDER DEVELOPMENT

OkosunLab pipelines built using the snakemake workflow management system

## Contents

1. [Pipeline Library](#Pipeline-Library)
2. [Tutorial](#Tutorial)
   1. [Setup](#Setup)
   2. [Running A Pipeline](#Running-A-Pipeline)
      1. [Job Submission Setup](#Job-Submission-Setup)

## Pipeline Library:

Pipeline | info
--- | --- 
[Alignment with recalibration](https://github.com/OkosunLab/SnakemakePipelines/tree/main/Alignment.With.Recalibration) | Pipeline for aligning DNAseq reads from illumina sequencing and running GATK pre-processing
[Alignment with UMI collapsing](https://github.com/OkosunLab/SnakemakePipelines/tree/main/Alignment.With.UMI.Collapsing) | Pipeline for aligning DNAseq reads from illumina sequencing from UMI tagged data
[Tumour normal variant calling](https://github.com/OkosunLab/SnakemakePipelines/tree/main/Tumour.Normal.Variant.Calling) | Pipeline for calling variants from matched tumour normal bam files
[Tumour only variant calling](https://github.com/OkosunLab/SnakemakePipelines/tree/main/Tumour.Only.Variant.Calling) | Pipeline for calling variants from matched tumour normal bam files
## Tutorial

### Setup

First you will need to create a copy of the snakemake environment. You only need to do this once and it will be able to handle all your snakemake pipelines.

```bash
ml anaconda3
conda env create -n snakemake -f /data/BCI-OkosunLab/Environments/anaconda3/20240513.snakemake.8.11.3.yml
```

### Running A Pipeline

Copy a version of the current pipeline, config.yaml and envs folder into your project directory. This ensures we have a copy of the exact pipeline you ran to generate your data, in case the pipeline is updated.

Adjust the values in the config file as you see fit (these should be described in the file and in the repo for the subfolders.

Open a screen session and navigate to your project directory:

```bash
screen -S snakemake.projectname
cd /Project/Directory/Goes/Here
```

**N.B:** Screen is a linux program that lets you have a "detachable" session. You can use it to keep things running even when you completely logout of a linux computer. **IMPORTANT** Do not use it to run compute jobs on front end - You still have to abide by the general server etiquette whilst using screen. We will be using it to run the snakemake pipeline, but this doesn't require a lot of overhead as it will be submitting jobs for each rule in the pipeline.

Load your snakemake environment:

```bash
ml anaconda3
conda activate snakemake
```

I have written a little wrapper for the snakemake command that includes the correct way to get it to call jobs on the cluster. This is in the root of this repositiory and is called RunSnakefile.sh. By default this will run the local file called Snakefile, running one job at a time, but has a few options to change this.

Short | Long | Purpose
--- | --- | ---
-n | --dry-run | Run a dry run of the script (default: off)
-s | --snake-file | Provide the snakefile name (default: Snakefile)
-j | --jobs | Number of concurrent jobs to run (default: 1)
-t | --target | Target file/rule (default: none)
-d | --dag | Print the dag and exit (default: off)
-e | --extra | Takes all remaining arguments and passes them to snakemake (MUST BE LAST)
-h | --help | Display this message and exit

My suggestion is to symlink this command in your ~/.local/bin/ so you can call it from anywhere on the system.

```bash
ln -s /path/to/RunSnakefile.sh ~/.local/bin/
```

So to run a pipeline you can use something like this:

```bash
## Dry run first
RunSnakefile.sh -s pipeline.name.snake -j 100 -n
## Proper run if now happy
RunSnakefile.sh -s pipeline.name.snake -j 100
```

#### Job Submission Setup

For those interested we are dymanically creating job scripts using this command:

```bash
"qsub -V -l h_rt=240:0:0 -l h_vmem={params.mem} -pe smp {threads} -j y -cwd -o {log}.jobscript"
```
Args | Notes
--- | ---
-V | Is vital as this preserves the loaded conda module - without this you cannont use conda to load software (I have not been able to find another way to submit jobs with a module automatically loaded yet).
-l h_rt | Currently I am asking for the max time (240 hours or 10 days) I need to parameterise this so we can use the config to set this.
-l h_vmem | we set the required memory in the params section of the rule using the key mem (hence {params.mem})
-pe smp {threads} | take the number of threads from the rule.
-j y | join stdev and sterr
-cwd | work on the current working directory
-o {log}.jobscript | store the output of stdev and sterr in the same place as the snakemake log just with the suffix .jobscript

