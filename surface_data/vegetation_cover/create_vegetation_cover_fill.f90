program create_vegetation_cover_nofill

use netcdf

implicit none

character*256 :: filename_crop    = '/scratch4/NCEPDEV/land/data/fix/original/surface_type/vegetation_cover/SynPct2020_GEO30arcsec_Cropland.nc'
character*256 :: filename_grass   = '/scratch4/NCEPDEV/land/data/fix/original/surface_type/vegetation_cover/SynPct2020_GEO30arcsec_Grassland.nc'
character*256 :: filename_forest  = '/scratch4/NCEPDEV/land/data/fix/original/surface_type/vegetation_cover/SynPct2020_GEO30arcsec_Forest.nc'
character*256 :: filename_shrub   = '/scratch4/NCEPDEV/land/data/fix/original/surface_type/vegetation_cover/SynPct2020_GEO30arcsec_Shrubland.nc'
character*256 :: filename_wetland = '/scratch4/NCEPDEV/land/data/fix/original/surface_type/vegetation_cover/SynPct2020_GEO30arcsec_Wetland.nc'
character*256 :: filename_water   = '/scratch4/NCEPDEV/land/data/fix/original/surface_type/vegetation_cover/SynPct2020_GEO30arcsec_Water.nc'
character*256 :: vegtype_in       = '/scratch4/NCEPDEV/land/data/fix/original/surface_type/vegetation_type/vegetation_type.viirs.v3.igbp.30s.fill.uncompressed.nc'

character*256 :: filename_out = '/scratch4/NCEPDEV/land/data/fix/original/surface_type/vegetation_cover/vegetation_cover.nesdis.30s.uncompressed.fill.nc'

integer  , parameter ::  jdim = 21600
integer  , parameter ::  idim = 43200

integer*1, allocatable :: vegetation_cover (:,:,:)
integer*1, allocatable :: vegetation_cover_save (:,:,:)
integer*1, allocatable ::  vegetation_type (:,:,:)
integer*1, allocatable ::          crop_in (:,:)
integer*1, allocatable ::         grass_in (:,:)
integer*1, allocatable ::        forest_in (:,:)
integer*1, allocatable ::         shrub_in (:,:)
integer*1, allocatable ::       wetland_in (:,:)
integer*1, allocatable ::         water_in (:,:)
logical  , allocatable ::         non_bare (:,:)
real*8   , allocatable ::  latitude_center (:)
real*8   , allocatable :: longitude_center (:)
real*8   , allocatable ::  latitude_corner (:)
real*8   , allocatable :: longitude_corner (:)
integer  , allocatable ::       cover_mini (:,:)

integer :: error
integer :: ncid_in,ncid_out,ncdim_jdim,ncdim_jdim_p1,ncdim_idim,ncdim_idim_p1,ncdim_time
integer :: varid
integer :: count_non_bare, sum_non_bare, num_missing, imax, imin, jmax, jmin
integer :: i, j
integer :: land_check
integer*1, parameter ::  nodata_byte = -99
real    :: data_real

allocate(latitude_center(jdim))
allocate(latitude_corner(jdim+1))
allocate(longitude_center(idim))
allocate(longitude_corner(idim+1))

do i = 1, idim
  longitude_corner(i) = -180.d0 + (i-1)*1.d0/120.d0
  longitude_center(i) = longitude_corner(i) + 1.d0/120.d0/2.d0
end do
longitude_corner(idim+1) = 180.d0

do j = 1, jdim
  latitude_corner(j) = -90.d0 + (j-1)*1.d0/120.d0
  latitude_center(j) = latitude_corner(j) + 1.d0/120.d0/2.d0
end do
latitude_corner(jdim+1) = 90.d0

!====================================
! create output file

