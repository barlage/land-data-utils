
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  data_source_file = keyword_values("regrid_parameter_assignment","data_source_file"  ,"string")
   data_scrip_file = keyword_values("regrid_parameter_assignment","data_scrip_file"   ,"string")
 precip_scrip_file = keyword_values("regrid_parameter_assignment","precip_scrip_file" ,"string")

;************************************************
; get gscd fields, use gscd missing as mask for land grids
;************************************************

  gscd_file = addfile(data_source_file, "r")
  gscd_var = gscd_file->QMEAN
  gscd_mask = where(gscd_var.ge.0,1,0)   ; if mask added, then resulting mask will find a source for all destination
  
  gscd_lat = gscd_file->latitude
;  gscd_lat@units = "degrees_north"
  gscd_lon = gscd_file->longitude
;  gscd_lon@units = "degrees_east"

; Create src grid for non-precip
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "GSCD Grid"
  Opt@GridMask       = gscd_mask

  rectilinear_to_SCRIP(data_scrip_file,gscd_lat,gscd_lon,Opt)

  gscd_var = gscd_file->PRECIP
  gscd_mask = where(gscd_var.ge.0,1,0)   ; if mask added, then resulting mask will find a source for all destination
  
; Create src grid for precip
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "GSCD Precip Grid"
  Opt@GridMask       = gscd_mask

  rectilinear_to_SCRIP(precip_scrip_file,gscd_lat,gscd_lon,Opt)

end

