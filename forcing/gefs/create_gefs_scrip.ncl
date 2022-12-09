
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

       gefs_filename = "/scratch2/NCEPDEV/land/data/forcing/gefs/sample/gefs.ens01.2020-09-23_03Z.nc"
 gefs_scrip_filename = "/scratch2/NCEPDEV/land/data/forcing/gefs/weights/gefs_SCRIP.nc"


;************************************************
; get gefs fields
;************************************************

  gefs_file = addfile(gefs_filename, "r")
  
  gefs_lat = gefs_file->latitude
;  gefs_lat@units = "degrees_north"
  gefs_lon = gefs_file->longitude
;  gefs_lon@units = "degrees_east"

; Create src grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "gefs Grid"

  rectilinear_to_SCRIP(gefs_scrip_filename,gefs_lat,gefs_lon,Opt)

end

