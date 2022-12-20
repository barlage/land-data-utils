
; in p8 the lat is flipped from the example of p7
; you need a prototype sflux file to extract the lats and lons

begin

proto_filename = "gfs.t00z.sfluxgrbf000.grib2"
pt_file  = addfile(proto_filename, "r")
lat1d = pt_file->lat_0
lon1d = pt_file->lon_0
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

  print(getfilevarnames(pt_file))

  indata = (/ pt_file->VGTYP_P0_L1_GGA0 /)
  vdata = tointeger(indata)

  indata = (/ pt_file->SOTYP_P0_L1_GGA0 /)
  sdata = tointeger(indata)

  outname = "/scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype8_vegsoil.nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->lat = lat
  outfile->lon = lon
  outfile->vegetation_type = vdata
  outfile->soil_type = sdata
  

end

