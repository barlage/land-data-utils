
SNODAS snow depth and SWE

https://nsidc.org/data/g02158/versions/1

Downloaded unmasked 2013-10 2022-12 on Cheyenne

Including scripts from cheyenne that download and process the data

    liquid_precipitation (E) 
    solid_precipitation
    snow_water_equivalent
    snow_depth

Daily data for 2013-10 to 2022-12

Data are on a regular 30 second ~conus grid.

To regrid to different grids, use the following steps:

1. run create_snodas_scrip.ncl
	only needs to be done once, stored in /scratch2/NCEPDEV/land/data/evaluation/SNODAS

2. use existing destination grid scrip files in /scratch2/NCEPDEV/land/data/evaluation/domains

3. create weights file

run from data/evaluations/SNODAS/CXXX directory

Create a conservative for C96; can merge them to possibly get a better estimate
	
ESMF_RegridWeightGen --ignore_degenerate --source ../snodas_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96_conus/C96_conus_SCRIP.nc \
       --weight SNODAS-C96_conus_conserve_wts.nc --method conserve --ignore_unmapped

4. run regrid_gleam_monthly.ncl in ./CXXX directory or ./prototype or ./hr directory

5. can do a quick check using e.g., view_C96.ncl or ncview prototype or hr grid

6. compress after creation using

find . -name 'snodas_v3.6*' | xargs -L 1 -I {} -t ncks -O -4 -L 1 {} {}

