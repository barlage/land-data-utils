load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

hr_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr1_vegsoil.nc"
hr_file = addfile(hr_filename, "r")
  hr_lat = hr_file->lat
  hr_lon = hr_file->lon

weights = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/hr/MSWEP-hr_nearest_wts.nc"

Opt                = True
;Opt@PrintTimings   = True

do iyyyy = 2019, 2022
do imm = 1, 12

  print("Starting: "+iyyyy+"-"+tostring_with_format(imm,"%2.2d"))

  filename = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/orig/monthly/"+iyyyy+tostring_with_format(imm,"%2.2d")+".nc"
    
  infile = addfile(filename,"r")

  mswep = infile->precipitation(0,:,:)
  
  mswep_regrid = ESMF_regrid_with_weights(mswep,weights,Opt)

  mswep_regrid!0 = "lat"
  mswep_regrid!1 = "lon"
  mswep_regrid&lat = hr_lat
  mswep_regrid&lon = hr_lon
  
;;;;;;;;;;;;;;;;;;;;

  outname = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/hr/monthly/mswep_hr."+iyyyy+"-"+tostring_with_format(imm,"%2.2d")+".nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->mswep_precip = mswep_regrid

end do
end do
  
end

