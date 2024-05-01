# vector_inputs

Modify `create_inputs.sh` for your case. Submit script using:

`sbatch create_inputs.sh`

Some standard grids may already be created here:

`/scratch2/NCEPDEV/land/data/ufs-land-driver/vector_inputs`

 set parameters for grid generation
 
`atm_res`      : fv3 grid resolution [C48,C96,C192,C384,C768,C1152] 

`ocn_res`      : ocean resolution [mx500,mx100,mx050,mx025] 

`grid_version` : fix file options [hr3] (only "hr3" = 20231027 fix files for now) 

`fixfile_path` : top level path for fix files, e.g., "/scratch1/NCEPDEV/global/glopara/fix/orog/" 

`grid_extent`  : grid options [global,conus] (for now, only a hard-coded conus (25-53N,235-293E) option is available) 

Outputs in current directory `atm_res`.`ocn_res` (`C96.mx100` example):

`ufs-land_C96.mx100_hr3_corners.nc` : 
* contains lat/lon of grid centers and corners organized in vector
* vector is organized from tile 1 to 6 starting in lower-left corner with x-dimension faster-varying

`ufs-land_C96.mx100_hr3_static_fields.nc` :
* contains fix file inputs put into vector format, a necessary input for the ufs-land-driver

`ufs-land_C96.mx100_hr3_SCRIP.nc` :
* contains SCRIP "unstructured" format information used for ESMF regridding

`ufs-land_C96.mx100_hr3_SCRIP_veg.nc` :
* contains SCRIP "unstructured" format information for vegetated grids used for ESMF regridding
* this and the following two are used for regridding vectors between resolutions to make certain grids are consistently matched (veg->veg, bare->bare, snow/ice->snow/ice)

`ufs-land_C96.mx100_hr3_SCRIP_bare.nc`   :
* contains SCRIP "unstructured" format information for bare grids used for ESMF regridding

`ufs-land_C96.mx100_hr3_SCRIP_snow.nc`   :
* contains SCRIP "unstructured" format information for snow/ice grids used for ESMF regridding
