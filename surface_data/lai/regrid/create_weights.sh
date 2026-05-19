#!/bin/sh -l
#
# -- Request n cores
#SBATCH --ntasks=2
#
# -- Specify queue
#SBATCH -q debug
#
# -- Specify a maximum wallclock
#SBATCH --time=0:05:00
#
# -- Specify under which account a job should run
#SBATCH --account=fv3-cpu
#
# -- Set the name of the job, or Slurm will default to the name of the script
#SBATCH --job-name=regrid_weights
#
# -- Tell the batch system to set the working directory to the current working directory
#SBATCH --chdir=.

module purge
module use /contrib/spack-stack/spack-stack-1.9.2/envs/ue-oneapi-2024.2.1/install/modulefiles/Core
module load stack-oneapi/2024.2.1
module load stack-intel-oneapi-mpi/2021.13
module load esmf/8.8.0
module load ncl/6.6.2

atm_res="C96"
ocn_res="mx100"
grid_version="hr3"
data_source="CERES"
data_source_file="/scratch4/NCEPDEV/land/data/evaluation/CERES/yearly/CERES_radiation_2011.nc"
interpolation_method="neareststod"
destination_scrip_path="/scratch4/NCEPDEV/land/data/ufs-land-driver/vector_inputs/"
grid_extent="global"

#################################################################################
#  shouldn't need to modify anything below
#################################################################################

# create scrip file for data atmosphere sources, will replace existing file

data_scrip_file=$data_source"_SCRIP.nc"

cmdparm="'data_scrip_file="\"$data_scrip_file"\"' "
cmdparm=$cmdparm"'data_source_file="\"$data_source_file"\"' "

echo "variable list sent to NCL"
echo $cmdparm

eval "time ncl create_ceres_scrip.ncl $cmdparm"

# the default location for output files is $atm_res.$ocn_res

if [ $grid_extent = "global" ]; then 
  res=$atm_res.$ocn_res
else
  res=$atm_res.$ocn_res.$grid_extent
fi

grid=$res"_hr3"
output_path=$res"/"
weights_filename=$data_source"-"$grid"_"$interpolation_method"_wts.nc"
destination_scrip_file=$destination_scrip_path"/"$res"/ufs-land_"$grid"_SCRIP.nc"

if [ -d $output_path ]; then 
  echo "BEWARE: output_path directory exists and overwriting is allowed"
else
  mkdir -p $output_path
fi

# create weights file

echo "Creating weights file: "$weights_filename

srun -n $SLURM_NTASKS time ESMF_RegridWeightGen --netcdf4 --ignore_degenerate \
       --source $data_scrip_file \
       --destination $destination_scrip_file \
       --weight $output_path$weights_filename --method $interpolation_method

rm $data_scrip_file
