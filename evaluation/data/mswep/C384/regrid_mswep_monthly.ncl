load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

C384_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/C384/C384_SCRIP.nc"
C384_file = addfile(C384_filename, "r")
  C384_lat = C384_file->grid_center_lat
  C384_lat@units = "degrees_north"
  C384_lat!0 = "location"
  C384_lon = C384_file->grid_center_lon
  C384_lon@units = "degrees_east"
  C384_lon!0 = "location"
  C384_lat_corner = C384_file->grid_corner_lat
  C384_lat_corner@units = "degrees_north"
  C384_lat_corner!0 = "location"
  C384_lon_corner = C384_file->grid_corner_lon
  C384_lon_corner@units = "degrees_east"
  C384_lon_corner!0 = "location"

weights = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/C384/MSWEP-C384_conserve_wts.nc"

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

  outname = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/C384/monthly/mswep_C384.monthly."+iyyyy+"-"+tostring_with_format(imm,"%2.2d")+".nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->mswep_precip = mswep_regrid
  outfile->latitude = C384_lat
  outfile->longitude = C384_lon
  outfile->latitude_corners = C384_lat_corner
  outfile->longitude_corners = C384_lon_corner

delete(mswep)
delete(mswep_regrid)

end do
end do
  
end

