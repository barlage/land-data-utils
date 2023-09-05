load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

iyyyy = 2020

;           JAN,FEB,MAR,APR,MAY,JUN,JUL,AUG,SEP,OCT,NOV,DEC
tstarts = (/  0, 31, 60, 91,121,152,182,213,244,274,305,335/)  ; 0-based leap year
tends   = (/ 30, 59, 90,120,151,181,212,243,273,304,334,365/)
;tstarts = (/  0, 31, 59, 90,120,151,181,212,243,273,304,334/)  ; 0-based non-leap year
;tends   = (/ 30, 58, 89,119,150,180,211,242,272,303,333,364/)

version = "v3.6a"

vars2process = (/"E","Eb","Ei","Es","Et","S","SMroot","SMsurf"/)

varlongnames = (/"Actual ET","E bare soil","E canopy interception","E snow", \
                "E transpiration","Evap stress","SM root zone","SM surface" /)

hr_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr1_vegsoil.nc"
hr_file = addfile(hr_filename, "r")
  hr_lat = hr_file->lat
  hr_lon = hr_file->lon

weights = "/scratch2/NCEPDEV/land/data/evaluation/GLEAM/hr/GLEAM-hr_bilinear_wts.nc"

do ivar = 0, 7

  var2process = vars2process(ivar)
  varlongname = varlongnames(ivar)

  print("Starting: "+varlongname)

  filename = "/scratch2/NCEPDEV/land/data/evaluation/GLEAM/orig/"+var2process+"/"+version+"/"+var2process+"_"+iyyyy+"_GLEAM_"+version+".nc"
    
  infile = addfile(filename,"r")

  do imm = 6, 9  ; 1-based

    gleam_time = infile->time(tstarts(imm-1):tends(imm-1))
    print("gleam_time: "+gleam_time(0))

    utc_date = cd_calendar(gleam_time,0)
    yyyy = tointeger(utc_date(0,0))
    mm = tointeger(utc_date(0,1))
    dd = tointeger(utc_date(0,2))
    print("date: "+yyyy+" "+mm+" "+dd)

    time = new(dimsizes(gleam_time), double)
    time = cd_inv_calendar(utc_date(:,0),utc_date(:,1),utc_date(:,2),utc_date(:,3),utc_date(:,4),utc_date(:,5),"seconds since 1970-01-01 00:00:00", 0)
  
;  print("time: "+time(0))
  
    gleam = infile->$var2process$(tstarts(imm-1):tends(imm-1),:,:)
    print(dimsizes(gleam))
  
    Opt                = True
    gleam_regrid = ESMF_regrid_with_weights(gleam,weights,Opt)

    gleam_regrid!0 = "time"
    gleam_regrid!1 = "latitude"
    gleam_regrid!2 = "longitude"
    delete(gleam_regrid&time)
    gleam_regrid&time = time
    gleam_regrid&latitude = hr_lat
    gleam_regrid&longitude = hr_lon
    gleam_regrid@long_name = varlongname
  
;;;;;;;;;;;;;;;;;;;;
    outname  = "/scratch2/NCEPDEV/land/data/evaluation/GLEAM/hr/daily/GLEAM_"+version+"_"+var2process+"_hr."+iyyyy+"-"+tostring_with_format(imm,"%2.2d")+".nc"

    system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
    outfile = addfile(outname,"c")
    outfile->$var2process$ = gleam_regrid

    delete(gleam)
    delete(gleam_regrid)
    delete(gleam_time)
    delete(time)
    delete(utc_date)

  end do
  
end do
  
end

