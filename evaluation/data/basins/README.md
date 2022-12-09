
Global Major River Basins

https://www.bafg.de/GRDC/EN/02_srvcs/22_gslrs/221_MRB/riverbasins_node.html

Downloaded as shapefile and converted to netcdf raster using gdal:

`gdal_rasterize -a MRBID -l mrb_basins -a_srs '+proj=latlong +datum=WGS84' -te -180 -90 180 90 -ts 3600 1800 -ot Int16 -of netcdf mrb_basins.shp world_basins.nc`

This produces a 0.1 degree basin mask globally.