error = nf90_create(trim(filename_out),nf90_netcdf4, ncid_out)
  call netcdf_err(error, 'creating file: '//trim(filename_out) )

error = nf90_def_dim(ncid_out,"jdim" ,jdim ,ncdim_jdim) 
  call netcdf_err(error, 'creating dimension: jdim')
error = nf90_def_dim(ncid_out,"jdim_p1" ,jdim+1 ,ncdim_jdim_p1) 
  call netcdf_err(error, 'creating dimension: jdim_p1')
error = nf90_def_dim(ncid_out,"idim" ,idim ,ncdim_idim) 
  call netcdf_err(error, 'creating dimension: idim')
error = nf90_def_dim(ncid_out,"idim_p1" ,idim+1 ,ncdim_idim_p1) 
  call netcdf_err(error, 'creating dimension: idim_p1')
error = nf90_def_dim(ncid_out,"time" ,1 ,ncdim_time) 
  call netcdf_err(error, 'creating dimension: time')

error = nf90_def_var(ncid_out,"lat",NF90_DOUBLE,(/ncdim_jdim/),varid)
  if(error /= nf90_noerr) stop "problem defining lat"
  error = nf90_put_att(ncid_out, varid, "long_name", "grid cell center latitude")
  if(error /= nf90_noerr) stop "problem adding lat attibute"

error = nf90_def_var(ncid_out,"lat_corner",NF90_DOUBLE,(/ncdim_jdim_p1/),varid)
  if(error /= nf90_noerr) stop "problem defining lat_corner"
  error = nf90_put_att(ncid_out, varid, "long_name", "grid cell corner latitude")
  if(error /= nf90_noerr) stop "problem adding lat_corner attibute"

error = nf90_def_var(ncid_out,"lon",NF90_DOUBLE,(/ncdim_idim/),varid) 
  if(error /= nf90_noerr) stop "problem defining lon"
  error = nf90_put_att(ncid_out, varid, "long_name", "grid cell center longitude")
  if(error /= nf90_noerr) stop "problem adding lon attibute"

error = nf90_def_var(ncid_out,"lon_corner",NF90_DOUBLE,(/ncdim_idim_p1/),varid) 
  if(error /= nf90_noerr) stop "problem defining lon_corner"
  error = nf90_put_att(ncid_out, varid, "long_name", "grid cell corner longitude")
  if(error /= nf90_noerr) stop "problem adding lon_corner attibute"

error = nf90_def_var(ncid_out, "vegetation_cover", NF90_BYTE, (/ncdim_idim,ncdim_jdim,ncdim_time/), varid)
 call netcdf_err(error, "defining variable: vegetation_cover")
  error = nf90_put_att(ncid_out, varid, "long_name", "2020 Global vegetation cover product, 30 arcsecond")
   call netcdf_err(error, "defining attribute: long_name variable: vegetation_cover")
  error = nf90_put_att(ncid_out, varid, "units", "fraction")
   call netcdf_err(error, "defining attribute: units variable: vegetation_cover")
  error = nf90_put_att(ncid_out, varid, "scale_factor", 0.01)
   call netcdf_err(error, "defining attribute: scale_factor variable: vegetation_cover")

error = nf90_put_att(ncid_out, NF90_GLOBAL, "description", "derived from 2020 Global surface fraction (%) product, 30 arcsecond, lat/lon original")
 call netcdf_err(error, "defining attribute: description: global")
error = nf90_put_att(ncid_out, NF90_GLOBAL, "data_source", "Multi-source global 10m-30m grass/crop/shrub/wetland/snow/forest/barren/water/urban products")
 call netcdf_err(error, "defining attribute: data_source : global")
error = nf90_put_att(ncid_out, NF90_GLOBAL, "developer", "Chengquan Huang (cqhuang@umd.edu)")
 call netcdf_err(error, "defining attribute: developer : global")
error = nf90_put_att(ncid_out, NF90_GLOBAL, "nesdis_poc", "Xiwu Zhan (xiwu.zhan@noaa.gov)")
 call netcdf_err(error, "defining attribute: nesdis_poc : global")
error = nf90_put_att(ncid_out, NF90_GLOBAL, "contributors", "Ivan Csiszar (ivan.csiszar@noaa.gov)")
 call netcdf_err(error, "defining attribute: contributors : global")

error = nf90_enddef(ncid_out) 
 call netcdf_err(error, "ending define mode")

error = nf90_inq_varid(ncid_out, 'lat', varid)
 call netcdf_err(error, 'inquire variable: lat' )
error = nf90_put_var(ncid_out, varid, latitude_center)
 call netcdf_err(error, 'writing variable: lat' )
    
error = nf90_inq_varid(ncid_out, 'lon', varid)
 call netcdf_err(error, 'inquire variable: lon' )
error = nf90_put_var(ncid_out, varid, longitude_center)
 call netcdf_err(error, 'writing variable: lon' )
    
error = nf90_inq_varid(ncid_out, 'lat_corner', varid)
 call netcdf_err(error, 'inquire variable: lat_corner' )
error = nf90_put_var(ncid_out, varid, latitude_corner)
 call netcdf_err(error, 'writing variable: lat_corner' )
    
error = nf90_inq_varid(ncid_out, 'lon_corner', varid)
 call netcdf_err(error, 'inquire variable: lon_corner' )
error = nf90_put_var(ncid_out, varid, longitude_corner)
 call netcdf_err(error, 'writing variable: lon_corner' )

error = nf90_close(ncid_out) 
 call netcdf_err(error, "closing ncid_out")

allocate(   crop_in(idim,jdim))
allocate(  grass_in(idim,jdim))
allocate( forest_in(idim,jdim))
allocate(  shrub_in(idim,jdim))
allocate(wetland_in(idim,jdim))
allocate(  water_in(idim,jdim))
allocate(vegetation_cover(idim,jdim,1))

!====================================
! read data files

!====================================
! cropland

error = nf90_open(trim(filename_crop), nf90_nowrite, ncid_in)
  call netcdf_err(error, 'opening file: '//trim(filename_crop) )
  
error = nf90_inq_varid(ncid_in, 'Cropland_fraction', varid)
 call netcdf_err(error, 'inquire Cropland_fraction variable' )

error = nf90_get_var(ncid_in, varid, crop_in)
 call netcdf_err(error, 'reading crop_in variable' )

error = nf90_close(ncid_in)
 call netcdf_err(error, 'closing file: '//trim(filename_crop) )

print*, 'crop_in max: ', maxval(crop_in)
print*, 'crop_in min: ', minval(crop_in)

!====================================
! grassland

error = nf90_open(trim(filename_grass), nf90_nowrite, ncid_in)
  call netcdf_err(error, 'opening file: '//trim(filename_grass) )
  
error = nf90_inq_varid(ncid_in, 'Grassland_fraction', varid)
 call netcdf_err(error, 'inquire Grassland_fraction variable' )

error = nf90_get_var(ncid_in, varid, grass_in)
 call netcdf_err(error, 'reading grass_in variable' )

error = nf90_close(ncid_in)
 call netcdf_err(error, 'closing file: '//trim(filename_grass) )

print*, 'grass_in max: ', maxval(grass_in)
print*, 'grass_in min: ', minval(grass_in)

!====================================
! forest

error = nf90_open(trim(filename_forest), nf90_nowrite, ncid_in)
  call netcdf_err(error, 'opening file: '//trim(filename_forest) )
  
error = nf90_inq_varid(ncid_in, 'Forest_fraction', varid)
 call netcdf_err(error, 'inquire Forest_fraction variable' )

error = nf90_get_var(ncid_in, varid, forest_in)
 call netcdf_err(error, 'reading forest_in variable' )

error = nf90_close(ncid_in)
 call netcdf_err(error, 'closing file: '//trim(filename_forest) )

print*, 'forest_in max: ', maxval(forest_in)
print*, 'forest_in min: ', minval(forest_in)

!====================================
! shrubland

error = nf90_open(trim(filename_shrub), nf90_nowrite, ncid_in)
  call netcdf_err(error, 'opening file: '//trim(filename_shrub) )
  
error = nf90_inq_varid(ncid_in, 'Shrubland_fraction', varid)
 call netcdf_err(error, 'inquire Shrubland_fraction variable' )

error = nf90_get_var(ncid_in, varid, shrub_in)
 call netcdf_err(error, 'reading shrub_in variable' )

error = nf90_close(ncid_in)
 call netcdf_err(error, 'closing file: '//trim(filename_shrub) )

print*, 'shrub_in max: ', maxval(shrub_in)
print*, 'shrub_in min: ', minval(shrub_in)

!====================================
! wetland

error = nf90_open(trim(filename_wetland), nf90_nowrite, ncid_in)
  call netcdf_err(error, 'opening file: '//trim(filename_wetland) )
  
error = nf90_inq_varid(ncid_in, 'Wetland_fraction', varid)
 call netcdf_err(error, 'inquire Wetland_fraction variable' )

error = nf90_get_var(ncid_in, varid, wetland_in)
 call netcdf_err(error, 'reading wetland_in variable' )

error = nf90_close(ncid_in)
 call netcdf_err(error, 'closing file: '//trim(filename_wetland) )

print*, 'wetland_in max: ', maxval(wetland_in)
print*, 'wetland_in min: ', minval(wetland_in)

!====================================
! water

error = nf90_open(trim(filename_water), nf90_nowrite, ncid_in)
  call netcdf_err(error, 'opening file: '//trim(filename_water) )
  
error = nf90_inq_varid(ncid_in, 'Water_fraction', varid)
 call netcdf_err(error, 'inquire Water_fraction variable' )

error = nf90_get_var(ncid_in, varid, water_in)
 call netcdf_err(error, 'reading water_in variable' )

error = nf90_close(ncid_in)
 call netcdf_err(error, 'closing file: '//trim(filename_water) )

print*, 'water_in max: ', maxval(water_in)
print*, 'water_in min: ', minval(water_in)

! calculate the vegetation_cover as (crop+grass+forest+shrub+wetland)/(1-water)

do i = 1, idim
do j = 1, jdim

  data_real = real (crop_in(i,j)) + real  (grass_in(i,j)) + real(forest_in(i,j)) + &
              real(shrub_in(i,j)) + real(wetland_in(i,j))
  
  if(water_in(i,j) < 100) then 
    data_real = 100.0*data_real / real(100 - water_in(i,j))   ! normalize by water fraction
    data_real = min(data_real, 100.0)                         ! cap at 100% if there are precision issues
  else
    data_real = 0.0                                           ! 100% water fraction so set to zero
  end if

  if(data_real > 0.0 .and. data_real <1.0) data_real = 1.0  ! make any vegetation at least 1%

  vegetation_cover(i,j,1) = nint(data_real)

end do
end do

! swap the latitude on the output grid

vegetation_cover(:,:,1) = vegetation_cover(:,21600:1:-1,1)

deallocate(crop_in)
deallocate(grass_in)
deallocate(forest_in)
deallocate(shrub_in)
deallocate(wetland_in)
deallocate(water_in)

allocate(vegetation_cover_save(idim,jdim,1))
allocate(vegetation_type(idim,jdim,1))
allocate(non_bare(idim,jdim))

!====================================
! read vegetation_type data file

error = nf90_open(trim(vegtype_in), nf90_nowrite, ncid_in)
  call netcdf_err(error, 'opening file: '//trim(vegtype_in) )
  
error = nf90_inq_varid(ncid_in, 'vegetation_type', varid)
 call netcdf_err(error, 'inquire vegetation_type variable' )

error = nf90_get_var(ncid_in, varid, vegetation_type)
 call netcdf_err(error, 'reading vegetation_type variable' )

error = nf90_close(ncid_in)
 call netcdf_err(error, 'closing file: '//trim(vegtype_in) )

non_bare = vegetation_type(:,:,1) /= 17 .and. vegetation_type(:,:,1) /= 16 .and. &
           vegetation_type(:,:,1) /= 15 .and. vegetation_type(:,:,1) /= 13

!====================================
! print inconsistencies

print*, "vegetation_cover = 0, vegetation_type  = 17   :", count(vegetation_cover == 0 .and. vegetation_type == 17)
print*, "vegetation_cover > 0, vegetation_type  = 17   :", count(vegetation_cover  > 0 .and. vegetation_type == 17)
print*, "vegetation_cover = 0, vegetation_type  = 16   :", count(vegetation_cover == 0 .and. vegetation_type == 16)
print*, "vegetation_cover > 0, vegetation_type  = 16   :", count(vegetation_cover  > 0 .and. vegetation_type == 16)
print*, "vegetation_cover = 0, vegetation_type  = 15   :", count(vegetation_cover == 0 .and. vegetation_type == 15)
print*, "vegetation_cover > 0, vegetation_type  = 15   :", count(vegetation_cover  > 0 .and. vegetation_type == 15)
print*, "vegetation_cover = 0, vegetation_type  = 13   :", count(vegetation_cover == 0 .and. vegetation_type == 13)
print*, "vegetation_cover > 0, vegetation_type  = 13   :", count(vegetation_cover  > 0 .and. vegetation_type == 13)
print*, "vegetation_cover = 0, vegetation_type /= 13,15,16,17:", count(vegetation_cover(:,:,1) == 0 .and. non_bare)
print*, "vegetation_cover > 0, vegetation_type /= 13,15,16,17:", count(vegetation_cover(:,:,1)  > 0 .and. non_bare)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! first check 10x10
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  vegetation_cover_save = vegetation_cover

  num_missing = count(vegetation_cover(:,:,1) == 0 .and. non_bare)
  print *, "Num missing before fill: ", num_missing
  if(num_missing > 0) then
    do i = 1,idim
    do j = 1,jdim
      if(vegetation_cover(i,j,1) == 0 .and. non_bare(i,j) ) then
       imax = min(i+5,idim)
       imin = max(i-5,1)
       jmax = min(j+5,jdim)
       jmin = max(j-5,1)
       allocate(cover_mini(imin:imax,jmin:jmax))
       cover_mini = vegetation_cover_save(imin:imax,jmin:jmax,1)
       count_non_bare = count(non_bare(imin:imax,jmin:jmax).and.cover_mini>0)
       if(count_non_bare > 0) then
         sum_non_bare = sum(cover_mini,mask=(non_bare(imin:imax,jmin:jmax).and.cover_mini>0))
         vegetation_cover(i,j,1) = sum_non_bare/count_non_bare
!       if(sum_non_bare > 0) then
!print*, non_bare(imin:imax,jmin:jmax)
!print*, vegetation_cover_save(imin:imax,jmin:jmax,1)
!print*, cover_mini(imin:imax,jmin:jmax)
!print*, count_non_bare
!print*, sum_non_bare
!print*, vegetation_cover(i,j,1)
!stop
!       end if
       end if
       deallocate(cover_mini)
      end if
    end do
    end do
  end if

!====================================
! print updated inconsistencies

print*
print*, "After 10x10 fill"
print*, "vegetation_cover = 0, vegetation_type /= 13,15,16,17:", count(vegetation_cover(:,:,1) == 0 .and. non_bare)
print*, "vegetation_cover > 0, vegetation_type /= 13,15,16,17:", count(vegetation_cover(:,:,1)  > 0 .and. non_bare)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! first check 100x100
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  vegetation_cover_save = vegetation_cover

  num_missing = count(vegetation_cover(:,:,1) == 0 .and. non_bare)
  print *, "Num missing before fill: ", num_missing
  if(num_missing > 0) then
    do i = 1,idim
    do j = 1,jdim
      if(vegetation_cover(i,j,1) == 0 .and. non_bare(i,j) ) then
       imax = min(i+50,idim)
       imin = max(i-50,1)
       jmax = min(j+50,jdim)
       jmin = max(j-50,1)
       allocate(cover_mini(imin:imax,jmin:jmax))
       cover_mini = vegetation_cover_save(imin:imax,jmin:jmax,1)
       count_non_bare = count(non_bare(imin:imax,jmin:jmax).and.cover_mini>0)
       if(count_non_bare > 0) then
         sum_non_bare = sum(cover_mini,mask=(non_bare(imin:imax,jmin:jmax).and.cover_mini>0))
         vegetation_cover(i,j,1) = sum_non_bare/count_non_bare
       end if
       deallocate(cover_mini)
      end if
    end do
    end do
  end if

!====================================
! print updated inconsistencies

print*
print*, "After 100x100 fill"
print*, "vegetation_cover = 0, vegetation_type /= 13,15,16,17:", count(vegetation_cover(:,:,1) == 0 .and. non_bare)
print*, "vegetation_cover > 0, vegetation_type /= 13,15,16,17:", count(vegetation_cover(:,:,1)  > 0 .and. non_bare)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! first check 200x200
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  vegetation_cover_save = vegetation_cover

  num_missing = count(vegetation_cover(:,:,1) == 0 .and. non_bare)
  print *, "Num missing before fill: ", num_missing
  if(num_missing > 0) then
    do i = 1,idim
    do j = 1,jdim
      if(vegetation_cover(i,j,1) == 0 .and. non_bare(i,j) ) then
       imax = min(i+100,idim)
       imin = max(i-100,1)
       jmax = min(j+100,jdim)
       jmin = max(j-100,1)
       allocate(cover_mini(imin:imax,jmin:jmax))
       cover_mini = vegetation_cover_save(imin:imax,jmin:jmax,1)
       count_non_bare = count(non_bare(imin:imax,jmin:jmax).and.cover_mini>0)
       if(count_non_bare > 0) then
         sum_non_bare = sum(cover_mini,mask=(non_bare(imin:imax,jmin:jmax).and.cover_mini>0))
         vegetation_cover(i,j,1) = sum_non_bare/count_non_bare
       end if
       deallocate(cover_mini)
      end if
    end do
    end do
  end if

!====================================
! print updated inconsistencies

print*
print*, "After 200x200 fill"
print*, "vegetation_cover = 0, vegetation_type /= 13,15,16,17:", count(vegetation_cover(:,:,1) == 0 .and. non_bare)
print*, "vegetation_cover > 0, vegetation_type /= 13,15,16,17:", count(vegetation_cover(:,:,1)  > 0 .and. non_bare)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! next check 400x400
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  vegetation_cover_save = vegetation_cover

  num_missing = count(vegetation_cover(:,:,1) == 0 .and. non_bare)
  print *, "Num missing before fill: ", num_missing
  if(num_missing > 0) then
    do i = 1,idim
    do j = 1,jdim
      if(vegetation_cover(i,j,1) == 0 .and. non_bare(i,j) ) then
       imax = min(i+200,idim)
       imin = max(i-200,1)
       jmax = min(j+200,jdim)
       jmin = max(j-200,1)
       allocate(cover_mini(imin:imax,jmin:jmax))
       cover_mini = vegetation_cover_save(imin:imax,jmin:jmax,1)
       count_non_bare = count(non_bare(imin:imax,jmin:jmax).and.cover_mini>0)
       if(count_non_bare > 0) then
         sum_non_bare = sum(cover_mini,mask=(non_bare(imin:imax,jmin:jmax).and.cover_mini>0))
         vegetation_cover(i,j,1) = sum_non_bare/count_non_bare
       end if
       deallocate(cover_mini)
      end if
    end do
    end do
  end if

!====================================
! print updated inconsistencies

print*
print*, "After 400x400 fill"
print*, "vegetation_cover = 0, vegetation_type /= 13,15,16,17:", count(vegetation_cover(:,:,1) == 0 .and. non_bare)
print*, "vegetation_cover > 0, vegetation_type /= 13,15,16,17:", count(vegetation_cover(:,:,1)  > 0 .and. non_bare)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! next just fill with grass type
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  where(vegetation_cover(:,:,1) == 0 .and. non_bare) 
    vegetation_cover(:,:,1) = 50
  end where

!====================================
! print updated inconsistencies

print*
print*, "After 50% fill"
print*, "vegetation_cover = 0, vegetation_type /= 13,15,16,17:", count(vegetation_cover(:,:,1) == 0 .and. non_bare)
print*, "vegetation_cover > 0, vegetation_type /= 13,15,16,17:", count(vegetation_cover(:,:,1)  > 0 .and. non_bare)

!====================================
! open and fill output file

error = nf90_open(trim(filename_out),nf90_write, ncid_out)
  call netcdf_err(error, 'opening file: '//trim(filename_out) )

error = nf90_inq_varid(ncid_out, 'vegetation_cover', varid)
 call netcdf_err(error, 'inquire vegetation_cover variable' )

error = nf90_put_var(ncid_out, varid, vegetation_cover)
 call netcdf_err(error, 'writing vegetation_cover variable' )
    
error = nf90_close(ncid_out)
 call netcdf_err(error, 'closing file: '//trim(filename_out) )

end program
    
subroutine netcdf_err( err, string )
    
!--------------------------------------------------------------
! if a netcdf call returns an error, print out a message
! and stop processing.
!--------------------------------------------------------------
    
use netcdf

implicit none
    
integer, intent(in) :: err
character(len=*), intent(in) :: string
character(len=80) :: errmsg
    
if( err == nf90_noerr )return
errmsg = nf90_strerror(err)
print*,''
print*,'fatal error: ', trim(string), ': ', trim(errmsg)
stop

return

end subroutine netcdf_err
 
