#!/bin/bash

#BATCH --job-name=smops_regid
#SBATCH -t 02:30:00
#SBATCH -A bigmem
#SBATCH -A da-cpu
#SBATCH --qos=batch
#SBATCH -o regid.out
#SBATCH -e regrid.out
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1 

./run_smops_soil_moisture.sh



