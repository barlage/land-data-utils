load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

prototype_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype8_vegsoil.nc"
prototype_file = addfile(prototype_filename, "r")
  prototype_lat = prototype_file->lat
  prototype_lon = prototype_file->lon

weights = "/scratch2/NCEPDEV/land/data/evaluation/cpc_precip/prototype/CPC-prototype_nearest_wts.nc"

Opt                = True
;Opt@PrintTimings   = True

do iyyyy = 2000, 2021
do imm = 1, 12

  print("Starting: "+iyyyy+"-"+tostring_with_format(imm,"%2.2d"))

  filename = "/scratch2/NCEPDEV/land/data/evaluation/cpc_precip/orig/monthly/precip."+iyyyy+"-"+tostring_with_format(imm,"%2.2d")+".ttl.nc"
    
  infile = addfile(filename,"r")

  cpc = infile->precip(0,:,:)
  
  cpc_regrid = ESMF_regrid_with_weights(cpc,weights,Opt)

  cpc_regrid!0 = "lat"
  cpc_regrid!1 = "lon"
  cpc_regrid&lat = prototype_lat
  cpc_regrid&lon = prototype_lon
  
;;;;;;;;;;;;;;;;;;;;

  outname = "/scratch2/NCEPDEV/land/data/evaluation/cpc_precip/prototype/monthly/cpc_prototype."+iyyyy+"-"+tostring_with_format(imm,"%2.2d")+".nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->cpc_precip = cpc_regrid

end do
end do
  
end

