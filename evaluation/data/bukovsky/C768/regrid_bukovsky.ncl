load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

weights_nearest = "/scratch2/NCEPDEV/land/data/evaluation/BUKOVSKY/C768/BUKOVSKY-C768_nearest_wts.nc"

bukovsky_filename = "/scratch2/NCEPDEV/land/data/evaluation/BUKOVSKY/combined/bukovsky_regions.nc"
infile = addfile(bukovsky_filename,"r")

bukovsky = (/ infile->region /)
region_names = infile->region_names
  
Opt                = True
;Opt@PrintTimings   = True

var_regrid = ESMF_regrid_with_weights(bukovsky,weights_nearest,Opt)
  var_regrid!0 = "location"
  delete(var_regrid@lat1d)
  delete(var_regrid@lon1d)

  outname = "/scratch2/NCEPDEV/land/data/evaluation/BUKOVSKY/C768/BUKOVSKY_C768.nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->regions = var_regrid
  outfile->region_names = region_names
  
end

