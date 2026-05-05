load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

data_source_directory = keyword_values("regrid_parameter_assignment","data_source_directory","string")
destination_directory = keyword_values("regrid_parameter_assignment","destination_directory","string")
 weights_filename_v16 = keyword_values("regrid_parameter_assignment","weights_filename_v16","string")
 weights_filename_v17 = keyword_values("regrid_parameter_assignment","weights_filename_v17","string")
          grid_string = keyword_values("regrid_parameter_assignment","grid_string","string")

; possible variable names from the preprocessing
;   dirctory          orig netcdf name               regrid name
;   LHTFL         ->  LHTFL_surface              ->  latent_heat_flux
;   SHTFL         ->  SHTFL_surface              ->  sensible_heat_flux
;   GFLUX         ->  GFLUX_surface              ->  ground_heat_flux
;   DSWRF         ->  DSWRF_surface              ->  downward_solar
;   DLWRF         ->  DLWRF_surface              ->  downward_longwave
;   USWRF         ->  USWRF_surface              ->  upward_solar
;   ULWRF         ->  ULWRF_surface              ->  upward_longwave
;   WATR          ->  WATR_surface               ->  total_runoff
;   PRATE         ->  PRATE_surface              ->  precipitation_rate
;   SNOD          ->  SNOD_surface               ->  snow_depth
;   WEASD         ->  WEASD_surface              ->  snow_water_equivalent
;   FRICV         ->  FRICV_surface              ->  friction_velocity
;   SOILW.level1  ->  SOILW_0M0D1mbelowground    ->  soil_water_level1
;   SOILW.level2  ->  SOILW_0D1M0D4mbelowground  ->  soil_water_level2
;   SOILW.level3  ->  SOILW_0D4M1mbelowground    ->  soil_water_level3
;   SOILW.level4  ->  SOILW_1M2mbelowground      ->  soil_water_level4
;   TSOIL.level1  ->  TSOIL_0M0D1mbelowground    ->  soil_temperature_level1
;   TSOIL.level2  ->  TSOIL_0D1M0D4mbelowground  ->  soil_temperature_level2
;   TSOIL.level3  ->  TSOIL_0D4M1mbelowground    ->  soil_temperature_level3
;   TSOIL.level4  ->  TSOIL_1M2mbelowground      ->  soil_temperature_level4


days2process = (/"day01","day07","day14"/)
vers2process = (/"v16","v17"/)
vars2process = (/"LHTFL"       ,"LHTFL_surface"            ,"latent_heat_flux"       , \
                 "SHTFL"       ,"SHTFL_surface"            ,"sensible_heat_flux"     , \
                 "GFLUX"       ,"GFLUX_surface"            ,"ground_heat_flux"       , \
                 "DSWRF"       ,"DSWRF_surface"            ,"downward_solar"         , \
                 "DLWRF"       ,"DLWRF_surface"            ,"downward_longwave"      , \
                 "USWRF"       ,"USWRF_surface"            ,"upward_solar"           , \
                 "ULWRF"       ,"ULWRF_surface"            ,"upward_longwave"        , \
                 "WATR"        ,"WATR_surface"             ,"total_runoff"           , \
                 "PRATE"       ,"PRATE_surface"            ,"precipitation_rate"     , \
                 "SNOD"        ,"SNOD_surface"             ,"snow_depth"             , \
                 "WEASD"       ,"WEASD_surface"            ,"snow_water_equivalent"  , \
                 "FRICV"       ,"FRICV_surface"            ,"friction_velocity"      , \
                 "SOILW.level1","SOILW_0M0D1mbelowground"  ,"soil_water_level1"      , \
                 "SOILW.level2","SOILW_0D1M0D4mbelowground","soil_water_level2"      , \
                 "SOILW.level3","SOILW_0D4M1mbelowground"  ,"soil_water_level3"      , \
                 "SOILW.level4","SOILW_1M2mbelowground"    ,"soil_water_level4"      , \
                 "TSOIL.level1","TSOIL_0M0D1mbelowground"  ,"soil_temperature_level1", \
                 "TSOIL.level2","TSOIL_0D1M0D4mbelowground","soil_temperature_level2", \
                 "TSOIL.level3","TSOIL_0D4M1mbelowground"  ,"soil_temperature_level3", \
                 "TSOIL.level4","TSOIL_1M2mbelowground"    ,"soil_temperature_level4" /)


do iver = 0, 1

  ver2process = vers2process(iver)
  if(ver2process .eq. "v16") then
    weights_filename = weights_filename_v16
  elseif(ver2process .eq. "v17") then
    weights_filename = weights_filename_v17
  else
    print("unknown version: "+ver2process)
    exit
  end if

do iday = 0, 2

  day2process = days2process(iday)

do ivar = 0, 19

  dir2process = vars2process(ivar*3)
  var2process = vars2process(ivar*3+1)
  out2process = vars2process(ivar*3+2)

  file_start = "GFS"+ver2process+"."+dir2process+"."+day2process+".monthly_mean."

  filename = data_source_directory+ver2process+"/"+day2process+"/"+dir2process+"/"+file_start+"nc"

  print("Accessing infile: "+filename)  
  infile = addfile(filename,"r")

;;;;;;;;;;;;;;;;;;;;
  outname  = destination_directory+file_start+grid_string+".nc"

  system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")

  print("Starting output variable: "+out2process)
  
  indata = infile->$var2process$
  
  Opt                = True
  data_regrid = ESMF_regrid_with_weights(indata,weights_filename,Opt)

  data_regrid!0 = "time"
  data_regrid!1 = "location"
  delete(data_regrid@lat1d)
  delete(data_regrid@lon1d)
  
  outfile->$out2process$ = data_regrid

  delete(indata)
  delete(data_regrid)

end do
end do
end do
  
end
