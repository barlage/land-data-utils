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

source_restart="ufs_land_restart.2024-12-01_00-00-00.nc"
destination_restart_start="ufs_land_restart"
destination_restart_end="2024-12-01_00-00-00.nc"
source_atm_res="C768"
source_ocn_res="mx025"
destination_atm_res="C1152"
destination_ocn_res="mx025"
grid_version="hr3"
interpolation_method="neareststod"
scrip_path="/scratch4/NCEPDEV/land/data/ufs-land-driver/vector_inputs/"
static_path="/scratch4/NCEPDEV/land/data/ufs-land-driver/vector_inputs/"

#################################################################################
#  shouldn't need to modify anything below
#################################################################################

# use existing scrip files from vector_inputs step

source_scrip_file=$scrip_path$datm_source"_SCRIP.nc"

# the default location for output files is $res

source_res=$source_atm_res.$source_ocn_res
destination_res=$destination_atm_res.$destination_ocn_res
regrid_res=$source_res"-"$destination_res

grid=$regrid_res"_hr3"
output_path=$regrid_res"/"

destination_restart=$output_path$destination_restart_start.$grid.$destination_restart_end

source_scrip_file=$scrip_path$source_res/"ufs-land_"$source_res"_hr3_SCRIP.nc"
source_veg_scrip_file=$scrip_path$source_res/"ufs-land_"$source_res"_hr3_SCRIP_veg.nc"
source_bare_scrip_file=$scrip_path$source_res/"ufs-land_"$source_res"_hr3_SCRIP_bare.nc"
source_snow_scrip_file=$scrip_path$source_res/"ufs-land_"$source_res"_hr3_SCRIP_snow.nc"

destination_scrip_file=$scrip_path$destination_res/"ufs-land_"$destination_res"_hr3_SCRIP.nc"
destination_veg_scrip_file=$scrip_path$destination_res/"ufs-land_"$destination_res"_hr3_SCRIP_veg.nc"
destination_bare_scrip_file=$scrip_path$destination_res/"ufs-land_"$destination_res"_hr3_SCRIP_bare.nc"
destination_snow_scrip_file=$scrip_path$destination_res/"ufs-land_"$destination_res"_hr3_SCRIP_snow.nc"

weights_filename=$output_path$grid"_"$interpolation_method"_wts.nc"
weights_veg_filename=$output_path$grid"_veg_"$interpolation_method"_wts.nc"
weights_bare_filename=$output_path$grid"_bare_"$interpolation_method"_wts.nc"
weights_snow_filename=$output_path$grid"_snow_"$interpolation_method"_wts.nc"
weights_veg_bare_filename=$output_path$grid"_veg_bare_"$interpolation_method"_wts.nc"

source_static=$static_path$source_res/"ufs-land_"$source_res"_hr3_static_fields.nc"
destination_static=$static_path$destination_res/"ufs-land_"$destination_res"_hr3_static_fields.nc"

if [ -d $output_path ]; then 
  echo "BEWARE: output_path directory exists and overwriting is allowed"
else
  mkdir -p $output_path
fi

# create weights files

echo "Creating weights file: "$weights_filename

srun -n $SLURM_NTASKS time ESMF_RegridWeightGen --netcdf4 --ignore_degenerate \
       --source $source_scrip_file \
       --destination $destination_scrip_file \
       --weight $weights_filename --method $interpolation_method

echo "Creating weights file: "$weights_veg_filename

srun -n $SLURM_NTASKS time ESMF_RegridWeightGen --netcdf4 --ignore_degenerate \
       --source $source_veg_scrip_file \
       --destination $destination_veg_scrip_file \
       --weight $weights_veg_filename --method $interpolation_method \
       --extrap_method neareststod

echo "Creating weights file: "$weights_bare_filename

srun -n $SLURM_NTASKS time ESMF_RegridWeightGen --netcdf4 --ignore_degenerate \
       --source $source_bare_scrip_file \
       --destination $destination_bare_scrip_file \
       --weight $weights_bare_filename --method $interpolation_method \
       --extrap_method neareststod

echo "Creating weights file: "$weights_snow_filename

srun -n $SLURM_NTASKS time ESMF_RegridWeightGen --netcdf4 --ignore_degenerate \
       --source $source_snow_scrip_file \
       --destination $destination_snow_scrip_file \
       --weight $weights_snow_filename --method $interpolation_method \
       --extrap_method neareststod

echo "Creating weights file: "$weights_veg_bare_filename

srun -n $SLURM_NTASKS time ESMF_RegridWeightGen --netcdf4 --ignore_degenerate \
       --source $source_veg_scrip_file \
       --destination $destination_bare_scrip_file \
       --weight $weights_veg_bare_filename --method $interpolation_method \
       --extrap_method neareststod

echo "Regridding restart file $source_restart"

echo "source_restart = $source_restart" > regrid_parameter_assignment
echo "destination_restart = $destination_restart" >> regrid_parameter_assignment
echo "weights_filename = $weights_filename" >> regrid_parameter_assignment
echo "weights_veg_filename = $weights_veg_filename" >> regrid_parameter_assignment
echo "weights_bare_filename = $weights_bare_filename" >> regrid_parameter_assignment
echo "weights_snow_filename = $weights_snow_filename" >> regrid_parameter_assignment
echo "weights_veg_bare_filename = $weights_veg_bare_filename" >> regrid_parameter_assignment
echo "destination_static = $destination_static" >> regrid_parameter_assignment
echo "source_static = $source_static" >> regrid_parameter_assignment

eval "time ncl regrid_vector_restart.ncl "

rm -f regrid_parameter_assignment
