load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

tbeg = 3168    ; 3168 = 2019 12 03
tend = 3268    ; 3268 = 2020 03 12

vars2process = (/"ini_sfc_sw_down_all_daily","ini_sfc_sw_up_all_daily","ini_sfc_lw_down_all_daily","ini_sfc_lw_up_all_daily"/)

varnames = (/"SWDN","SWUP","LWDN","LWUP" /)

hr_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr3_vegsoil.nc"
hr_file = addfile(hr_filename, "r")
  hr_lat = hr_file->lat
  hr_lon = hr_file->lon

weights = "/scratch2/NCEPDEV/land/data/evaluation/CERES/hr/CERES-hr_bilinear_wts.nc"

do ivar = 0, 3

  var2process = vars2process(ivar)
  varname = varnames(ivar)

  print("Starting: "+varname)

  filename = "/scratch2/NCEPDEV/land/data/evaluation/CERES/orig/CERES_SW_LW_20110401-20231231.nc"
    
  infile = addfile(filename,"r")

  in_time = infile->time(tbeg:tend)
  ceres_time = (/ toint(in_time) /)
  ceres_time@units = in_time@units
  print("ceres_time: "+ceres_time(0))

  utc_date = cd_calendar(ceres_time,0)
  yyyy = tointeger(utc_date(0,0))
  mm = tointeger(utc_date(0,1))
  dd = tointeger(utc_date(0,2))
  print("date: "+yyyy+" "+mm+" "+dd)

  time = new(dimsizes(ceres_time), double)
  time = cd_inv_calendar(utc_date(:,0),utc_date(:,1),utc_date(:,2),utc_date(:,3),utc_date(:,4),utc_date(:,5),ceres_time@units, 0)
  
  ceres = infile->$var2process$(tbeg:tend,:,:)
  print(dimsizes(ceres))
  
  Opt                = True
  ceres_regrid = ESMF_regrid_with_weights(ceres,weights,Opt)

  ceres_regrid!0 = "time"
  ceres_regrid!1 = "latitude"
  ceres_regrid!2 = "longitude"
  delete(ceres_regrid&time)
  ceres_regrid&time = time
  ceres_regrid&latitude = hr_lat
  ceres_regrid&longitude = hr_lon
  ceres_regrid@long_name = var2process
  
;;;;;;;;;;;;;;;;;;;;
  outname  = "/scratch2/NCEPDEV/land/data/evaluation/CERES/hr/CERES_"+varname+"_hr.winter.nc"

  system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->$var2process$ = ceres_regrid

  delete(ceres)
  delete(ceres_regrid)
  delete(ceres_time)
  delete(in_time)
  delete(time)
  delete(utc_date)

end do
  
end

