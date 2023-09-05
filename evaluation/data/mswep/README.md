
MSWEP Precipitation

https://www.gloh2o.org/mswep/

Spatial/temporal res: 0.1°, monthly (2010-2022), daily(2019-2022)

Up to 2020365 is "Past", after this date is "NRT"

To regrid to different grids, use the following steps:

1. run create_mswep_scrip.ncl
	only needs to be done once, stored in /scratch2/NCEPDEV/land/data/evaluation/MSWEP

2. use existing destination grid scrip files in /scratch2/NCEPDEV/land/data/evaluation/domains

3. create weights file

run from data/evaluation/MSWEP/CXXX directory
	
ESMF_RegridWeightGen --ignore_degenerate --source ../mswep_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96/C96_SCRIP.nc \
       --weight MSWEP-C96_conserve_wts.nc --method conserve

ESMF_RegridWeightGen --ignore_degenerate --source ../mswep_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C384/C384_SCRIP.nc \
       --weight MSWEP-C384_conserve_wts.nc --method conserve

ESMF_RegridWeightGen --ignore_degenerate --source ../mswep_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C768/C768_SCRIP.nc \
       --weight MSWEP-C768_conserve_wts.nc --method conserve

run from data/evaluation/MSWEP/prototype directory
	
ESMF_RegridWeightGen --ignore_degenerate --source ../mswep_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype_SCRIP.nc \
       --weight MSWEP-prototype_conserve_wts.nc --method conserve

run from data/evaluation/MSWEP/hr directory
	
ESMF_RegridWeightGen --ignore_degenerate --source ../mswep_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr_SCRIP.nc \
       --weight MSWEP-hr_nearest_wts.nc --method neareststod

4. run the following scripts in ./CXXX or ./prototype directory

ncl regrid_mswep_daily.ncl
ncl regrid_mswep_monthly.ncl

5. compress after creation (currently not done because these are pretty small)

find . -name 'mswep_hr*' | xargs -L 1 -I {} -t ncks -O -4 -L 1 {} {}
