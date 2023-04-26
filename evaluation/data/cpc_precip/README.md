
CPC Precipitation

https://psl.noaa.gov/data/gridded/data.cpc.globalprecip.html

Spatial/temporal res: 0.5°, daily

Scripts to create annual and monthly totals:

create_cpc_yearly.perl
create_cpc_monthly.perl

Note: dataset uses missing_value, but NCO needs _FillValue to do proper masking during calculation

To regrid to different grids, use the following steps:

1. run create_cpc_scrip.ncl
	only needs to be done once, stored in /scratch2/NCEPDEV/land/data/evaluation/cpc_precip

2. use existing destination grid scrip files in /scratch2/NCEPDEV/land/data/evaluation/domains

3. create weights file

run from data/evaluations/basins/CXXX directory
	
ESMF_RegridWeightGen --ignore_degenerate --source ../cpc_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96/C96_SCRIP.nc \
       --weight CPC-C96_nearest_wts.nc --method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../cpc_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C384/C384_SCRIP.nc \
       --weight CPC-C384_nearest_wts.nc --method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../cpc_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C768/C768_SCRIP.nc \
       --weight CPC-C768_nearest_wts.nc --method neareststod

run from data/evaluations/basins/prototype directory
	
ESMF_RegridWeightGen --ignore_degenerate --source ../cpc_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype_SCRIP.nc \
       --weight CPC-prototype_nearest_wts.nc --method neareststod

4. run the following scripts in ./CXXX or ./prototype directory

ncl regrid_cpc_precip_monthly.ncl
ncl regrid_cpc_precip_monthly.ncl
