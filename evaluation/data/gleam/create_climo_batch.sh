#!/bin/sh -l
#
# -- Request n cores
#SBATCH --partition=u1-service
#SBATCH --ntasks=1
#
# -- Specify queue
#SBATCH -q batch
#
# -- Specify a maximum wallclock
#SBATCH --time=0:05:00
#
# -- Specify under which account a job should run
#SBATCH --account=fv3-cpu
#
# -- Set the name of the job, or Slurm will default to the name of the script
#SBATCH --job-name=create_climo_gleam
#SBATCH -o create_climo_gleam.out
#
# -- Tell the batch system to set the working directory to the current working directory
#SBATCH --chdir=.

module purge
module load nco

gleam_version="v4.2a"
variable2process="E"
data_directory="/scratch4/NCEPDEV/land/data/evaluation/GLEAM/original/monthly/$gleam_version/$variable2process"
output_file=$data_directory/"GLEAM.${gleam_version}.${variable2process}.climatology.2015-2024.nc"

if [ -e $output_file ]; then 
  echo "BEWARE: remove $output_file"
  rm -f $output_file
fi
for mm in {01..12}
do

  imm=$((10#$mm-1))

for yyyy in {2015..2024}
do

#create individual month files

    echo "extracting: ${yyyy}${mm}"
    ncks -h -d time,$imm,$imm $data_directory/${variable2process}_${yyyy}_GLEAM_${gleam_version}_MO.nc ${yyyy}${mm}.nc
    ncks -h -O --mk_rec_dmn time ${yyyy}${mm}.nc ${yyyy}${mm}.nc

done  # end of yyyy loop

#create a monthly mean file

  echo "creating: ${mm}.mean.nc"
  ncra -h *${mm}.nc ${mm}.mean.nc

  rm *${mm}.nc

done  # end of mm loop

ncrcat -h *mean.nc $output_file
ncatted -h -a description,global,c,c,'GLEAM climatology 2015-2024' $output_file
ncap2 -h -O -s 'time=int(time)' $output_file $output_file

rm *mean.nc

