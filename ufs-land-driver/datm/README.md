# create data atmosphere (datm) files

Modify `create_datm_files.sh` for your case. Submit script using:

`sbatch create_datm_files.sh`

Some standard grids may already be created here:

`/scratch2/NCEPDEV/land/data/ufs-land-driver/datm`

 set parameters for datm generation
 
`atm_res`      : fv3 grid resolution [C48,C96,C192,C384,C768,C1152] 

`ocn_res`      : ocean resolution [mx500,mx100,mx050,mx025] 

`grid_version` : fix file options [hr3] (only "hr3" = 20231027 fix files for now) 

`grid_extent`  : grid options [global,conus] (for now, only a hard-coded conus (25-53N,235-293E) option is available) 

`datm_source`  : data atmosphere source [ERA5,GDAS,CDAS]

`datm_source_path` : datm_source files path, e.g., `"/scratch2/NCEPDEV/land/data/ufs-land-driver/datm/ERA5/orig/" `

`elevation_source_filename` : source data elevation file, e.g., `"/scratch2/NCEPDEV/land/data/ufs-land-driver/datm/ERA5/elevation/e5.oper.invariant.128_129_z.ll025sc.1979010100_1979010100.nc"`

`weights_path` : weights files path (created in Step 2), e.g., `"/scratch2/NCEPDEV/land/data/ufs-land-driver/weights/"`

`interpolation_method` : ESMF regrid method [bilinear,neareststod,nearestdtos,conserve]

`static_file_path` : ufs-land-driver static file path (created in Step 1), e.g., `"/scratch2/NCEPDEV/land/data/ufs-land-driver/vector_inputs/"` 

`regrid_tasks_file` : file with all the individual commands to create datm files, e.g., `"regrid-tasks.1990-2009.ERA5"` 

Outputs in current directory `atm_res`.`ocn_res` (`C96.mx100` example):

`ERA5-C96.mx100_hr3_datm_2009-07-01.nc` :
* atmospheric forcing from ERA5 regrid to C96.mx100_hr3 vector for 2009-07-01
