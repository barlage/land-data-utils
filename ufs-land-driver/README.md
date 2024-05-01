# ufs-land-driver input

Collection of scripts and instructions for creating inputs to ufs-land-driver. 

Structure:
- `vector_inputs` : scripts for creating one-time inputs for ufs-land-driver
- `weights` : scripts for creating regrid weights files
- `forcing` : scripts for creating atmospheric forcing in vector format
- `initial` : scripts for ufs-land-driver cold start initial conditions

Step 1: create one-time inputs for the ufs-land-driver and follow-on processing scripts in `vector_inputs/`

Step 2: create one-time ESMF weights file for regridding data atmosphere source to vector format in `weights/`
