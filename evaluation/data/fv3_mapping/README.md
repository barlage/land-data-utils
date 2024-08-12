# Code to create file that maps between source lat/lon pairs and FV3 tiles 

Steps:

1. Edit Fortran code `create_fv3_mapping.f90`. Note that submit script (step 3) will compile.

The code should not need to be edited for most FV3 applications. There are a few hard-coded options that could be changed:

```
include_source_latlon      = .false.    ! put the source latlon in the mapping file
include_fv3_orography      = .false.    ! put the source orography in the mapping file
perturb_value              = 1.d-4      ! a small adjustment to lat/lon to find [radians]
quick_search_pad           = 1          ! do a first search +/- this many grids around the current
fv3_search_order(7) = (/3,1,2,5,6,4,0/) ! do the general search in this order, logical choice is most land first
                                        ! 7th element is to trick the regional option
```

- If you want source latitude and longitude or orography in the mapping file, set them to `.true.`
- `perturb_value` or `quick_search_pad` could be increased if grids are not being found
- `fv3_search_order` can be change if you are not using the standard tile setup

2. Edit input namelist `fv3_mapping.nml` for your case.

```
atm_resolution    : FV3 atmosphere resolution, e.g., 96 for C96
ocn_resolution    : FV3 ocean resolution, e.g., 100 for mx100, -1 for no ocean
number_of_tiles   : number of FV3 tiles: 6 for global, 1 for regional
fv3_file_path     : path to FV3 grid and orography files
source_path       : path to source lat/lon file
source_lat_name   : name of latitude variable in source file
source_lon_name   : name of longitude variable in source file
source_dim1_name  : 1st dimension name in source file, e.g., idim,lat,etc.
source_dim2_name  : 2nd dimension name in source file, e.g., jdim,lon,etc.
source_name       : name used in mapping filename
mapping_file_path : path to save mapping file
```
3. Submit `create_fv3_mapping.sh` possibly changing for your case:
```
#SBATCH -t 00:10:00        : wall clock time to run
#SBATCH -A fv3-cpu         : compute account
#SBATCH -q batch           : for small jobs, could run in debug queue
#SBATCH --partition=bigmem : for large destination and/or source grids, possibly need to use bigmem nodes
```

Sample namelist for C96.mx100 global
```
&fv3_mapping_nml
 atm_resolution    = 96                                                                        ! FV3 atmosphere resolution, e.g., 96 for C96
 ocn_resolution    = 100                                                                       ! FV3 ocean resolution, e.g., 100 for mx100, -1 for no ocean
 number_of_tiles   = 6                                                                         ! number of FV3 tiles: 6 for global, 1 for regional
 fv3_file_path     = "/scratch1/NCEPDEV/global/glopara/fix/orog/20231027/"                     ! path to FV3 grid and orography files
 source_path       = "/scratch2/NCEPDEV/land/data/evaluation/IMS/fix_coords/IMS4km_latlon.nc"  ! path to source lat/lon file
 source_lat_name   = "ims_lat"                                                                 ! name of latitude variable in source file
 source_lon_name   = "ims_lon"                                                                 ! name of longitude variable in source file
 source_dim1_name  = "idim"                                                                    ! 1st dimension name in source file, e.g., idim,lat,etc.
 source_dim2_name  = "jdim"                                                                    ! 2nd dimension name in source file, e.g., jdim,lon,etc.
 source_name       = "IMS4km"                                                                  ! name used in mapping filename
 mapping_file_path = "/scratch2/NCEPDEV/land/data/evaluation/IMS/fix_20231027/index_files/"    ! path to save mapping file
/
```
