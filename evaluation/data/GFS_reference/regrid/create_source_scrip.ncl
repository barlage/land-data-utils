
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

data_source_file = keyword_values("regrid_parameter_assignment","data_source_file","string")
 data_scrip_file = keyword_values("regrid_parameter_assignment","data_scrip_file" ,"string")

;************************************************
; get gfs fields, use gfs soil type as mask for land grids
;************************************************

  gfs_file = addfile(data_source_file, "r")
  gfs_mask = gfs_file->LAND_surface(0,:,:)  ; if mask added, then resulting mask will find a source for all destination
  
  gfs_lat = gfs_file->latitude
;  gfs_lat@units = "degrees_north"
  gfs_lon = gfs_file->longitude
;  gfs_lon@units = "degrees_east"

; Create src grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "GFS Grid"
  Opt@GridMask       = gfs_mask

  rectilinear_to_SCRIP(data_scrip_file,gfs_lat,gfs_lon,Opt)

end

