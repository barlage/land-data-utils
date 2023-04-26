load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

C96_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/C96/C96_SCRIP.nc"
C96_file = addfile(C96_filename, "r")
  C96_lat = C96_file->grid_center_lat
  C96_lat@units = "degrees_north"
  C96_lat!0 = "location"
  C96_lon = C96_file->grid_center_lon
  C96_lon@units = "degrees_east"
  C96_lon!0 = "location"
  C96_lat_corner = C96_file->grid_corner_lat
  C96_lat_corner@units = "degrees_north"
  C96_lat_corner!0 = "location"
  C96_lon_corner = C96_file->grid_corner_lon
  C96_lon_corner@units = "degrees_east"
  C96_lon_corner!0 = "location"

weights = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/C96/MSWEP-C96_conserve_wts.nc"

Opt                = True
;Opt@PrintTimings   = True

do iyyyy = 2010, 2010;22
do imm = 1, 1;2

  print("Starting: "+iyyyy+"-"+tostring_with_format(imm,"%2.2d"))

  filename = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/orig/monthly/"+iyyyy+tostring_with_format(imm,"%2.2d")+".nc"
    
  infile = addfile(filename,"r")

  mswep = infile->precipitation(0,:,:)
  
  mswep_regrid = ESMF_regrid_with_weights(mswep,weights,Opt)

  mswep_regrid!0 = "location"
  delete(mswep_regrid@lat1d)
  delete(mswep_regrid@lon1d)
  
;;;;;;;;;;;;;;;;;;;;

  outname = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/C96/monthly/mswep_C96.monthly."+iyyyy+"-"+tostring_with_format(imm,"%2.2d")+".nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->mswep_precip = mswep_regrid
  outfile->latitude = C96_lat
  outfile->longitude = C96_lon
  outfile->latitude_corners = C96_lat_corner
  outfile->longitude_corners = C96_lon_corner

delete(mswep)
delete(mswep_regrid)

end do
end do
  
end

