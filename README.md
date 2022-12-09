# land-data-utils

Collection of scripts and instructions for manipulating land data and doing land model evaluation. 

Repository structure:
- `evaluation` : scripts for evaluating land model
  - `data` : scripts for creating and regridding eval data
	  - `basins` : scripts to create basin masks
	  - `domains` : scripts to create SCRIP files for destination grids
	  - `gleam` : scripts to regrid GLEAM data
  - `analysis` : scripts for evaluation
    - `water_budget` : 
    - `energy_budget` : scripts to analyze energy budget
- `forcing` : scripts to manipulate and regrid forcing data
  - `gefs` : scripts to create weights file for land model regridding
