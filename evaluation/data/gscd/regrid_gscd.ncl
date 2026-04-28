load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

       data_source_file = keyword_values("regrid_parameter_assignment","data_source_file","string")
  destination_directory = keyword_values("regrid_parameter_assignment","destination_directory","string")
       weights_filename = keyword_values("regrid_parameter_assignment","weights_filename","string")
weights_filename_precip = keyword_values("regrid_parameter_assignment","weights_filename_precip","string")
            grid_string = keyword_values("regrid_parameter_assignment","grid_string","string")

vars2process = (/"QMEAN","RC","PRECIP","BF1","BF2","BF3","BF4","BFI1","BFI2","BFI3","BFI4", \
                 "QMEAN_uncertainty"/)

infile = addfile(data_source_file,"r")

outname  = destination_directory+"/GSCD."+grid_string+".nc"
  system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
outfile = addfile(outname,"c")
  
do ivar = 0, dimsizes(vars2process)-1

  var2process = vars2process(ivar)

  print("Starting: "+var2process)
  
  indata = infile->$var2process$
  
  Opt                = True
  if(var2process.eq."PRECIP") then
    print("Using weights file: "+weights_filename_precip)
    gscd_regrid = ESMF_regrid_with_weights(indata,weights_filename_precip,Opt)
  else
    print("Using weights file: "+weights_filename)
    gscd_regrid = ESMF_regrid_with_weights(indata,weights_filename,Opt)
  end if

  gscd_regrid!0 = "location"
  delete(gscd_regrid@lat1d)
  delete(gscd_regrid@lon1d)
  
  outfile->$var2process$ = gscd_regrid

  delete(indata)
  delete(gscd_regrid)

end do

end
