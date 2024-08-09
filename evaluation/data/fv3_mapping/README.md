# Code to create file that maps between source lat/lon pairs and FV3 tiles 

Steps:

1. Edit namelist.

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



Sample namelist for C96.mx100 global

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

