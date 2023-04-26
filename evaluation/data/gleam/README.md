
GLEAM water budget estimates

https://www.gleam.eu

Downloaded v3.6a and v3.6b using sftp

    Actual Evaporation (E) 
    Soil Evaporation (Eb)  
    Interception Loss (Ei)
    Potential Evaporation (Ep) 
    Snow Sublimation (Es)
    Transpiration (Et)
    Open-Water Evaporation (Ew)
    Evaporative Stress (S)
    Root-Zone Soil Moisture (SMroot)
    Surface Soil Moisture (SMsurf)

Daily data for 2011 - 2021
Monthly data from 1980 - 2021 (v3.6a) and 2003 - 2021 (v3.6b)

Data are on a regular 0.25 degree global grid.

To regrid to different grids, use the following steps:

1. run create_gleam_scrip.ncl
	only needs to be done once, stored in /scratch2/NCEPDEV/land/data/evaluation/GLEAM

2. use existing destination grid scrip files in /scratch2/NCEPDEV/land/data/evaluation/domains

3. create weights file

run from data/evaluations/GLEAM/CXXX directory

Create a bilinear and conservative for C96; can merge them to possibly get a better estimate
	
ESMF_RegridWeightGen --ignore_degenerate --source ../gleam_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96/C96_SCRIP.nc \
       --weight GLEAM-C96_bilinear_wts.nc --method bilinear --extrap_method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../gleam_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96/C96_SCRIP.nc \
       --weight GLEAM-C96_conserve_wts.nc --method conserve --ignore_unmapped

For C384 and C786, only create a bilinear version
	
ESMF_RegridWeightGen --ignore_degenerate --source ../gleam_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C384/C384_SCRIP.nc \
       --weight GLEAM-C384_bilinear_wts.nc --method bilinear --extrap_method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../gleam_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C768/C768_SCRIP.nc \
       --weight GLEAM-C768_bilinear_wts.nc --method bilinear --extrap_method neareststod

For the prototype grid

ESMF_RegridWeightGen --ignore_degenerate --source ../gleam_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype_SCRIP.nc \
       --weight GLEAM-prototype_bilinear_wts.nc --method bilinear --extrap_method neareststod

For the hr grid

ESMF_RegridWeightGen --ignore_degenerate --source ../gleam_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr_SCRIP.nc \
       --weight GLEAM-hr_bilinear_wts.nc --method bilinear --extrap_method neareststod


4. run regrid_gleam_monthly.ncl in ./CXXX directory or ./prototype or ./hr directory

run the script separately for v3.6a and v3.6b by commently lines

this will regrid the data from 2011 for both versions

5. can do a quick check using e.g., view_C96.ncl or ncview prototype grid

6. compress after creation using

find . -name 'GLEAM_v3.6*' | xargs -L 1 -I {} -t ncks -O -4 -L 1 {} {}

