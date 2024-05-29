# ufs-land-driver input

Collection of scripts and instructions for creating inputs to ufs-land-driver. 

Structure:
- `vector_inputs` : scripts for creating one-time inputs for ufs-land-driver
- `weights` : scripts for creating regrid weights files
- `datm` : scripts for creating data atmospheric forcing in vector format
- `cold_start` : scripts for ufs-land-driver cold start initial conditions

Step 1: create one-time inputs for the ufs-land-driver and follow-on processing scripts in `vector_inputs/`

Step 2: create one-time ESMF weights file for regridding data atmosphere source to vector format in `weights/`

Step 3: regrid existing 2D (lat-lon) source data (GDAS,ERA5,etc.) to vector format in `datm/`

Step 4: create cold start initial conditions in `cold_start/`
