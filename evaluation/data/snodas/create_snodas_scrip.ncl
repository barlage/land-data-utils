
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

       snodas_filename = "/scratch2/NCEPDEV/land/data/evaluation/SNODAS/orig/SNODAS_unmasked_20131001.nc"
 snodas_scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/SNODAS/snodas_SCRIP.nc"


;************************************************
; get snodas fields
;************************************************

  snodas_file = addfile(snodas_filename, "r")
  
  snodas_var = snodas_file->snow_depth
  snodas_mask = where(ismissing(snodas_var),0,1)   ; if mask added, then resulting mask will find a source for all destination

  
  snodas_lat = snodas_file->lat
;  snodas_lat@units = "degrees_north"
  snodas_lon = snodas_file->lon
;  snodas_lon@units = "degrees_east"

; Create src grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "snodas grid"
  Opt@GridMask       = snodas_mask

  rectilinear_to_SCRIP(snodas_scrip_filename,snodas_lat,snodas_lon,Opt)

end

