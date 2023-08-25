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

do iyyyy = 2019, 2019

  daymin = 335
  daymax = 365

do iddd = daymin, daymax

  print("Starting: "+iyyyy+"-"+tostring_with_format(iddd,"%3.3d"))

  filename = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/orig/daily/"+iyyyy+tostring_with_format(iddd,"%3.3d")+".nc"
    
  infile = addfile(filename,"r")

  mswep = infile->precipitation(0,:,:)
  
  mswep_regrid = ESMF_regrid_with_weights(mswep,weights,Opt)

  mswep_regrid!0 = "lat"
  mswep_regrid!1 = "lon"
  mswep_regrid&lat = hr_lat
  mswep_regrid&lon = hr_lon
  
;;;;;;;;;;;;;;;;;;;;

  md = monthday(iyyyy,iddd)
  dd = md%100
  mm = (md - dd)/100

  print("Writing: "+iyyyy+"-"+tostring_with_format(mm,"%2.2d")+"-"+tostring_with_format(dd,"%2.2d"))

  outname = "/scratch2/NCEPDEV/land/data/evaluation/MSWEP/hr/daily/mswep_hr."+iyyyy+"-"+tostring_with_format(mm,"%2.2d")+"-"+tostring_with_format(dd,"%2.2d")+".nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->mswep_precip = mswep_regrid

end do
end do
  
end

