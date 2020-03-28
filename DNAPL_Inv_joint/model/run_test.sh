#!/bin/sh
#
################################################################################
# 
### EXAMPLE MPICH SCRIPT FOR SGE
### To use, change "MPICH_JOB", "NUMBER_OF_CPUS" 
### and "MPICH_PROGRAM_NAME" to real values. 
#
################################################################################
#
### Run job through bash shell
#$ -S /bin/bash
#
### Your job name 
#$ -N comsol
#
### Use current working directory
#$ -cwd
#
### Join stdout and stderr
#$ -j y
#
#
### Submits to queue designated by <queue_name>.
#$ -q  hydro.q 
#
### pe request for MPICH. Set your number of processors here. 
### Make sure you use the "mpich" parallel environemnt.
## #$ -pe mpich NUMBER_OF_CPUS
#$ -pe mpich 8
#
### The following is for reporting only. It is not really needed
### to run the job. It will show up in your output file.
## echo "Got $NSLOTS processors."
## echo "Machines:"
## cat $TMPDIR/machines
#
### Use full pathname to make sure we are using the right mpirun
comsol server -np 8 -silent -port 2036 -tmpdir temporary_files1 &
sleep 30s
matlab -nodisplay -r three_D_aquifer_joint