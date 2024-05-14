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
## Target rule/file?
target=""
## Extra options?
EXTRA=""
###################################

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
		-e | --extra )		shift
					EXTRA=$1
					;;
		-h | --help )		echo -e "
A script for running OkosunLab snakemake files on apocrita (should work on almost any SGE based system too)
Written by: Findlay Bewicke-Copley
Last Updated: 01/05/2024

Options:
-n | --dry-run		Run a dry run of the script
-s | --snake-file	Provide the snakefile name (default: $Snakefile)
-j | --jobs		Number of concurrent jobs to run
-t | --target		Target file/rule
-d | --dag		Print the dag and exit 
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
		-s $Snakefile  | 
		dot -Tsvg > dag.svg
else
	snakemake \
		$Dry \
		-s $Snakefile \
		$target \
		-p --executor cluster-generic \
		--cluster-generic-submit-cmd \
		"qsub -V -l h_rt=240:0:0 -l h_vmem={params.mem} -pe smp {threads} -j y -cwd -o {log}.jobscript" \
		-j $Jobs \
		--software-deployment-method conda $EXTRA

fi

