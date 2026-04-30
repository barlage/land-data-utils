load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

  data_source_directory = keyword_values("regrid_parameter_assignment","data_source_directory","string")
  destination_directory = keyword_values("regrid_parameter_assignment","destination_directory","string")
       weights_filename = keyword_values("regrid_parameter_assignment","weights_filename","string")
            grid_string = keyword_values("regrid_parameter_assignment","grid_string","string")

vars2process = (/"E","Es","Ei","Et","Eb"/)

; Do v4.2a first

outname  = destination_directory+"/GLEAM.v4.2a.climatology.2015-2024."+grid_string+".nc"
  system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
outfile = addfile(outname,"c")
  
do ivar = 0, dimsizes(vars2process)-1

  var2process = vars2process(ivar)

  print("Starting: "+var2process)
  
  inname = data_source_directory+"/v4.2a/"+var2process+"/GLEAM.v4.2a."+var2process+".climatology.2015-2024.nc"
  print("Reading: "+inname)
  infile = addfile(inname,"r")

  indata = infile->$var2process$
  
  Opt                = True
  gleam_regrid = ESMF_regrid_with_weights(indata,weights_filename,Opt)

  gleam_regrid!0 = "time"
  gleam_regrid!1 = "location"
  delete(gleam_regrid@lat1d)
  delete(gleam_regrid@lon1d)
  
  outfile->$var2process$ = gleam_regrid

  delete(indata)
  delete(gleam_regrid)

end do

; Do v4.2b next

outname  = destination_directory+"/GLEAM.v4.2b.climatology.2015-2024."+grid_string+".nc"
  system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
outfile = addfile(outname,"c")
  
do ivar = 0, dimsizes(vars2process)-1

  var2process = vars2process(ivar)

  print("Starting: "+var2process)
  
  inname = data_source_directory+"/v4.2b/"+var2process+"/GLEAM.v4.2b."+var2process+".climatology.2015-2024.nc"
  print("Reading: "+inname)
  infile = addfile(inname,"r")

  indata = infile->$var2process$
  
  Opt                = True
  gleam_regrid = ESMF_regrid_with_weights(indata,weights_filename,Opt)

  gleam_regrid!0 = "time"
  gleam_regrid!1 = "location"
  delete(gleam_regrid@lat1d)
  delete(gleam_regrid@lon1d)
  
  outfile->$var2process$ = gleam_regrid

  delete(indata)
  delete(gleam_regrid)

end do

end
