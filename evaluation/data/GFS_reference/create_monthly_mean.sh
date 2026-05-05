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
#SBATCH --time=0:15:00
#
# -- Specify under which account a job should run
#SBATCH --account=fv3-cpu
#
# -- Set the name of the job, or Slurm will default to the name of the script
#SBATCH --job-name=create_monthly_mean
#SBATCH -o create_monthly_mean.%j.out
#
# -- Tell the batch system to set the working directory to the current working directory
#SBATCH --chdir=.

module purge
module load wgrib2
module load nco

gfs_version="$1"           # 1st argument options: 16, 17
variable2process="$2"      # 2nd argument options: grib name
level2process="$3"         # 3rd argument options: 1, 2, 3, 4, or 0 for non-soil field
day2process="$4"           # 4th argument options: day01, day07, day14

file_preamble="GFSv${gfs_version}.${variable2process}."
data_directory="/scratch5/purged/Zhichang.Guo/"


if [[ $level2process -ne "0" ]]; then
  file_preamble="${file_preamble}level${level2process}." 
fi

workshop_directory="workshop_v${gfs_version}.${day2process}.${variable2process}.level${level2process}"

if [[ -d $workshop_directory ]]; then 
  echo "BEWARE: $workshop_directory directory exists, remove entire directory"
  rm -Rf $workshop_directory
fi
mkdir -p $workshop_directory

dds=(31 28 31 30 31 30 31 31 30 31 30 31)
levels=(":0-0.1" ":0.1-0.4" ":0.4-1" ":1-2")

if [[ $day2process == "day01" ]]; then
  hhhs=(003 006 009 012 015 018 021 024)
elif [[ $day2process == "day07" ]]; then
  hhhs=(147 150 153 156 159 162 165 168)
elif [[ $day2process == "day14" ]]; then
  hhhs=(315 318 321 324 327 330 333 336)
else
  echo "ERROR: unknown day $day2process"
  exit 1
fi

#################################################################################
# set the months to process here
#################################################################################

for yyyy in 2024 2025 2026
do

