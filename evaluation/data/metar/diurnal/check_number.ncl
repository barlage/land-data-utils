
; script to calculate the number of stations that have diurnal climatologies above a certain year count

begin

infile = addfile("/scratch2/NCEPDEV/land/data/evaluation/METAR_SYNOP/dinural/metar_diurnal.nc", "r")

t2_climo_count = infile->t2_climo_count

do imm = 0, 11
  print("Number valid in mo "+(imm+1)+" : "+ num(t2_climo_count(:,imm).eq.10 ))
  print("Number valid in mo "+(imm+1)+" : "+ num(t2_climo_count(:,imm).ge.9 ))
  print("Number valid in mo "+(imm+1)+" : "+ num(t2_climo_count(:,imm).ge.8 ))
  print(" ")
end do


end
