
; SMOPS has no lat/lon information in the file so create manually

begin

 scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/SMOPS/smops_SCRIP.nc"

;************************************************
; get pts fields
;************************************************

  lat = fspan(89.875,-89.875,720)
   lat@units = "degrees_north"
  lon = fspan(-179.875,179.875,1440)
   lon@units = "degrees_east"

  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "SMOPS Grid"

  rectilinear_to_SCRIP(scrip_filename,lat,lon,Opt)

end
