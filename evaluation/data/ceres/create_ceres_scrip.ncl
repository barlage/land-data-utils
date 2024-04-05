
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

       ceres_filename = "/scratch2/NCEPDEV/land/data/evaluation/CERES/orig/CERES_SW_LW_20110401-20231231.nc"
 ceres_scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/CERES/ceres_SCRIP.nc"


;************************************************
; get ceres fields
;************************************************

  ceres_file = addfile(ceres_filename, "r")

;  possibly add a mask later, data are available everywhere
;  ceres_var = ceres_file->(0,:,:)
;  ceres_mask = where(ismissing(ceres_var),0,1)   ; if mask added, then resulting mask will find a source for all destination

  
  ceres_lat = ceres_file->lat
;  ceres_lat@units = "degrees_north"
  ceres_lon = ceres_file->lon
;  ceres_lon@units = "degrees_east"

; Create src grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "ceres grid"
;  Opt@GridMask       = ceres_mask

  rectilinear_to_SCRIP(ceres_scrip_filename,ceres_lat,ceres_lon,Opt)

end

