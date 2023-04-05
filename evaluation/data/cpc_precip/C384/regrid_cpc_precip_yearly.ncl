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

weights = "/scratch2/NCEPDEV/land/data/evaluation/cpc_precip/C384/CPC-C384_nearest_wts.nc"

Opt                = True
;Opt@PrintTimings   = True

do iyyyy = 2000, 2021

  print("Starting: "+iyyyy)

  filename = "/scratch2/NCEPDEV/land/data/evaluation/cpc_precip/orig/yearly/precip."+iyyyy+".ttl.nc"
    
  infile = addfile(filename,"r")

  cpc = infile->precip(0,:,:)
  
  cpc_regrid = ESMF_regrid_with_weights(cpc,weights,Opt)

  cpc_regrid!0 = "location"
  delete(cpc_regrid@lat1d)
  delete(cpc_regrid@lon1d)
  
;;;;;;;;;;;;;;;;;;;;

  outname = "/scratch2/NCEPDEV/land/data/evaluation/cpc_precip/C384/yearly/cpc_C384.yearly."+iyyyy+".nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->cpc_precip = cpc_regrid
  outfile->latitude = C384_lat
  outfile->longitude = C384_lon
  outfile->latitude_corners = C384_lat_corner
  outfile->longitude_corners = C384_lon_corner

delete(cpc)
delete(cpc_regrid)

end do
  
end
