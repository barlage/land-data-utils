#!/bin/bash

#SBATCH --job-name=fv3_mapping
#SBATCH -t 00:10:00
#SBATCH -A fv3-cpu
#SBATCH -q batch
#SBATCH -o create_fv3_mapping.out
#SBATCH -e create_fv3_mapping.out
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1

module purge
module use /scratch1/NCEPDEV/nems/role.epic/spack-stack/spack-stack-1.6.0/envs/unified-env-rocky8/install/modulefiles/Core
module load stack-intel/2021.5.0 
module load stack-intel-oneapi-mpi/2021.5.1 
module load netcdf-hdf5parallel/4.7.4 

make

./create_fv3_mapping.exe

make clean
