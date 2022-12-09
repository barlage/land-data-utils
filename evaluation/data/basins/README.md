
Global Major River Basins

https://www.bafg.de/GRDC/EN/02_srvcs/22_gslrs/221_MRB/riverbasins_node.html

Downloaded as shapefile and converted to netcdf raster using gdal:

`gdal_rasterize -a MRBID -l mrb_basins -a_srs '+proj=latlong +datum=WGS84' -te -180 -90 180 90 -ts 3600 1800 -ot Int16 -of netcdf mrb_basins.shp world_basins.nc`

This produces a 0.1 degree basin mask globally.

[20221209] gdal not on hera so this was run on cheyenne

To regrid to different grids, use the following steps:

1. run create_grdc_scrip.ncl
	only needs to be done once, stored in /scratch2/NCEPDEV/land/data/evaluation/basins

2. use existing destination grid scrip files in /scratch2/NCEPDEV/land/data/evaluation/domains

3. create weights file

run from data/evaluations/basins/CXXX directory
	
ESMF_RegridWeightGen --ignore_degenerate --source ../grdc_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C96/C96_SCRIP.nc \
       --weight GRDC-C96_nearest_wts.nc --method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../grdc_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C384/C384_SCRIP.nc \
       --weight GRDC-C384_nearest_wts.nc --method neareststod

ESMF_RegridWeightGen --ignore_degenerate --source ../grdc_SCRIP.nc \
       --destination /scratch2/NCEPDEV/land/data/evaluation/domains/C768/C768_SCRIP.nc \
       --weight GRDC-C768_nearest_wts.nc --method neareststod

4. run regrid_grdc.ncl in ./CXXX directory
