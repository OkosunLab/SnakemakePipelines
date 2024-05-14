# SnakemakePipelines
OkosunLab pipelines built using the snakemake workflow language

## Pipeline Library:

Pipeline | info
--- | --- 
UMI.Consensus.Calling | Pipeline for calling variants from UMI marked DNA-seq

## Tutorial

First you will need to create a copy of the snakemake environment. You only need to do this once and it will be able to handle all your snakemake pipelines.

```bash
ml anaconda3
conda create -f /data/BCI-OkosunLab/Environments/anaconda3/20240513.snakemake.8.11.3.yml
```

Copy a version of the current pipeline, config.yaml and envs folder into your project directory. This ensures we have a copy of the exact pipeline you ran to generate your data, in case the pipeline is updated.

Adjust the values in the config file as you see fit.

Open a screen session and navigate to your project directory:

```bash
screen -S snakemake.projectname
cd /Project/Directory/Goes/Here
```

Load your snakemake environment:

```bash
ml anaconda3
conda activate snakemake
```

I have written a little wrapper for the snakemake command that includes the correct way to get it to call jobs on the cluster. This is in the root of this repositiory and is called RunSnakefile.sh. By default this will run the local file called Snakefile, running one job at a time, but has a few options to change this.

Short | Long | Purpose
--- | --- | ---
-n | --dry-run | Run a dry run of the script
-s | --snake-file | Provide the snakefile name (default: Snakefile)
-j | --jobs | Number of concurrent jobs to run
-t | --target | target file/rule
-d | --dag | Print the dag and exit 
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
