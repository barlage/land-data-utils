
# CERES surface radiation budget and cloud estimates

https://ceres.larc.nasa.gov/data

Downloaded 4x radiation, 5x clouds, 2x surface separately

Daily data for 20110101 - most recent

Data are on a regular 1.00 degree global grid.

stored: `/scratch4/NCEPDEV/land/data/evaluation/CERES/original`

see `/scratch4/NCEPDEV/land/data/evaluation/CERES/original/README` for converting to yearly

To regrid to different grids, use the following steps:

1. create weights file

	edit and run `create_weights.sh`
 
 	only needs to be done once, weights file stored in `/scratch4/NCEPDEV/land/data/evaluation/CERES/weights`
	
 	use existing destination grid scrip files in `/scratch4/NCEPDEV/land/data/ufs-land-driver/vector_inputs`
	
	if desired destination grid doesn't exist, use `ufs-land-driver` scripts to create

2. edit and run `regrid_ceres.sh` in `./regrid` directory

3. can do a quick check using e.g., `view_C96.ncl` or ncview prototype or hr grid

