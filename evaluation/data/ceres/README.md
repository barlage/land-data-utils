
CERES surface radiation budget estimates

https://ceres.larc.nasa.gov/data

Retrieved radiation data from Lydia
Ancillary data downloaded separately

Daily data for 20110401 - 20231231

Data are on a regular 1.00 degree global grid.

stored: /scratch2/NCEPDEV/land/data/evaluation/CERES/orig

To regrid to different grids, use the following steps:

1. run create_ceres_scrip.ncl
	only needs to be done once, stored in /scratch2/NCEPDEV/land/data/evaluation/CERES

2. use existing destination grid scrip files in /scratch2/NCEPDEV/land/data/evaluation/domains

3. create weights file

run from /scratch2/NCEPDEV/land/data/evaluation/CERES/CXXX directory

Create a bilinear for C96
	
ESMF_RegridWeightGen --ignore_degenerate --source ../ceres_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96/C96_SCRIP.nc \
       --weight CERES-C96_bilinear_wts.nc --method bilinear --extrap_method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../ceres_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96_conus/C96_conus_SCRIP.nc \
       --weight CERES-C96_conus_bilinear_wts.nc --method bilinear --extrap_method neareststod

For C384 and C786, only create a bilinear version
	
ESMF_RegridWeightGen --ignore_degenerate --source ../ceres_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C384/C384_SCRIP.nc \
       --weight CERES-C384_bilinear_wts.nc --method bilinear --extrap_method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../ceres_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C768/C768_SCRIP.nc \
       --weight CERES-C768_bilinear_wts.nc --method bilinear --extrap_method neareststod

For the prototype grid

ESMF_RegridWeightGen --ignore_degenerate --source ../ceres_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype_SCRIP.nc \
       --weight CERES-prototype_bilinear_wts.nc --method bilinear --extrap_method neareststod

For the hr grid

ESMF_RegridWeightGen --ignore_degenerate --source ../ceres_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr_SCRIP.nc \
       --weight CERES-hr_bilinear_wts.nc --method bilinear --extrap_method neareststod


4. run regrid_ceres_daily.ncl in ./CXXX directory or ./prototype or ./hr directory

this will regrid the data, manually adjust for dates

for hr, only do 2019-2021

5. can do a quick check using e.g., view_C96.ncl or ncview prototype or hr grid

6. compress after creation using

find . -name 'CERES_v3.6*' | xargs -L 1 -I {} -t ncks -O -4 -L 1 {} {}

