load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

vars2process = (/"E","Eb","Ei","Es","Et","S","SMroot","SMsurf"/)

varlongnames = (/"Actual ET","E bare soil","E canopy interception","E snow", \
                "E transpiration","Evap stress","SM root zone","SM surface" /)

C96_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/C96_conus/C96_conus_SCRIP.nc"
C96_file = addfile(C96_filename, "r")
  C96_lat = C96_file->grid_center_lat
  C96_lat@units = "degrees_north"
  C96_lat!0 = "location"
  C96_lon = C96_file->grid_center_lon
  C96_lon@units = "degrees_east"
  C96_lon!0 = "location"
  C96_lat_corner = C96_file->grid_corner_lat
  C96_lat_corner@units = "degrees_north"
  C96_lat_corner!0 = "location"
  C96_lon_corner = C96_file->grid_corner_lon
  C96_lon_corner@units = "degrees_east"
  C96_lon_corner!0 = "location"

do ivar = 0, 7

var2process = vars2process(ivar)
varlongname = varlongnames(ivar)

print("Starting: "+varlongname)

filename = "/scratch2/NCEPDEV/land/data/evaluation/GLEAM/orig/"+var2process+"/v3.6b/"+var2process+"_2003-2021_GLEAM_v3.6b_MO.nc"
outname  = "/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.6b_"+var2process+"_C96_conus.nc"
tstart = 96  ; jan 2011

;filename = "/scratch2/NCEPDEV/land/data/evaluation/GLEAM/orig/"+var2process+"/v3.6a/"+var2process+"_1980-2021_GLEAM_v3.6a_MO.nc"
;outname  = "/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.6a_"+var2process+"_C96_conus.nc"
;tstart = 372  ; jan 2011

weights = "/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM-C96_conus_conserve_wts.nc"

Opt                = True
    
  infile = addfile(filename,"r")

  gleam_time = infile->time(tstart:)
  print("gleam_time: "+gleam_time(0))

  utc_date = cd_calendar(gleam_time,0)
  yyyy = tointeger(utc_date(0,0))
  mm = tointeger(utc_date(0,1))
  dd = tointeger(utc_date(0,2))
  print("date: "+yyyy+" "+mm+" "+dd)

  time = new(dimsizes(gleam_time), double)
;   time!0 = "time"
;   time@units = "seconds since 1970-01-01 00:00:00"
  time = cd_inv_calendar(utc_date(:,0),utc_date(:,1),utc_date(:,2),utc_date(:,3),utc_date(:,4),utc_date(:,5),"seconds since 1970-01-01 00:00:00", 0)
  
;  print("time: "+time(0))
  
  gleam = infile->$var2process$(tstart:,:,:)
  print(dimsizes(gleam))
  
  gleam_sort = gleam(time|:,lat|:,lon|:)
  
  gleam_regrid = ESMF_regrid_with_weights(gleam_sort,weights,Opt)

  gleam_regrid!0 = "time"
  gleam_regrid!1 = "location"
  delete(gleam_regrid&time)
  gleam_regrid&time = time
  gleam_regrid@long_name = varlongname
  delete(gleam_regrid@lat1d)
  delete(gleam_regrid@lon1d)
  
;;;;;;;;;;;;;;;;;;;;

   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->$var2process$ = gleam_regrid
;  outfile->time = gleam_time
  outfile->latitude = C96_lat
  outfile->longitude = C96_lon
  outfile->latitude_corners = C96_lat_corner
  outfile->longitude_corners = C96_lon_corner

delete(gleam)
delete(gleam_sort)
delete(gleam_regrid)

end do
  
end

