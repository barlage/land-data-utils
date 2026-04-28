begin

infile = addfile("/scratch4/NCEPDEV/land/data/evaluation/GSCD/original/GSCD_v2.0.nc","r")

outname  = "/scratch4/NCEPDEV/land/data/evaluation/GSCD/original/GSCD_v2.0_postprocess.nc"
system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
outfile = addfile(outname,"c")

latitude  = infile->latitude
longitude = infile->longitude

data_in  = infile->QMEAN
qmean = data_in(latitude | :, longitude | :)
outfile->QMEAN = qmean
data_in  = infile->QMEAN_unc
qmean_unc = data_in(latitude | :, longitude | :)
outfile->QMEAN_uncertainty = qmean_unc

data_in  = infile->RC
rc = data_in(latitude | :, longitude | :)
outfile->RC = rc
data_in  = infile->RC_unc
rc_unc = data_in(latitude | :, longitude | :)
outfile->RC_uncertainty = rc_unc

precip = qmean
;rc_adj = where(rc.eq.0,0.01,rc)
;precip = qmean/rc_adj
rc_mask = mask(rc,rc.gt.0,True)
precip = where(rc_mask.gt.0, qmean/rc_mask, 0.0)
precip@long_name = "precipitation estimated using RC and QMEAN"
precip@units = "mm/yr"
outfile->PRECIP = precip

data_in  = infile->BFI1
bfi1 = data_in(latitude | :, longitude | :)
outfile->BFI1 = bfi1
data_in  = infile->BFI1_unc
bfi1_unc = data_in(latitude | :, longitude | :)
outfile->BFI1_uncertainty = bfi1_unc
bf1 = qmean
bf1 = bfi1*qmean
bf1@long_name = "baseflow estimated using BFI1 and QMEAN"
bf1@units = "mm/yr"
outfile->BF1 = bf1

data_in  = infile->BFI2
bfi2 = data_in(latitude | :, longitude | :)
outfile->BFI2 = bfi2
data_in  = infile->BFI2_unc
bfi2_unc = data_in(latitude | :, longitude | :)
outfile->BFI2_uncertainty = bfi2_unc
bf2 = qmean
bf2 = bfi2*qmean
bf2@long_name = "baseflow estimated using BFI2 and QMEAN"
bf2@units = "mm/yr"
outfile->BF2 = bf2

data_in  = infile->BFI3
bfi3 = data_in(latitude | :, longitude | :)
outfile->BFI3 = bfi3
data_in  = infile->BFI3_unc
bfi3_unc = data_in(latitude | :, longitude | :)
outfile->BFI3_uncertainty = bfi3_unc
bf3 = qmean
bf3 = bfi3*qmean
bf3@long_name = "baseflow estimated using BFI3 and QMEAN"
bf3@units = "mm/yr"
outfile->BF3 = bf3

data_in  = infile->BFI4
bfi4 = data_in(latitude | :, longitude | :)
outfile->BFI4 = bfi4
data_in  = infile->BFI4_unc
bfi4_unc = data_in(latitude | :, longitude | :)
outfile->BFI4_uncertainty = bfi4_unc
bf4 = qmean
bf4 = bfi4*qmean
bf4@long_name = "baseflow estimated using BFI4 and QMEAN"
bf4@units = "mm/yr"
outfile->BF4 = bf4

end
