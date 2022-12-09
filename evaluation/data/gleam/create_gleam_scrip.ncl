
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

       gleam_filename = "/scratch2/NCEPDEV/land/data/evaluation/GLEAM/orig/E/v3.6a/E_1980-2021_GLEAM_v3.6a_MO.nc"
 gleam_scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/GLEAM/gleam_SCRIP.nc"


;************************************************
; get gleam fields
;************************************************

  gleam_file = addfile(gleam_filename, "r")
  
  gleam_var = gleam_file->E(0,:,:)
  gleam_inv = gleam_var(lat|:,lon|:)
  gleam_mask = where(ismissing(gleam_inv),0,1)   ; if mask added, then resulting mask will find a source for all destination

  
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

  rectilinear_to_SCRIP(gleam_scrip_filename,gleam_lat,gleam_lon,Opt)

end