for mm in 01 02 03 04 05 06 07 08 09 10 11 12
do

  if [[ $gfs_version == "16" ]]; then
    gfs_directory=${data_directory}GFSv16/
  else
    if [[ $yyyy$mm -le "202405" ]]; then
      gfs_directory=${data_directory}RETRO/stream1b/forecast/
    elif [[ $yyyy$mm -le "202411" ]]; then
      gfs_directory=${data_directory}RETRO/stream2/forecast/
    elif [[ $yyyy$mm -le "202505" ]]; then
      gfs_directory=${data_directory}RETRO/stream3/forecast/
    elif [[ $yyyy$mm -le "202511" ]]; then
      gfs_directory=${data_directory}RETRO/stream4/forecast/
    else
      gfs_directory=${data_directory}RETRO/realtime/forecast/
    fi
  fi

  days_in_month=${dds[10#$mm-1]}

  for dd in {01..31}
  do

    dd2check=$((10#${dd}))
    if [[ "$dd2check" -le "$days_in_month" ]]; then

      ic2process="${yyyy}${mm}${dd}"

      if [[ -d ${gfs_directory}${ic2process}00 ]]; then 

        echo "starting extraction: $ic2process from ${gfs_directory}"

        for hhh in "${hhhs[@]}"
        do

          ihh=$((10#${hhh}))

          if [[ $gfs_version == "16" ]]; then
            input_name="${gfs_directory}${ic2process}00/${ic2process}00.pgbf${hhh}.grib2"
          else
            input_name="${gfs_directory}${ic2process}00/${ic2process}00.f${hhh}.grib2"
          fi

          output_yyyymmdd=$(date -d "${ic2process} 00 +$ihh hours" +"%Y%m%d")
          output_hh2=$(date -d "${ic2process} 00 +$ihh hours" +"%H")

          output_yyyymmdd=$(date -d "${output_yyyymmdd} ${output_hh2} -3 hours" +"%Y%m%d")
          output_hh1=$(date -d "${output_yyyymmdd} ${output_hh2} -3 hours" +"%H")

          output_name="${workshop_directory}/${ic2process}.${output_hh1}-${output_hh2}.nc"

          if [[ $level2process == "0" ]]; then
            wgrib2 $input_name | egrep ${variable2process} | wgrib2 -i $input_name -netcdf $output_name
          else
            wgrib2 $input_name | egrep ${variable2process}${levels[10#$level2process-1]} | wgrib2 -i $input_name -netcdf $output_name
          fi

        done  # end of hhh loop
      fi    # directory exist check
    fi    # dd max check
  done  # end of dd loop
done  # end of mm loop
done  # end of yyyy loop

########
# After creating all the files, create the means
########

cd $workshop_directory

for yyyy in 2024 2025 2026
do
for mm in 01 02 03 04 05 06 07 08 09 10 11 12
do

  days_in_month=${dds[10#$mm-1]}

  if [[ -e ${yyyy}${mm}01.00-03.nc ]] && [[ -e ${yyyy}${mm}$days_in_month.21-00.nc ]]; then

#create a monthly mean file from all files

    echo "creating: ${file_preamble}${yyyy}-${mm}.${day2process}.monthly_mean.nc"
    ncra -h ${yyyy}${mm}*.nc ${file_preamble}${yyyy}-${mm}.${day2process}.monthly_mean.nc

#create a monthly mean diurnal cycle file

    ncra -h ${yyyy}${mm}??.00-03.nc diurnal00.nc
    ncra -h ${yyyy}${mm}??.03-06.nc diurnal03.nc
    ncra -h ${yyyy}${mm}??.06-09.nc diurnal06.nc
    ncra -h ${yyyy}${mm}??.09-12.nc diurnal09.nc
    ncra -h ${yyyy}${mm}??.12-15.nc diurnal12.nc
    ncra -h ${yyyy}${mm}??.15-18.nc diurnal15.nc
    ncra -h ${yyyy}${mm}??.18-21.nc diurnal18.nc
    ncra -h ${yyyy}${mm}??.21-00.nc diurnal21.nc

    echo "creating: ${file_preamble}${yyyy}-${mm}.${day2process}.monthly_mean_diurnal_cycle.nc"
    ncrcat -h diurnal*.nc ${file_preamble}${yyyy}-${mm}.${day2process}.monthly_mean_diurnal_cycle.nc
    ncatted -h -a description,global,c,c,'diurnal cycle, first time is 00-03Z average' ${file_preamble}${yyyy}-${mm}.${day2process}.monthly_mean_diurnal_cycle.nc
    ncatted -h -a NCO,global,d,,, ${file_preamble}${yyyy}-${mm}.${day2process}.monthly_mean_diurnal_cycle.nc

    rm diurnal*.nc

  else

    echo "${yyyy}${mm}01.00-03.nc and/or ${yyyy}${mm}$days_in_month.21-00.nc not present"

  fi    # check if first and last file exist

done  # end of mm loop
done  # end of yyyy loop

archive_directory="/scratch4/NCEPDEV/land/data/evaluation/GFS_reference/original/v${gfs_version}/${day2process}/${variable2process}"
if [[ $level2process -ne "0" ]]; then
  archive_directory="${archive_directory}.level${level2process}"
fi
if [[ ! -d $archive_directory ]]; then
  mkdir -p $archive_directory
fi

# move the 2024-03 file before creating the cat file so all leads will have 23 times
if [[ -e ${file_preamble}2024-03.${day2process}.monthly_mean.nc ]]; then
  mv ${file_preamble}2024-03.${day2process}.monthly_mean.nc $archive_directory
fi

echo "creating: ${file_preamble}${day2process}.monthly_mean.nc"

ncrcat -h ${file_preamble}????-??.${day2process}.monthly_mean.nc ${file_preamble}${day2process}.monthly_mean.nc

rm 2*.nc

echo "moving files to: $archive_directory"

mv * $archive_directory

echo "remove workshop directory"

cd ..
rm -Rf $workshop_directory
