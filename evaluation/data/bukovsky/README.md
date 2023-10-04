
Bukovsky regions

https://www.narccap.ucar.edu/contrib/bukovsky/

combine_bukovsky.ncl : combine the region files into one using region numbers
  stored in /scratch2/NCEPDEV/land/data/evaluation/BUKOVSKY/combined

To regrid to different grids, use the following steps:

1. run create_bukovsky_scrip.ncl
	only needs to be done once, stored in /scratch2/NCEPDEV/land/data/evaluation/BUKOVSKY

2. use existing destination grid scrip files in /scratch2/NCEPDEV/land/data/evaluation/domains

3. create weights file

run from data/evaluations/BUKOVSKY/CXXX directory
	
ESMF_RegridWeightGen --ignore_degenerate --source ../bukovsky_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96/C96_SCRIP.nc \
       --weight BUKOVSKY-C96_nearest_wts.nc --method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../bukovsky_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96_conus/C96_conus_SCRIP.nc \
       --weight BUKOVSKY-C96_conus_nearest_wts.nc --method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../bukovsky_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C384/C384_SCRIP.nc \
       --weight BUKOVSKY-C384_nearest_wts.nc --method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../bukovsky_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C768/C768_SCRIP.nc \
       --weight BUKOVSKY-C768_nearest_wts.nc --method neareststod

run from data/evaluations/BUKOVSKY/prototype directory
	
ESMF_RegridWeightGen --ignore_degenerate --source ../bukovsky_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype_SCRIP.nc \
       --weight BUKOVSKY-prototype_nearest_wts.nc --method neareststod

run from data/evaluations/BUKOVSKY/hr directory
	
ESMF_RegridWeightGen --ignore_degenerate --source ../bukovsky_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr_SCRIP.nc \
       --weight BUKOVSKY-hr_nearest_wts.nc --method neareststod

4. run regrid_bukovsky.ncl in ./CXXX or ./prototype or ./hr directory
