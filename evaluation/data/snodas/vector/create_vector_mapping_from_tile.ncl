
begin

tilepath = "/scratch2/NCEPDEV/land/data/evaluation/SNODAS/mapping/"
outpath  = "/scratch2/NCEPDEV/land/data/evaluation/SNODAS/mapping/"
fv3path = "/scratch1/NCEPDEV/global/glopara/fix/orog/20220805/C96.mx100/"

fv3_lat_min =  25.0  ; use these to define a region of the fv3 grid to use
fv3_lat_max =  53.0  ;   e.g., the C96_conus grid
fv3_lon_min = 235.0
fv3_lon_max = 293.0

fv3_lat_min =  40.0  ; use these to define a region of the fv3 grid to use
fv3_lat_max =  42.0  ;   e.g., the C96_conus grid
fv3_lon_min = 260.0
fv3_lon_max = 262.0

source_lat_min =  22.0  ; use these to define the limits of the source data to
source_lat_max =  60.0  ;   reduce the number of fv3 grids checked
source_lon_min = 228.0
source_lon_max = 300.0

fv3_size = 96
ocn_size = "mx100"
outname = outpath+"snodas_vector_mapping_C"+fv3_size+"_conus.nc"
  system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
newfile = addfile(outname,"c")

tilename = tilepath+"snodas_fv3_mapping_C"+fv3_size+".nc"
tilefile = addfile(tilename,"r")
tile   = tilefile->tile
tile_i = tilefile->tile_i
tile_j = tilefile->tile_j

vector_location    = new(dimsizes(tile),integer)
vector_location!0  = "lat"
vector_location!1  = "lon"
vector_location@_FillValue = -9999
vector_location = -9999

nloc = -1

do itile = 1,6

print("Starting tile: "+itile)

 maskfile = addfile(fv3path+"oro_C"+fv3_size+"."+ocn_size+".tile"+itile+".nc","r")

 inmask = maskfile->land_frac 
 inlat  = maskfile->geolat
 inlon  = maskfile->geolon

 ndims = dimsizes(inmask)
 
 do idim0 = 0, ndims(0)-1
 do idim1 = 0, ndims(1)-1
 
   if(inmask(idim0,idim1).gt.0   .and. \
       inlat(idim0,idim1).gt.fv3_lat_min .and. inlat(idim0,idim1).lt.fv3_lat_max .and. \
       inlon(idim0,idim1).gt.fv3_lon_min .and. inlon(idim0,idim1).lt.fv3_lon_max ) then

     nloc = nloc + 1

     if(inlat(idim0,idim1).gt.source_lat_min .and. inlat(idim0,idim1).lt.source_lat_max .and. \
        inlon(idim0,idim1).gt.source_lon_min .and. inlon(idim0,idim1).lt.source_lon_max ) then

       vector_location = where(tile.eq.itile .and. tile_i.eq.(idim0+1) .and. tile_j.eq.(idim1+1), \
                          nloc, vector_location)

     end if
   
   end if
   
 end do
 end do
 
 print("number of cumulative locs: "+(nloc+1))

end do

newfile->vector_location = vector_location

end

