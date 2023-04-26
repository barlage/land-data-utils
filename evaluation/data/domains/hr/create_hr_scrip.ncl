load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

    vegsoil_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr1_vegsoil.nc"
   an_scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr_noant_SCRIP.nc"
   hr_scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr_SCRIP.nc"

;************************************************
; get hr fields
;************************************************

  hr_file  = addfile(vegsoil_filename, "r")

  hr_lat  = hr_file->lat
  hr_lon  = hr_file->lon

  inveg = hr_file->vegetation_type
  insoi = hr_file->soil_type
  hr_mask = inveg
  hr_mask = where(inveg.gt.0,1,0)

; Create source grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "hr Grid"
  Opt@GridMask       = hr_mask

  rectilinear_to_SCRIP(hr_scrip_filename,hr_lat,hr_lon,Opt)
  delete(Opt)
  
;************************************************
; set analysis fields
;************************************************

  an_lat = hr_lat(0:1279)
  an_lon = hr_lon

; Create destination grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "Analysis grid"
  Opt@GridMask       = hr_mask(0:1279,:)

  rectilinear_to_SCRIP(an_scrip_filename,an_lat,an_lon,Opt)
  delete(Opt)

end
