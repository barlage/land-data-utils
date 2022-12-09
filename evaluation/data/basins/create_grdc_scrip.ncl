
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

       grdc_filename = "/scratch2/NCEPDEV/land/data/evaluation/basins/world_basins.nc"
 grdc_scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/basins/grdc_SCRIP.nc"


;************************************************
; get grdc fields
;************************************************

  grdc_file = addfile(grdc_filename, "r")
  
  grdc_var = (/ grdc_file->Band1 /)
;  grdc_mask = where(ismissing(grdc_var),0,1)   ; if mask added, then resulting mask will find a source for all destination

  
  grdc_lat = grdc_file->lat
;  grdc_lat@units = "degrees_north"
  grdc_lon = grdc_file->lon
;  grdc_lon@units = "degrees_east"

; Create src grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "grdc Grid"
;  Opt@GridMask       = grdc_mask

  rectilinear_to_SCRIP(grdc_scrip_filename,grdc_lat,grdc_lon,Opt)

end

