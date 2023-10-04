load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

weights_nearest = "/scratch2/NCEPDEV/land/data/evaluation/BUKOVSKY/hr/BUKOVSKY-hr_nearest_wts.nc"

bukovsky_filename = "/scratch2/NCEPDEV/land/data/evaluation/BUKOVSKY/combined/bukovsky_regions.nc"
infile = addfile(bukovsky_filename,"r")

bukovsky = (/ infile->region /)
region_names = infile->region_names
  
Opt                = True
;Opt@PrintTimings   = True

var_regrid = ESMF_regrid_with_weights(bukovsky,weights_nearest,Opt)

  outname = "/scratch2/NCEPDEV/land/data/evaluation/BUKOVSKY/hr/BUKOVSKY_hr.nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->regions = var_regrid
  outfile->region_names = region_names
  
end

