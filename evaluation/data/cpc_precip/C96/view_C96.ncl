begin

  res                       = True              ; Plot mods desired.
  res@gsnMaximize           = True              ; Maximize plot
  res@gsnAddCyclic          = False             ; don't add a longitude cyclic point
  res@cnFillOn              = True              ; color plot desired
  res@cnFillOpacityF        = 0.6               ; apply a little opacity so we can see mesh lines better
  res@cnFillMode            = "CellFill"
  res@cnFillPalette         = "BlWhRe"
  res@cnLinesOn             = False             ; turn off contour lines
  res@cnLineLabelsOn        = False             ; turn off contour labels
  res@tiMainFontHeightF     = 0.017
  res@pmTitleZone           = 4                 ; move title down
  res@mpFillOn              = False             ; turn off map fill
  res@pmTickMarkDisplayMode = "Always"          ; nicer map tickmark labels
  res@mpDataBaseVersion     = "LowRes"       ; better map outlines
  res@mpOutlineBoundarySets = "Geophysical"
  res@mpOutlineOn           = True
  res@mpNationalLineThicknessF    = 2.0      ; for better looking images
  res@mpGeophysicalLineThicknessF = 2.0
  res@mpCountyLineThicknessF      = 2.0
  res@mpProvincialLineThicknessF  = 2.0
  res@gsnRightString        = ""
  res@gsnLeftString         = ""
  res@lbLabelBarOn          = True             ; Will turn on in panel

  if(True) then
    wks = gsn_open_wks("x11","blah") 
  else
    wks = gsn_open_wks("png","blah") 
  end if

  infile = addfile("/scratch2/NCEPDEV/land/data/evaluation/cpc_precip/C96/yearly/cpc_C96.yearly.2000.nc","r")
  
  lat  = infile->latitude
  lon  = infile->longitude
  latc = infile->latitude_corners
  lonc = infile->longitude_corners

  res@sfXArray      := lon               ; necessary for plotting MPAS
  res@sfYArray      := lat
  res@sfYCellBounds := latc     ; necessary for CellFill 
  res@sfXCellBounds := lonc

  invar = infile->cpc_precip

  plot = gsn_csm_contour_map(wks,invar,res)  

end
