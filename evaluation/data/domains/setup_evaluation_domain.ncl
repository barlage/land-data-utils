load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

; the assumption is that there is a sample sflux file in grid_directory
;  a SCRIP and grid information file will be created in grid_directory

grid_name = "v16"
scrip_name = "v16.1536x3072"
grid_directory = "/scratch4/NCEPDEV/land/data/evaluation/domains/v16/"
grid_filename = grid_directory+"sample.gfsv16.grib2"

grid_file  = addfile(grid_filename, "r")
lat1d = grid_file->lat_0
lon1d = grid_file->lon_0
  latitude = new(dimsizes(lat1d),float)
  latitude!0 = "latitude"
  latitude@units = "degrees_north"
  latitude = (/ lat1d /)
  longitude = new(dimsizes(lon1d),float)
  longitude!0 = "longitude"
  longitude@units = "degrees_east"
  longitude = (/ lon1d /)

  vegetation_type = new((/dimsizes(lat1d),dimsizes(lon1d)/), integer)
    vegetation_type!0 = "latitude"
    vegetation_type!1 = "longitude"
    vegetation_type&latitude = latitude
    vegetation_type&longitude = longitude
  soil_type = vegetation_type
  elevation_data = new((/dimsizes(lat1d),dimsizes(lon1d)/), float)
    elevation_data!0 = "latitude"
    elevation_data!1 = "longitude"
    elevation_data&latitude = latitude
    elevation_data&longitude = longitude

  print(getfilevarnames(grid_file))

  indata = (/ grid_file->VGTYP_P0_L1_GGA0 /)
  vegetation_type = tointeger(indata)

  indata = (/ grid_file->SOTYP_P0_L1_GGA0 /)
  soil_type = tointeger(indata)

  indata = (/ grid_file->HGT_P0_L1_GGA0 /)
  elevation_data = (/ indata /)

  outname = grid_directory+grid_name+"_grid_information.nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->vegetation_type = vegetation_type
  outfile->soil_type = soil_type
  outfile->elevation = elevation_data
  
  land_mask = vegetation_type
  land_mask = where(vegetation_type.gt.0,1,0)

  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = grid_name+" evaluation grid with no land mask"

  rectilinear_to_SCRIP(grid_directory+scrip_name+"_nomask_SCRIP.nc",latitude,longitude,Opt)
  
  Opt@GridMask       = land_mask
  Opt@Title          = grid_name+" evaluation grid with land mask"

  rectilinear_to_SCRIP(grid_directory+scrip_name+"_SCRIP.nc",latitude,longitude,Opt)
  delete(Opt)


end

