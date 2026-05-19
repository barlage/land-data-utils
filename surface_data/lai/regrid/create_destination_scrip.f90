program create_destination_scrip

use netcdf

implicit none

character*256 :: filename_out = 'viirs_lai_destination_SCRIP.nc'

integer  , parameter ::  jdim = 21600
integer  , parameter ::  idim = 43200

real*8   , allocatable ::  latitude_center (:)
real*8   , allocatable :: longitude_center (:)
real*8   , allocatable ::  latitude_corner (:,:)
real*8   , allocatable :: longitude_corner (:,:)
integer  , allocatable ::            imask (:,:)
real*8 :: dlat, dlon

integer :: error
integer :: ncid_in,ncid_out,ncdim_ij,ncdim_rank,ncdim_corners
integer :: varid
integer :: i, j, ijdim

ijdim = idim*jdim

allocate( latitude_center(  ijdim))
allocate( latitude_corner(4,ijdim))
allocate(longitude_center(  ijdim))
allocate(longitude_corner(4,ijdim))

dlon = 360.d0/idim
dlat = 180.d0/jdim

do j = 1, jdim
do i = 1, idim

  ij = (j-1)*idim + i
  longitude_center(ij)   = -180.d0 + dlon/2.d0 + (i-1)*dlon
  longitude_corner(ij,1) = longitude_center(ij) - dlon/2.d0
  longitude_corner(ij,2) = longitude_center(ij) + dlon/2.d0
  longitude_corner(ij,3) = longitude_center(ij) + dlon/2.d0
  longitude_corner(ij,4) = longitude_center(ij) - dlon/2.d0

  latitude_center(ij)   = -90.d0 + dlat/2.d0 + (j-1)*dlat
  latitude_corner(ij,1) = latitude_center(ij) - dlat/2.d0
  latitude_corner(ij,2) = latitude_center(ij) - dlat/2.d0
  latitude_corner(ij,3) = latitude_center(ij) + dlat/2.d0
  latitude_corner(ij,4) = latitude_center(ij) + dlat/2.d0

end do
end do

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

error = nf90_def_dim(ncid_out,"grid_size" ,ijdim ,ncdim_ij) 
  call netcdf_err(error, 'creating dimension: grid_size')
error = nf90_def_dim(ncid_out,"grid_corners" ,4 ,ncdim_corners) 
  call netcdf_err(error, 'creating dimension: grid_corners')
error = nf90_def_dim(ncid_out,"grid_rank" ,2 ,ncdim_rank) 
  call netcdf_err(error, 'creating dimension: grid_rank')

error = nf90_def_var(ncid_out,"grid_dims",NF90_INT,(/ncdim_rank/),varid)
  if(error /= nf90_noerr) stop "problem defining grid_dims"

error = nf90_def_var(ncid_out,"grid_center_lat",NF90_DOUBLE,(/ncdim_ij/),varid)
  if(error /= nf90_noerr) stop "problem defining grid_center_lat"
  error = nf90_put_att(ncid_out, varid, "units", "degrees")
  if(error /= nf90_noerr) stop "problem adding lat attibute"

error = nf90_def_var(ncid_out,"grid_center_lon",NF90_DOUBLE,(/ncdim_ij/),varid)
  if(error /= nf90_noerr) stop "problem defining grid_center_lon"
  error = nf90_put_att(ncid_out, varid, "units", "degrees")
  if(error /= nf90_noerr) stop "problem adding lon attibute"

error = nf90_def_var(ncid_out,"grid_imask",NF90_INT,(/ncdim_ij/),varid)
  if(error /= nf90_noerr) stop "problem defining grid_imask"

error = nf90_def_var(ncid_out,"grid_corner_lat",NF90_DOUBLE,(/ncdim_ij,ncdim_corners/),varid)
  if(error /= nf90_noerr) stop "problem defining grid_corner_lat"
  error = nf90_put_att(ncid_out, varid, "units", "degrees")
  if(error /= nf90_noerr) stop "problem adding grid_corner_lat attibute"

error = nf90_def_var(ncid_out,"grid_corner_lon",NF90_DOUBLE,(/ncdim_ij,ncdim_corners/),varid)
  if(error /= nf90_noerr) stop "problem defining grid_corner_lon"
  error = nf90_put_att(ncid_out, varid, "units", "degrees")
  if(error /= nf90_noerr) stop "problem adding grid_corner_lon attibute"

error = nf90_enddef(ncid_out) 
 call netcdf_err(error, "ending define mode")

error = nf90_inq_varid(ncid_out, 'grid_dims', varid)
 call netcdf_err(error, 'inquire variable: grid_dims' )
error = nf90_put_var(ncid_out, varid, (/idim,jdim/))
 call netcdf_err(error, 'writing variable: grid_dims' )
    
error = nf90_inq_varid(ncid_out, 'grid_center_lat', varid)
 call netcdf_err(error, 'inquire variable: grid_center_lat' )
error = nf90_put_var(ncid_out, varid, latitude_center)
 call netcdf_err(error, 'writing variable: grid_center_lat' )
    
error = nf90_inq_varid(ncid_out, 'grid_center_lon', varid)
 call netcdf_err(error, 'inquire variable: grid_center_lon' )
error = nf90_put_var(ncid_out, varid, longitude_center)
 call netcdf_err(error, 'writing variable: grid_center_lon' )
    
error = nf90_inq_varid(ncid_out, 'grid_imask', varid)
 call netcdf_err(error, 'inquire variable: grid_imask' )
error = nf90_put_var(ncid_out, varid, imask)
 call netcdf_err(error, 'writing variable: grid_imask' )
    
error = nf90_inq_varid(ncid_out, 'grid_corner_lat', varid)
 call netcdf_err(error, 'inquire variable: grid_corner_lat' )
error = nf90_put_var(ncid_out, varid, latitude_corner)
 call netcdf_err(error, 'writing variable: grid_corner_lat' )
    
error = nf90_inq_varid(ncid_out, 'grid_corner_lon', varid)
 call netcdf_err(error, 'inquire variable: grid_corner_lon' )
error = nf90_put_var(ncid_out, varid, longitude_corner)
 call netcdf_err(error, 'writing variable: grid_corner_lon' )
    

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
 
