
SMOPS soil moisture

Download information: SMOPS data was first downloaded from https://www.avl.class.noaa.gov/saa/products/search%3Fsub_id%3D0%26datatype_family%3DSMOPS, and then a shell script was used to extracted belended soil moisture and uncertainty only to reduce data size.

Daily data for 2018 - 2022

Data are on a regular 0.25 degree global grid.

To regrid to different grids, use the following steps:

1. run create_smops_scrip.ncl
	only needs to be done once, stored in /scratch2/NCEPDEV/land/data/evaluation/SMOPS

2. use existing destination grid scrip files in /scratch2/NCEPDEV/land/data/evaluation/domains

3. create weights file

run from data/evaluations/SMOPS/CXXX directory

Create a bilinear weight file for each destination
	
ESMF_RegridWeightGen --ignore_degenerate --source ../smops_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96/fix_20231027/C96_SCRIP.nc \
       --weight SMOPS-C96_bilinear_wts.nc --method bilinear --extrap_method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../smops_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96_conus/fix_20231027/C96_conus_SCRIP.nc \
       --weight SMOPS-C96_conus_bilinear_wts.nc --method bilinear --extrap_method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../smops_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C384/fix_20231027/C384_SCRIP.nc \
       --weight SMOPS-C384_bilinear_wts.nc --method bilinear --extrap_method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../smops_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C768/fix_20231027/C768_SCRIP.nc \
       --weight SMOPS-C768_bilinear_wts.nc --method bilinear --extrap_method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../smops_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C1152/fix_20231027/C1152_SCRIP.nc \
       --weight SMOPS-C1152_bilinear_wts.nc --method bilinear --extrap_method neareststod

For the prototype grid

ESMF_RegridWeightGen --ignore_degenerate --source ../smops_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype_SCRIP.nc \
       --weight SMOPS-prototype_bilinear_wts.nc --method bilinear --extrap_method neareststod

For the hr grid

ESMF_RegridWeightGen --ignore_degenerate --source ../smops_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr_SCRIP.nc \
       --weight SMOPS-hr_bilinear_wts.nc --method bilinear --extrap_method neareststod


4. regrid step

/test contains an ncl regrid script to test if the C96 scrip is correct, use view_C96.ncl to visualize

For each individual cgrid type, C96_conus, C96, C384, C768, C1152, hr, and prototype, go to that directory, do "make clean" if excutable file exists. After that, do "make" to build the excuetable, and then run script interactively or submit a job via copying submit_regrid.sh to that directory.

Michael Barlage and Youlong Xia, NCEP/EMC, 18 January 2024




