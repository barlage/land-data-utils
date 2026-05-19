program create_source_scrip

use netcdf

implicit none

character*256 :: filename_out = 'viirs_lai_source_SCRIP.nc'

integer  , parameter ::  jdim = 21600
integer  , parameter ::  idim = 43200

real*8   , allocatable ::  latitude_center (:)
real*8   , allocatable :: longitude_center (:)
real*8   , allocatable ::  latitude_corner (:)
real*8   , allocatable :: longitude_corner (:)

integer :: error
integer :: ncid_in,ncid_out,ncdim_jdim,ncdim_jdim_p1,ncdim_idim,ncdim_idim_p1
integer :: varid
integer :: i, j


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

  grid_size = dimsizes(lat2d)
  print(grid_size)
  grid_corners = 4
  grid_rank = 2

  grid_dims = new((/grid_rank/),integer)
  grid_dims!0 = "grid_rank"
  grid_dims   = (/ grid_size /)

  grid_center_lat = new((/grid_size(0),grid_size(1)/),double)
  grid_center_lat!0 = "grid_y"
  grid_center_lat!1 = "grid_x"
  grid_center_lat@units = "degrees"
  grid_center_lat = (/ lat2d /)

  grid_center_lon = grid_center_lat
  grid_center_lon = (/ lon2d /)

  grid_imask = new((/grid_size(0),grid_size(1)/),integer)
  grid_imask!0 = "grid_y"
  grid_imask!1 = "grid_x"
  grid_imask = 1
  
  grid_corner_lat = new((/grid_size(0),grid_size(1),grid_corners/),double)
  grid_corner_lat!0 = "grid_y"
  grid_corner_lat!1 = "grid_x"
  grid_corner_lat!2 = "grid_corners"
  grid_corner_lat@units = "degrees"
  grid_corner_lat = (/ corner_lats /)
  
  grid_corner_lon = grid_corner_lat
  grid_corner_lon = (/ corner_lons /)
  
  tile_scrip->grid_dims = grid_dims
  tile_scrip->grid_center_lat = grid_center_lat
  tile_scrip->grid_center_lon = grid_center_lon
  tile_scrip->grid_imask = grid_imask
  tile_scrip->grid_corner_lat = grid_corner_lat
  tile_scrip->grid_corner_lon = grid_corner_lon

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
 
