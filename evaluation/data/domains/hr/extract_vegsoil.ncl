
begin

hr_filename = "path-to-sflux/gfs.t00z.sfluxgrbf000.grib2"
hr_file  = addfile(hr_filename, "r")
lat1d = hr_file->lat_0
lon1d = hr_file->lon_0
  lat = new(dimsizes(lat1d),float)
  lat!0 = "lat"
  lat@units = "degrees_north"
  lat = (/ lat1d /)
  lon = new(dimsizes(lon1d),float)
  lon!0 = "lon"
  lon@units = "degrees_east"
  lon = (/ lon1d /)

  vdata = new((/dimsizes(lat1d),dimsizes(lon1d)/), integer)
    vdata!0 = "lat"
    vdata!1 = "lon"
    vdata&lat = lat
    vdata&lon = lon
  sdata = vdata
  edata = new((/dimsizes(lat1d),dimsizes(lon1d)/), float)
    edata!0 = "lat"
    edata!1 = "lon"
    edata&lat = lat
    edata&lon = lon

  print(getfilevarnames(hr_file))

  indata = (/ hr_file->VGTYP_P0_L1_GGA0 /)
  vdata = tointeger(indata)

  indata = (/ hr_file->SOTYP_P0_L1_GGA0 /)
  sdata = tointeger(indata)

  indata = (/ hr_file->HGT_P0_L1_GGA0 /)
  edata = (/ indata /)

  outname = "/scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr1_vegsoil.nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->vegetation_type = vdata
  outfile->soil_type = sdata
  outfile->elevation = edata
;  outfile->lat = lat
;  outfile->lon = lon
  

end

