load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

    vegsoil_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype8_vegsoil.nc"
   an_scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype_noant_SCRIP.nc"
   pt_scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype_SCRIP.nc"

;************************************************
; get prototype fields
;************************************************

  prototype_file  = addfile(vegsoil_filename, "r")

  prototype_lat  = prototype_file->lat
  prototype_lon  = prototype_file->lon

  inveg = prototype_file->vegetation_type
  insoi = prototype_file->soil_type
  prototype_mask = inveg
  prototype_mask = where(inveg.gt.0,1,0)

; Create source grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "Prototype Grid"
  Opt@GridMask       = prototype_mask

  rectilinear_to_SCRIP(pt_scrip_filename,prototype_lat,prototype_lon,Opt)
  delete(Opt)
  
;************************************************
; set analysis fields
;************************************************

  an_lat = prototype_lat(0:639)
  an_lon = prototype_lon

; Create destination grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "Analysis grid"
  Opt@GridMask       = prototype_mask(0:639,:)

  rectilinear_to_SCRIP(an_scrip_filename,an_lat,an_lon,Opt)
  delete(Opt)

end
