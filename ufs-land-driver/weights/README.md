# weights

Modify `create_weights.sh` for your case. Submit script using:

`sbatch create_weights.sh`

Some standard grids may already be created here:

`/scratch2/NCEPDEV/land/data/ufs-land-driver/weights`

 set parameters for weights generation
 
`atm_res`      : fv3 grid resolution [C48,C96,C192,C384,C768,C1152] 

`ocn_res`      : ocean resolution [mx500,mx100,mx050,mx025] 

`grid_version` : fix file options [hr3] (only "hr3" = 20231027 fix files for now) 

`datm_source`  : data atmosphere source [ERA5,GDAS,CDAS]

`datm_source_file` : a single datm_source file, e.g., "/scratch2/NCEPDEV/land/data/ufs-land-driver/datm/ERA5/orig/ERA5_forcing_2022-12-31.nc" 

`interpolation_method` : ESMF regrid method [bilinear,neareststod,nearestdtos,conserve]

`destination_scrip_path` : destination SCRIP path, e.g., "/scratch2/NCEPDEV/land/data/ufs-land-driver/vector_inputs/" 

`grid_extent`  : grid options [global,conus] (for now, only a hard-coded conus (25-53N,235-293E) option is available) 

Outputs in current directory `atm_res`.`ocn_res` (`C96.mx100` example):

`ERA5-C96.mx100_hr3_bilinear_wts.nc` :
* contains ESMF weights to regrid gridded ERA5 to C96.mx100_hr3 vector using bilinear interpolation

