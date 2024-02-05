
CCI soil moisture

https://dap.ceda.ac.uk/neodc/esacci/soil_moisture/data/daily_files/COMBINED/v08.1/

Daily data for 2018 - 2022

Data are on a regular 0.25 degree global grid.

To regrid to different grids, use the following steps:

1. run create_cci_scrip.ncl
	only needs to be done once, stored in /scratch2/NCEPDEV/land/data/evaluation/CCI

2. use existing destination grid scrip files in /scratch2/NCEPDEV/land/data/evaluation/domains

3. create weights file

run from data/evaluations/CCI/CXXX directory

Create a bilinear weight file for each destination
	
ESMF_RegridWeightGen --ignore_degenerate --source ../cci_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96/fix_20231027/C96_SCRIP.nc \
       --weight CCI-C96_bilinear_wts.nc --method bilinear --extrap_method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../cci_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96_conus/fix_20231027/C96_conus_SCRIP.nc \
       --weight CCI-C96_conus_bilinear_wts.nc --method bilinear --extrap_method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../cci_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C384/fix_20231027/C384_SCRIP.nc \
       --weight CCI-C384_bilinear_wts.nc --method bilinear --extrap_method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../cci_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C768/fix_20231027/C768_SCRIP.nc \
       --weight CCI-C768_bilinear_wts.nc --method bilinear --extrap_method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../cci_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C1152/fix_20231027/C1152_SCRIP.nc \
       --weight CCI-C1152_bilinear_wts.nc --method bilinear --extrap_method neareststod

For the prototype grid

ESMF_RegridWeightGen --ignore_degenerate --source ../cci_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype_SCRIP.nc \
       --weight CCI-prototype_bilinear_wts.nc --method bilinear --extrap_method neareststod

For the hr grid

ESMF_RegridWeightGen --ignore_degenerate --source ../cci_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr_SCRIP.nc \
       --weight CCI-hr_bilinear_wts.nc --method bilinear --extrap_method neareststod


4. regrid step

For each individual cgrid type, C96_conus, C96, C384, C768, C1152, hr, and prototype, go to that directory, do "make" to build the excuetable, and then run script interactively or submit a job via copying submit_regrid.sh to that directory.

Michael Barlage and Youlong Xia, NCEP/EMC, 16 January 2024 

