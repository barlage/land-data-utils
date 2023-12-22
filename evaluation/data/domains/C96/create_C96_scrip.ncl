begin

pts_scrip_filename = "/scratch2/NCEPDEV/land/data/evaluation/domains/C96/fix_20231027/C96_SCRIP.nc"

fixpath = "/scratch1/NCEPDEV/global/glopara/fix/orog/20231027/C96/"

nloc = -1

maxdim = 96*96*6
latitude           = new(maxdim,double)
latitude!0         = "location"
longitude          = latitude
latitude_corners   = new((/maxdim,4/),double)
latitude_corners!0 = "location"
latitude_corners!1 = "corners"
longitude_corners  = latitude_corners

do itile = 1,6

print("Starting tile: "+itile)

 mask_file = addfile(fixpath+"C96.mx100_oro_data.tile"+itile+".nc","r")
 corner_file = addfile(fixpath+"C96_grid.tile"+itile+".nc","r")

 inmask = mask_file->land_frac 
 inlat  = mask_file->geolat
 inlon  = mask_file->geolon
 inx    = corner_file->x
 iny    = corner_file->y

 ndims = dimsizes(inmask)
 
 do idim0 = 0, ndims(0)-1
 do idim1 = 0, ndims(1)-1
 
   if(inmask(idim0,idim1).gt.0) then
     nloc = nloc + 1
     latitude(nloc)            = (/ iny   (idim0*2+1,idim1*2+1) /)
     longitude(nloc)           = (/ inx   (idim0*2+1,idim1*2+1) /)
     latitude_corners(nloc,0)  = (/ iny   (idim0*2  ,idim1*2) /)
     latitude_corners(nloc,1)  = (/ iny   (idim0*2  ,idim1*2+2) /)
     latitude_corners(nloc,2)  = (/ iny   (idim0*2+2,idim1*2+2) /)
     latitude_corners(nloc,3)  = (/ iny   (idim0*2+2,idim1*2) /)
     longitude_corners(nloc,0) = (/ inx   (idim0*2,  idim1*2) /)
     longitude_corners(nloc,1) = (/ inx   (idim0*2  ,idim1*2+2) /)
     longitude_corners(nloc,2) = (/ inx   (idim0*2+2,idim1*2+2) /)
     longitude_corners(nloc,3) = (/ inx   (idim0*2+2,idim1*2) /)
   end if
   
 end do
 end do
 
 print("number of cumulative locs: "+(nloc+1))

end do

; Create destination grid
;----------------------------------------------------------------------

  system("if [ -e "+pts_scrip_filename+" ]; then rm -f "+pts_scrip_filename+ ";fi")
  pts_scrip = addfile(pts_scrip_filename,"c")
  grid_size = nloc+1
  print(grid_size)
  grid_corners = 4
  grid_rank = 1

  grid_dims = new((/grid_rank/),integer)
  grid_dims!0 = "grid_rank"
  grid_dims(0) = grid_size

  grid_center_lat = new((/grid_size/),double)
  grid_center_lat!0 = "grid_size"
  grid_center_lat@units = "degrees"
  grid_center_lat = (/ latitude(0:nloc) /)

  grid_center_lon = grid_center_lat
  grid_center_lon = (/ longitude(0:nloc) /)

  grid_imask = new((/grid_size/),integer)
  grid_imask!0 = "grid_size"
  grid_imask = 1
  
  grid_corner_lat = new((/grid_size,grid_corners/),double)
  grid_corner_lat!0 = "grid_size"
  grid_corner_lat!1 = "grid_corners"
  grid_corner_lat@units = "degrees"
  grid_corner_lat = (/ latitude_corners(0:nloc,:) /)
  
  grid_corner_lon = grid_corner_lat
  grid_corner_lon = (/ longitude_corners(0:nloc,:) /)
  
  pts_scrip->grid_dims = grid_dims
  pts_scrip->grid_center_lat = grid_center_lat
  pts_scrip->grid_center_lon = grid_center_lon
  pts_scrip->grid_imask = grid_imask
  pts_scrip->grid_corner_lat = grid_corner_lat
  pts_scrip->grid_corner_lon = grid_corner_lon

end

