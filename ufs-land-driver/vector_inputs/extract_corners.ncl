
begin

 atm_res      = keyword_values("regrid_parameter_assignment","atm_res"     ,"string")
 ocn_res      = keyword_values("regrid_parameter_assignment","ocn_res"     ,"string")
 grid_version = keyword_values("regrid_parameter_assignment","grid_version","string")
 output_path  = keyword_values("regrid_parameter_assignment","output_path" ,"string")
 fixfile_path = keyword_values("regrid_parameter_assignment","fixfile_path","string")
 grid_extent  = keyword_values("regrid_parameter_assignment","grid_extent" ,"string")

; create filename and overwrite if present

if(grid_extent.eq."global") then
  if(ocn_res.eq."mx000") then
    outname = output_path+"ufs-land_"+atm_res+"_"+grid_version+"_corners.nc"
  else
    outname = output_path+"ufs-land_"+atm_res+"."+ocn_res+"_"+grid_version+"_corners.nc"
  end if
elseif(grid_extent.eq."conus") then
  outname = output_path+"ufs-land_"+atm_res+"."+ocn_res+"."+grid_extent+"_"+grid_version+"_corners.nc"
elseif(grid_extent.eq."regional") then
  if(ocn_res.eq."mx000") then
    outname = output_path+"ufs-land_"+atm_res+"_"+grid_version+"_regional_corners.nc"
  else
    outname = output_path+"ufs-land_"+atm_res+"."+ocn_res+"_"+grid_version+"_regional_corners.nc"
  end if
else
  print("problem with grid_extent in extract_corners")
  exit
end if
  system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
newfile = addfile(outname,"c")

; deal with some differences between global and regional domains

if(grid_extent.eq."regional") then
  number_of_tiles = 1
  tile_index_beg  = 7
  tile_index_end  = 7
else
  number_of_tiles = 6
  tile_index_beg  = 1
  tile_index_end  = 6
end if

; read an oro file to set the maximum dimension

if(grid_extent.eq."global".or.grid_extent.eq."conus") then
  if(ocn_res.eq."mx000") then
    maskfile = addfile(fixfile_path+atm_res+"/"+atm_res+"_oro_data.tile1.nc","r")
  else
    maskfile = addfile(fixfile_path+atm_res+"/"+atm_res+"."+ocn_res+"_oro_data.tile1.nc","r")
  end if
elseif(grid_extent.eq."regional") then
  if(ocn_res.eq."mx000") then
    maskfile = addfile(fixfile_path+atm_res+"/"+atm_res+"_oro_data.tile7.nc","r")
  else
    maskfile = addfile(fixfile_path+atm_res+"/"+atm_res+"."+ocn_res+"_oro_data.tile7.nc","r")
  end if
end if
maskdims = getfiledimsizes(maskfile)

maxdim = maskdims(0)*maskdims(1)*number_of_tiles
latitude           = new(maxdim,double)
latitude!0         = "location"
longitude          = latitude
latitude_corners   = new((/maxdim,4/),double)
latitude_corners!0 = "location"
latitude_corners!1 = "corners"
longitude_corners  = latitude_corners

nloc = -1

do itile = tile_index_beg, tile_index_end

print("Starting tile: "+itile)

 if(ocn_res.eq."mx000") then
   maskfile = addfile(fixfile_path+atm_res+"/"+atm_res+"_oro_data.tile"+itile+".nc","r")
 else
   maskfile = addfile(fixfile_path+atm_res+"/"+atm_res+"."+ocn_res+"_oro_data.tile"+itile+".nc","r")
 end if
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

