
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

       cpc_filename = "/scratch2/NCEPDEV/land/data/evaluation/cpc_precip/orig/daily/precip.2000.nc"
 cpc_scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/cpc_precip/cpc_SCRIP.nc"


;************************************************
; get cpc fields
;************************************************

  cpc_file = addfile(cpc_filename, "r")
  
  cpc_var = cpc_file->precip(0,:,:)
  cpc_mask = where(ismissing(cpc_var),0,1)   ; if mask added, then resulting mask will find a source for all destination

  
  cpc_lat = cpc_file->lat
;  cpc_lat@units = "degrees_north"
  cpc_lon = cpc_file->lon
;  cpc_lon@units = "degrees_east"

; Create src grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "cpc Grid"
  Opt@GridMask       = cpc_mask

  rectilinear_to_SCRIP(cpc_scrip_filename,cpc_lat,cpc_lon,Opt)

end

