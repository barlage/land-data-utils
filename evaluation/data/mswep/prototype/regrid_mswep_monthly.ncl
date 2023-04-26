load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

prototype_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype8_vegsoil.nc"
prototype_file = addfile(prototype_filename, "r")
  prototype_lat = prototype_file->lat
  prototype_lon = prototype_file->lon

weights = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/prototype/MSWEP-prototype_conserve_wts.nc"

Opt                = True
;Opt@PrintTimings   = True

do iyyyy = 2010, 2022
do imm = 1, 12

  print("Starting: "+iyyyy+"-"+tostring_with_format(imm,"%2.2d"))

  filename = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/orig/monthly/"+iyyyy+tostring_with_format(imm,"%2.2d")+".nc"
    
  infile = addfile(filename,"r")

  mswep = infile->precipitation(0,:,:)
  
  mswep_regrid = ESMF_regrid_with_weights(mswep,weights,Opt)

  mswep_regrid!0 = "lat"
  mswep_regrid!1 = "lon"
  mswep_regrid&lat = prototype_lat
  mswep_regrid&lon = prototype_lon
  
;;;;;;;;;;;;;;;;;;;;

  outname = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/prototype/monthly/mswep_prototype."+iyyyy+"-"+tostring_with_format(imm,"%2.2d")+".nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->mswep_precip = mswep_regrid

end do
end do
  
end

