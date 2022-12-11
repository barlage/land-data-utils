
Create a weights file to use for the GEFS ensemble forcing in the ufs-land-driver

To regrid to different grids, use the following steps:

1. run create_gefs_scrip.ncl
	only needs to be done once, stored in /scratch2/NCEPDEV/land/data/forcing/gefs/weights

2. use existing destination grid scrip files in /scratch2/NCEPDEV/land/data/evaluation/domains

3. create weights file

run from data/forcing/gefs/weights/CXXX directory

ESMF_RegridWeightGen --ignore_degenerate --source ../gefs_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96/C96_SCRIP.nc \
       --weight GEFS-C96_bilinear_wts.nc --method bilinear

ESMF_RegridWeightGen --ignore_degenerate --source ../gefs_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C384/C384_SCRIP.nc \
       --weight GEFS-C384_bilinear_wts.nc --method bilinear

ESMF_RegridWeightGen --ignore_degenerate --source ../gefs_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C768/C768_SCRIP.nc \
       --weight GEFS-C768_bilinear_wts.nc --method bilinear

4. there are a lot of extra fields and non-descriptive variables, so make the file more friendly

perl reformat_weights_file.perl

change file_in and file_out for different resolutions
