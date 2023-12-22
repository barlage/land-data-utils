
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

       cci_filename = "/scratch2/NCEPDEV/land/data/evaluation/CCI/orig/ESACCI-SOILMOISTURE-L3S-SSMV-COMBINED-20220101000000-fv08.1.nc"
 cci_scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/CCI/cci_SCRIP.nc"


;************************************************
; get cci fields
;************************************************

  cci_file = addfile(cci_filename, "r")
  
  cci_lat = cci_file->lat
  cci_lat@units = "degrees_north"
  cci_lon = cci_file->lon
  cci_lon@units = "degrees_east"

; Create src grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "cci Grid"
;  Opt@GridMask       = cci_mask

  rectilinear_to_SCRIP(cci_scrip_filename,cci_lat,cci_lon,Opt)

end

