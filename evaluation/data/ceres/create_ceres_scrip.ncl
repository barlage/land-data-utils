
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

;************************************************
; get ceres fields
;************************************************

  ceres_file = addfile(data_source_file, "r")

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

  rectilinear_to_SCRIP(data_scrip_file,ceres_lat,ceres_lon,Opt)

end

