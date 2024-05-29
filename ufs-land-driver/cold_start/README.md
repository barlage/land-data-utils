# cold start initial conditions

To conduct a simulation from a somewhat arbitary set of initial conditions, run this script to get the cold start initial condition file based on:
- grid definition
- source data for temperature
- simulation start date

The date stamp on the file will be one timestep before the simulation start date.

Modify `create_cold_start.sh` for your case. Submit script using:

`sbatch create_cold_start.sh`

Some standard grids and times may already be created here:

`/scratch2/NCEPDEV/land/data/ufs-land-driver/cold_start`

 set parameters for weights generation
 
`atm_res`      : fv3 grid resolution [C48,C96,C192,C384,C768,C1152] 

`ocn_res`      : ocean resolution [mx500,mx100,mx050,mx025] 

`grid_version` : fix file options [hr3] (only "hr3" = 20231027 fix files for now) 

`grid_extent`  : grid options [global,conus] (for now, only a hard-coded conus (25-53N,235-293E) option is available) 

`datm_source`  : data atmosphere source [ERA5,GDAS,CDAS]

`datm_source_path` : base path where datm already exists, e.g., "/scratch2/NCEPDEV/land/data/ufs-land-driver/datm/ERA5/" 

`static_file_path` : ufs-land-driver static file path (created in Step 1), e.g., `"/scratch2/NCEPDEV/land/data/ufs-land-driver/vector_inputs/"` 

`interpolation_method` : ESMF regrid method [bilinear,neareststod,nearestdtos,conserve]

`yyyy` : year of desired cold start initial condition, e.g., 1999 

`mm` : month of desired cold start initial condition, e.g., 1 

`dd` : day of desired cold start initial condition, e.g., 1 

`hh` : hour of desired cold start initial condition, e.g., 0 

`timestep` : model timestep in minutes, e.g., 60 

Outputs in current directory `atm_res`.`ocn_res` (`C96.mx100` example):
