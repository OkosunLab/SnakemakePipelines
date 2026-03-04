#!/bin/bash

###################################
## Default options
###################################
## Use the Snakefile called Snakefile (default behaviour of Snakemake)
Snakefile=Snakefile
## Run one job at a time
Jobs=1
## Don't do a dry-run
Dry=""
## Create a DAG?
DAG=0
## Create a rulegraph
RULEGRAPH=0
## Set high mem
HIGHMEM=""
## Target rule/file?
target=""
## Extra options?
EXTRA=""
dagFile="dag.svg"
## Where is the conda environment
conda_envs="/data/BCI-OkosunLab/Environments/Snakemake"
OS="rocky"
## join output
join="-j y"
## job scheduler
scheduler="slurm"
###################################

RED="\033[0;31m" 
NC='\033[0m' 
echo -e "${RED} 
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣤⣤⣶⣶⣿⡟⠢⣶⣤⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣟⢿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣦⢶⣶⡀⠀⠋⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⣾⣿⣿⡟⣽⡖⠀⠀⠉⠙⢿⣿⣷⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⣿⣿⣿⣾⣿⡄⠀⠀⠀⠀⠀⠈⠙⠛⠛⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⢿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
⠀⠀⠀⠀⠀⠈⠻⣿⣿⣿⣿⣿⣿⣷⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
⠀⠀⢀⡄⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⣿⣷⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
⠀⠀⢸⣿⣆⠀⠀⣀⣀⡀⠀⠀⠀⠙⢿⣿⣿⣯⢿⣿⣷⢀⣀⣀⣀⠀⠀⠀⠀⠀ 
⠀⠀⣠⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣤⡘⣿⣿⣿⣏⣿⣿⣿⣿⣿⣿⣿⣷⣦⡀⠀ 
⢀⣾⣿⣿⣿⠿⣛⣻⣿⣟⣻⣿⣿⣿⣇⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣆ 
⣼⣿⣿⣿⢳⣿⣿⡿⠿⠿⠿⣿⣿⣿⣿⣿⣿⣿⡇⣿⣿⣁⣈⣁⣹⣿⣿⣿⣿⣿ 
⣿⣿⣿⣿⣧⣝⣁⣀⣀⣀⣀⣤⣾⣿⣿⣿⣿⡟⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟ 
⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢋⣼⢟⣵⣾⣭⣽⣛⣛⣯⣽⣿⠟⠀ 
⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⣫⠴⠋⠁⠙⠛⠻⠿⠿⠿⠿⠟⠋⠁⠀⠀ 
⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠀⠈⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ 
Ceci n'est pas une pipe${NC}" 

while [ "$1" != "" ]; do
        case $1 in
                -n | --dry-run )	Dry="-n"
					;;
		-s | --snake-file )	shift
					Snakefile=$1
					;;
		-j | --jobs )		shift
					Jobs=$1
					;;
		-t | --target )		shift
					target=$1
					;;
		-d | --dag )		DAG=1
					;;
		-r | --rulegraph )	RULEGRAPH=1
					;;
		-x | --join-off )	join="-e {log}.error"
					;;
		-m | --highmem )	HIGHMEM='-l highmem'
					;;
		-f | --dag-file )	shift
					dagFile=$1
					;;
		-c | --conda_location )	shift
					conda_envs=$1
					;;
		-o | --os )		shift
					OS=$1
					;;
		-e | --extra )		shift
					EXTRA=$@
					;;
		-q | --scheduler )	shift
					scheduler=$1
					;;
		-h | --help )		echo -e "
A script for running OkosunLab snakemake files on apocrita (should work on almost any SGE based system too)
Written by: Findlay Bewicke-Copley
Last Updated: 01/05/2024

Options:
-n | --dry-run		Run a dry run of the script (default: off)
-s | --snake-file	Provide the snakefile name (default: $Snakefile)
-j | --jobs		Number of concurrent jobs to run (default: 1)
-t | --target		Target file/rule (default: none)
-d | --dag		Print the dag and exit (default: off)
-m | --highmem		Submit this pipeline using the highmem nodes (default: off)
-r | --rulegraph	Print the rule graph and exit (default: off)
-f | --dag-file		The file name for the dag (default: dag.svg)
-c | --conda_location	The location to store conda environments (default: $conda_envs)
-q | --scheduler	The job scheduler to use (default: $scheduler)
-e | --extra		Takes all remaining arguments and passes them to snakemake (MUST BE LAST)
-h | --help		Display this message and exit
"
					exit 1
					;;
        esac
        shift
done

if [ $DAG -eq 1 ]; 
then
	snakemake --dag \
		$target \
		$EXTRA \
		-s $Snakefile  | 
		dot -Tsvg > $dagFile
elif [ $RULEGRAPH -eq 1 ]; then 
	snakemake --rulegraph \
		-F \
		$EXTRA \
		-s $Snakefile  | 
		dot -Tsvg > $dagFile
elif [ $scheduler == "slurm" ]; then
	snakemake \
		$Dry \
		-s $Snakefile \
		$target \
		-p --executor slurm \
		--default-resources \
		-j $Jobs \
		--software-deployment-method conda \
		--conda-prefix $conda_envs \
		$EXTRA
elif [ $scheduler == "sge" ]; then
	snakemake \
		$Dry \
		-s $Snakefile \
		$target \
		-p --executor cluster-generic \
		--cluster-generic-submit-cmd \
		"qsub -V -l h_rt=24:0:0 -l h_vmem={params.mem} ${HIGHMEM} -pe smp {threads} ${join} -cwd -o {log}.jobscript -l ${OS}" \
		-j $Jobs \
		--software-deployment-method conda \
		--conda-prefix $conda_envs \
		$EXTRA
else
	echo "Do I look like I know what a dang ${scheduler} is!"

fi

