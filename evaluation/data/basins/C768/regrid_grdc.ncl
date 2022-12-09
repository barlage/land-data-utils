load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

weights_nearest = "/scratch2/NCEPDEV/land/data/evaluation/basins/C768/GRDC-C768_nearest_wts.nc"

grdc_filename = "/scratch2/NCEPDEV/land/data/evaluation/basins/world_basins.nc"
infile = addfile(grdc_filename,"r")

basins = (/ infile->Band1 /)
  
Opt                = True
;Opt@PrintTimings   = True

var_regrid = ESMF_regrid_with_weights(basins,weights_nearest,Opt)
  var_regrid!0 = "location"
  delete(var_regrid@lat1d)
  delete(var_regrid@lon1d)

  outname = "/scratch2/NCEPDEV/land/data/evaluation/basins/C768/GRDC_C768.nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->basins = var_regrid
  
end

