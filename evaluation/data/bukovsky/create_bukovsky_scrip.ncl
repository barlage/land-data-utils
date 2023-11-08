
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

       bukovsky_filename = "/scratch2/NCEPDEV/land/data/evaluation/BUKOVSKY/combined/bukovsky_regions.nc"
 bukovsky_scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/BUKOVSKY/bukovsky_SCRIP.nc"


;************************************************
; get bukovsky fields
;************************************************

  bukovsky_file = addfile(bukovsky_filename, "r")
  
  bukovsky_lat = bukovsky_file->lat
;  bukovsky_lat@units = "degrees_north"
  bukovsky_lon = bukovsky_file->lon
;  bukovsky_lon@units = "degrees_east"

; Create src grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "Bukovsky Grid"

  rectilinear_to_SCRIP(bukovsky_scrip_filename,bukovsky_lat,bukovsky_lon,Opt)

end

