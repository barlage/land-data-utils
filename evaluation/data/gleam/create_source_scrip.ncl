
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  data_source_file = keyword_values("regrid_parameter_assignment","data_source_file"  ,"string")
   data_scrip_file = keyword_values("regrid_parameter_assignment","data_scrip_file"   ,"string")

;************************************************
; get gleam fields, use gleam missing as mask for land grids
;************************************************

  gleam_file = addfile(data_source_file, "r")
  gleam_var = gleam_file->E(0,:,:)
  delete(gleam_var@_FillValue)
  gleam_mask = where(gleam_var.ne.-999,1,0)   ; if mask added, then resulting mask will find a source for all destination

  gleam_lat = gleam_file->lat
;  gleam_lat@units = "degrees_north"
  gleam_lon = gleam_file->lon
;  gleam_lon@units = "degrees_east"

; Create src grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "gleam Grid"
  Opt@GridMask       = gleam_mask

  rectilinear_to_SCRIP(data_scrip_file,gleam_lat,gleam_lon,Opt)

end

