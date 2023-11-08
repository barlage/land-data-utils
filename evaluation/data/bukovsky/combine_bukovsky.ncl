begin

longnames = (/"ColdNEPacific" ,"WarmNEPacific","PacificNW"     ,"PacificSW"  ,"Southwest"    , \
              "Mezquital"     ,"NRockies"     ,"SRockies"      ,"GreatBasin" ,"NPlains"      , \
              "CPlains"       ,"SPlains"      ,"Prairie"       ,"GreatLakes" ,"Appalachia"   , \
              "DeepSouth"     ,"Southeast"    ,"WarmNWAtlantic","MidAtlantic","NorthAtlantic", \
              "ColdNWAtlantic","EastBoreal"   ,"WestBoreal"    ,"EastTaiga"  ,"WestTaiga"    , \
              "CentralTundra" ,"WestTundra"   ,"EastTundra"    ,"Hudson"     ,"LabradorSea"  , \
              "Greenland" /)

infile = addfile("/scratch2/NCEPDEV/land/data/evaluation/BUKOVSKY/region-masks/ColdNEPacific.nc","r")

lat = infile->lat
lon = infile->lon
region = new((/dimsizes(lat),dimsizes(lon)/),integer)
region = 0
region!0 = "lat"
region!1 = "lon"
region&lat = lat
region&lon = lon
region@standard_name = "region_code"
region@long_name = "Bukovsky region code"
region_names = new((/31,15/),character)
region_names!0 = "region"
region_names!1 = "name_length"

do ireg = 0, 30

  infile = addfile("/scratch2/NCEPDEV/land/data/evaluation/BUKOVSKY/region-masks/"+longnames(ireg)+".nc","r")

  region_mask = infile->mask

  region = where(ismissing(region_mask),region,(ireg+1))

  slength = dimsizes(stringtochar(longnames(ireg)))
  region_names(ireg,0:slength-1) = stringtochar(longnames(ireg))

end do

region = mask(region,region.gt.0,True)

outfile = addfile("/scratch2/NCEPDEV/land/data/evaluation/BUKOVSKY/combined/bukovsky_regions.nc", "c")
outfile->region = region
outfile->region_names = region_names

outfile@Region01 = longnames(0)
outfile@Region02 = longnames(1)
outfile@Region03 = longnames(2)
outfile@Region04 = longnames(3)
outfile@Region05 = longnames(4)
outfile@Region06 = longnames(5)
outfile@Region07 = longnames(6)
outfile@Region08 = longnames(7)
outfile@Region09 = longnames(8)
outfile@Region10 = longnames(9)
outfile@Region11 = longnames(10)
outfile@Region12 = longnames(11)
outfile@Region13 = longnames(12)
outfile@Region14 = longnames(13)
outfile@Region15 = longnames(14)
outfile@Region16 = longnames(15)
outfile@Region17 = longnames(16)
outfile@Region18 = longnames(17)
outfile@Region19 = longnames(18)
outfile@Region20 = longnames(19)
outfile@Region21 = longnames(20)
outfile@Region22 = longnames(21)
outfile@Region23 = longnames(22)
outfile@Region24 = longnames(23)
outfile@Region25 = longnames(24)
outfile@Region26 = longnames(25)
outfile@Region27 = longnames(26)
outfile@Region28 = longnames(27)
outfile@Region29 = longnames(28)
outfile@Region30 = longnames(29)
outfile@Region31 = longnames(30)

end
