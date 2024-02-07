load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

weights_bilinear = "/scratch2/NCEPDEV/land/data/evaluation/SMOPS/C96/SMOPS-C96_bilinear_wts.nc"
numlocs = 18320

Opt                = True
;Opt@Debug          = True
;Opt@PrintTimings   = True

  infile = addfile("/scratch2/NCEPDEV/land/data/evaluation/SMOPS/orig/NPR_SMOPS_CMAP_D20200801_extn.nc","r")
  
;;;;;;;;;;;;;;;;;;;;

  data = infile->Blended_SM

  var_regrid = ESMF_regrid_with_weights(data,weights_bilinear,Opt)

  outname = "smops_test.nc"
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
  outfile->Blended_SM = var_regrid

end

