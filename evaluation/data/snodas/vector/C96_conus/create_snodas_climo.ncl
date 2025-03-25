
; create gleam climatology from 2013-2022
;   Jan 2013 is index 24 in a and b file

begin

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.8a_E_C96_conus.nc","r")
latitude = infile->latitude
num_locations = dimsizes(latitude)

GLEAM_38a_E_in = infile->E(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.7b_E_C96_conus.nc","r")
GLEAM_37b_E_in = infile->E(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.6a_E_C96_conus.nc","r")
GLEAM_36a_E_in = infile->E(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.6b_E_C96_conus.nc","r")
GLEAM_36b_E_in = infile->E(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.8a_Et_C96_conus.nc","r")
GLEAM_38a_Et_in = infile->Et(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.7b_Et_C96_conus.nc","r")
GLEAM_37b_Et_in = infile->Et(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.6a_Et_C96_conus.nc","r")
GLEAM_36a_Et_in = infile->Et(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.6b_Et_C96_conus.nc","r")
GLEAM_36b_Et_in = infile->Et(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.8a_Eb_C96_conus.nc","r")
GLEAM_38a_Eb_in = infile->Eb(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.7b_Eb_C96_conus.nc","r")
GLEAM_37b_Eb_in = infile->Eb(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.6a_Eb_C96_conus.nc","r")
GLEAM_36a_Eb_in = infile->Eb(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.6b_Eb_C96_conus.nc","r")
GLEAM_36b_Eb_in = infile->Eb(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.8a_Ei_C96_conus.nc","r")
GLEAM_38a_Ei_in = infile->Ei(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.7b_Ei_C96_conus.nc","r")
GLEAM_37b_Ei_in = infile->Ei(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.6a_Ei_C96_conus.nc","r")
GLEAM_36a_Ei_in = infile->Ei(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.6b_Ei_C96_conus.nc","r")
GLEAM_36b_Ei_in = infile->Ei(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.8a_Es_C96_conus.nc","r")
GLEAM_38a_Es_in = infile->Es(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.7b_Es_C96_conus.nc","r")
GLEAM_37b_Es_in = infile->Es(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.6a_Es_C96_conus.nc","r")
GLEAM_36a_Es_in = infile->Es(location | :, time | :)

infile  = addfile("/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/GLEAM_v3.6b_Es_C96_conus.nc","r")
GLEAM_36b_Es_in = infile->Es(location | :, time | :)

GLEAM_38a_E = new((/12,num_locations/),float)
 GLEAM_38a_E!0 = "month"
 GLEAM_38a_E!1 = "locations"
GLEAM_38a_Et = GLEAM_38a_E
GLEAM_38a_Ei = GLEAM_38a_E
GLEAM_38a_Eb = GLEAM_38a_E
GLEAM_38a_Es = GLEAM_38a_E

GLEAM_37b_E  = GLEAM_38a_E
GLEAM_37b_Et = GLEAM_38a_E
GLEAM_37b_Ei = GLEAM_38a_E
GLEAM_37b_Eb = GLEAM_38a_E
GLEAM_37b_Es = GLEAM_38a_E

GLEAM_36a_E  = GLEAM_38a_E
GLEAM_36a_Et = GLEAM_38a_E
GLEAM_36a_Ei = GLEAM_38a_E
GLEAM_36a_Eb = GLEAM_38a_E
GLEAM_36a_Es = GLEAM_38a_E

GLEAM_36b_E  = GLEAM_38a_E
GLEAM_36b_Et = GLEAM_38a_E
GLEAM_36b_Ei = GLEAM_38a_E
GLEAM_36b_Eb = GLEAM_38a_E
GLEAM_36b_Es = GLEAM_38a_E

do imm = 0, 11

  GLEAM_38a_E(imm,:)  = dim_avg(GLEAM_38a_E_in(:,24+imm::12))
  GLEAM_37b_E(imm,:)  = dim_avg(GLEAM_37b_E_in(:,24+imm::12))
  GLEAM_36a_E(imm,:)  = dim_avg(GLEAM_36a_E_in(:,24+imm::12))
  GLEAM_36b_E(imm,:)  = dim_avg(GLEAM_36b_E_in(:,24+imm::12))

  GLEAM_38a_Et(imm,:) = dim_avg(GLEAM_38a_Et_in(:,24+imm::12))
  GLEAM_37b_Et(imm,:) = dim_avg(GLEAM_37b_Et_in(:,24+imm::12))
  GLEAM_36a_Et(imm,:) = dim_avg(GLEAM_36a_Et_in(:,24+imm::12))
  GLEAM_36b_Et(imm,:) = dim_avg(GLEAM_36b_Et_in(:,24+imm::12))

  GLEAM_38a_Eb(imm,:) = dim_avg(GLEAM_38a_Eb_in(:,24+imm::12))
  GLEAM_37b_Eb(imm,:) = dim_avg(GLEAM_37b_Eb_in(:,24+imm::12))
  GLEAM_36a_Eb(imm,:) = dim_avg(GLEAM_36a_Eb_in(:,24+imm::12))
  GLEAM_36b_Eb(imm,:) = dim_avg(GLEAM_36b_Eb_in(:,24+imm::12))

  GLEAM_38a_Ei(imm,:) = dim_avg(GLEAM_38a_Ei_in(:,24+imm::12))
  GLEAM_37b_Ei(imm,:) = dim_avg(GLEAM_37b_Ei_in(:,24+imm::12))
  GLEAM_36a_Ei(imm,:) = dim_avg(GLEAM_36a_Ei_in(:,24+imm::12))
  GLEAM_36b_Ei(imm,:) = dim_avg(GLEAM_36b_Ei_in(:,24+imm::12))

  GLEAM_38a_Es(imm,:) = dim_avg(GLEAM_38a_Es_in(:,24+imm::12))
  GLEAM_37b_Es(imm,:) = dim_avg(GLEAM_37b_Es_in(:,24+imm::12))
  GLEAM_36a_Es(imm,:) = dim_avg(GLEAM_36a_Es_in(:,24+imm::12))
  GLEAM_36b_Es(imm,:) = dim_avg(GLEAM_36b_Es_in(:,24+imm::12))

end do

outname = "/scratch2/NCEPDEV/land/data/evaluation/GLEAM/C96_conus/climo/GLEAM_C96_conus_climatology.nc"
 system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
outfile = addfile(outname,"c")
outfile->GLEAM_38a_E  = GLEAM_38a_E
outfile->GLEAM_37b_E  = GLEAM_37b_E
outfile->GLEAM_36a_E  = GLEAM_36a_E
outfile->GLEAM_36b_E  = GLEAM_36b_E

outfile->GLEAM_38a_Et = GLEAM_38a_Et
outfile->GLEAM_37b_Et = GLEAM_37b_Et
outfile->GLEAM_36a_Et = GLEAM_36a_Et
outfile->GLEAM_36b_Et = GLEAM_36b_Et

outfile->GLEAM_38a_Eb = GLEAM_38a_Eb
outfile->GLEAM_37b_Eb = GLEAM_37b_Eb
outfile->GLEAM_36a_Eb = GLEAM_36a_Eb
outfile->GLEAM_36b_Eb = GLEAM_36b_Eb

outfile->GLEAM_38a_Ei = GLEAM_38a_Ei
outfile->GLEAM_37b_Ei = GLEAM_37b_Ei
outfile->GLEAM_36a_Ei = GLEAM_36a_Ei
outfile->GLEAM_36b_Ei = GLEAM_36b_Ei

outfile->GLEAM_38a_Es = GLEAM_38a_Es
outfile->GLEAM_37b_Es = GLEAM_37b_Es
outfile->GLEAM_36a_Es = GLEAM_36a_Es
outfile->GLEAM_36b_Es = GLEAM_36b_Es

end
