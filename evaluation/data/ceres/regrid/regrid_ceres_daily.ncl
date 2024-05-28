load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

cres = "C96.mx100"
grid = "_hr3"
basepath = "/scratch2/NCEPDEV/land/data/evaluation/CERES/"

tbeg = 3105    ; 3168 = 20191203 3105 = 20191001
tend = 3470    ; 3268 = 20200312 3470 = 20200930

vars2process = (/"ini_sfc_sw_down_all_daily","ini_sfc_sw_up_all_daily","ini_sfc_lw_down_all_daily","ini_sfc_lw_up_all_daily"/)

varnames = (/"SWDN","SWUP","LWDN","LWUP" /)

latlon_filename = "/scratch2/NCEPDEV/land/data/ufs-land-driver/vector_inputs/"+cres+"/ufs-land_"+cres+grid+"_corners.nc"
latlon_file = addfile(latlon_filename, "r")
  latlon_lat = latlon_file->latitude
  latlon_lon = latlon_file->longitude

weights = basepath+cres+"/CERES-"+cres+grid+"_bilinear_wts.nc"

do ivar = 0, 3

  var2process = vars2process(ivar)
  varname = varnames(ivar)

  print("Starting: "+varname)

  filename = basepath+"orig/CERES_SW_LW_20110401-20231231.nc"
    
  infile = addfile(filename,"r")

  in_time = infile->time(tbeg:tend)
  ceres_time = (/ toint(in_time) /)
  ceres_time@units = in_time@units

  utc_date = cd_calendar(ceres_time,0)
  yyyy = tointeger(utc_date(0,0))
  mm = tointeger(utc_date(0,1))
  dd = tointeger(utc_date(0,2))

  datebeg = yyyy+tostring_with_format(mm,"%2.2d")+tostring_with_format(dd,"%2.2d")
  print("datebeg: "+datebeg)

  yyyy = tointeger(utc_date(tend-tbeg,0))
  mm = tointeger(utc_date(tend-tbeg,1))
  dd = tointeger(utc_date(tend-tbeg,2))

  dateend = yyyy+tostring_with_format(mm,"%2.2d")+tostring_with_format(dd,"%2.2d")
  print("dateend: "+dateend)

  time = new(dimsizes(ceres_time), double)
  time = cd_inv_calendar(utc_date(:,0),utc_date(:,1),utc_date(:,2),utc_date(:,3),utc_date(:,4),utc_date(:,5),ceres_time@units, 0)
  
  ceres = infile->$var2process$(tbeg:tend,:,:)
  
  Opt                = True
  ceres_regrid = ESMF_regrid_with_weights(ceres,weights,Opt)

  ceres_regrid!0 = "time"
  ceres_regrid!1 = "locations"
  delete(ceres_regrid&time)
  delete(ceres_regrid@lat1d)
  delete(ceres_regrid@lon1d)
  ceres_regrid&time = time
  ceres_regrid@long_name = var2process
  
;;;;;;;;;;;;;;;;;;;;
  outname  = basepath+cres+"/CERES-"+cres+"_"+varname+"_"+datebeg+"-"+dateend+".nc"

  system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->$var2process$ = ceres_regrid
  outfile->ceres_regrid_latitude = latlon_lat
  outfile->ceres_regrid_longitude = latlon_lon

  delete(ceres)
  delete(ceres_regrid)
  delete(ceres_time)
  delete(in_time)
  delete(time)
  delete(utc_date)

end do
  
end

