
begin

; create filename and overwrite if present

if(grid_extent.eq."global") then
  outname = output_path+"ufs-land_"+atm_res+"."+ocn_res+"_"+grid_version+"_corners.nc"
elseif(grid_extent.eq."conus") then
  outname = output_path+"ufs-land_"+atm_res+"."+ocn_res+"."+grid_extent+"_"+grid_version+"_corners.nc"
else
  print("problem with grid_extent in extract_corners")
  exit
end if
  system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
newfile = addfile(outname,"c")

; set the maximum dimension

maskfile = addfile(fixfile_path+atm_res+"/"+atm_res+"."+ocn_res+"_oro_data.tile1.nc","r")
maskdims = getfiledimsizes(maskfile)

maxdim = maskdims(0)*maskdims(1)*6
latitude           = new(maxdim,double)
latitude!0         = "location"
longitude          = latitude
latitude_corners   = new((/maxdim,4/),double)
latitude_corners!0 = "location"
latitude_corners!1 = "corners"
longitude_corners  = latitude_corners

nloc = -1

do itile = 1,6

print("Starting tile: "+itile)

 maskfile = addfile(fixfile_path+atm_res+"/"+atm_res+"."+ocn_res+"_oro_data.tile"+itile+".nc","r")
 cornfile = addfile(fixfile_path+atm_res+"/"+atm_res+"_grid.tile"+itile+".nc","r")

 inmask = maskfile->land_frac 
 inlat  = maskfile->geolat
 inlon  = maskfile->geolon
 inx    = cornfile->x
 iny    = cornfile->y

 ndims = dimsizes(inmask)
 
 if(grid_extent.eq."conus") then

   inmask = where(inmask.gt.0 .and. \
                  inlat.gt.25  .and.  inlat.lt.53 .and. \
                  inlon.gt.235 .and.  inlon.lt.293, 1, 0)
 
 end if

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
 
 print("number of cumulative locs (1-based): "+(nloc+1))

end do

newfile->latitude = latitude(0:nloc)
newfile->longitude = longitude(0:nloc)
newfile->latitude_corners = latitude_corners(0:nloc,:)
newfile->longitude_corners = longitude_corners(0:nloc,:)

end

