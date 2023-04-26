
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

       mswep_filename = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/orig/201001.nc"
 mswep_scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/mswep_SCRIP.nc"


;************************************************
; get mswep fields
;************************************************

  mswep_file = addfile(mswep_filename, "r")
  
  mswep_var = mswep_file->precipitation(0,:,:)

  
  mswep_lat = mswep_file->lat
;  mswep_lat@units = "degrees_north"
  mswep_lon = mswep_file->lon
;  mswep_lon@units = "degrees_east"

; Create src grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "mswep Grid"

  rectilinear_to_SCRIP(mswep_scrip_filename,mswep_lat,mswep_lon,Opt)

end

