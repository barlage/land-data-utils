load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

C768_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/C768/C768_SCRIP.nc"
C768_file = addfile(C768_filename, "r")
  C768_lat = C768_file->grid_center_lat
  C768_lat@units = "degrees_north"
  C768_lat!0 = "location"
  C768_lon = C768_file->grid_center_lon
  C768_lon@units = "degrees_east"
  C768_lon!0 = "location"
  C768_lat_corner = C768_file->grid_corner_lat
  C768_lat_corner@units = "degrees_north"
  C768_lat_corner!0 = "location"
  C768_lon_corner = C768_file->grid_corner_lon
  C768_lon_corner@units = "degrees_east"
  C768_lon_corner!0 = "location"

weights = "/scratch2/NCEPDEV/land/data/evaluation/cpc_precip/C768/CPC-C768_nearest_wts.nc"

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

  outname = "/scratch2/NCEPDEV/land/data/evaluation/cpc_precip/C768/yearly/cpc_C768.yearly."+iyyyy+".nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->cpc_precip = cpc_regrid
  outfile->latitude = C768_lat
  outfile->longitude = C768_lon
  outfile->latitude_corners = C768_lat_corner
  outfile->longitude_corners = C768_lon_corner

delete(cpc)
delete(cpc_regrid)

end do
  
end
