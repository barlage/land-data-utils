#!/bin/sh -l
#
# -- Request n cores
#SBATCH --ntasks=1
#
# -- Specify queue
#SBATCH -q debug
#
# -- Specify under which account a job should run
#SBATCH --account=fv3-cpu
#
# -- Set the name of the job, or Slurm will default to the name of the script
#SBATCH --job-name=ufs-land-input
#
# -- Tell the batch system to set the working directory to the current working directory
#SBATCH --chdir=.
#
# -- Specify a maximum wallclock
# -- C96  : ~1 minute
# -- C192 : ~1 minute
# -- C384 : ~2 minutes
# -- C768 : ~6 minutes
# -- C1152: ~15 minutes
#
#SBATCH --time=0:01:00

module purge
module load ncl/6.6.2

# set parameters for grid generation
#
# atm_res      : fv3 grid resolution
# ocn_res      : ocean resolution
# grid_version : hr3 - append directory date string (not supporting other options for now)
# fixfile_path : top level path for fix files
# grid_extent  : global or conus

atm_res="C96"
ocn_res="mx100"
grid_version="hr3"
fixfile_path="/scratch1/NCEPDEV/global/glopara/fix/orog/"
grid_extent="global"

#################################################################################
#  shouldn't need to modify anything below
#################################################################################

# set full fix file based on grid version

if [ $grid_version = "hr3" ]; then 
  fixfile_path=$fixfile_path"20231027/"
else
  echo "ERROR: unknown fixfile_path $fixfile_path"
  exit 1
fi

# the default location for output files is $atm_res.$ocn_res

if [ $grid_extent = "global" ]; then 
  output_path=$atm_res.$ocn_res"/"
else
  output_path=$atm_res.$ocn_res.$grid_extent"/"
fi

if [ -d $output_path ]; then 
  echo "ERROR: directory $output_path exists and overwriting is prevented"
  echo "ERROR: remove $output_path and resubmit"
  exit 2
else
  mkdir -p $output_path
fi

# create the strings for the ncl command line

cmdparm="'atm_res="\"$atm_res"\"' "
cmdparm=$cmdparm"'ocn_res="\"$ocn_res"\"' "
cmdparm=$cmdparm"'grid_version="\"$grid_version"\"' "
cmdparm=$cmdparm"'output_path="\"$output_path"\"' "
cmdparm=$cmdparm"'fixfile_path="\"$fixfile_path"\"' "
cmdparm=$cmdparm"'grid_extent="\"$grid_extent"\"' "

echo "variable list sent to NCL"
echo $cmdparm

# create the grid corners file, this is used in follow-on ncl scripts and for other tools

eval "time ncl extract_corners.ncl $cmdparm"

# create the static fields file, this is used to create the inputs to the driver

eval "time ncl extract_static.ncl $cmdparm"

# create the SCRIP file, this is used for ESMF regridding

eval "time ncl create_scrip.ncl $cmdparm"


