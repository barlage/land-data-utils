program create_land_fraction_30s

use netcdf

implicit none

character*256 :: filename_in  = '/scratch4/NCEPDEV/land/data/fix/original/land_mask/GlobalWaterFraction2020_7p5arcsec_v2.nc'
character*256 :: filename_out = '/scratch4/NCEPDEV/land/data/fix/original/land_mask/land_fraction.nesdis.30s.uncompressed.nc'
integer  , parameter ::  jdim = 21600
integer  , parameter ::  idim = 43200

integer*1, allocatable :: land_fraction_out (:,:,:)
integer*1, allocatable :: water_fraction_in (:,:)
real*8   , allocatable :: latitude_center   (:)
real*8   , allocatable :: longitude_center  (:)
real*8   , allocatable :: latitude_corner   (:)
real*8   , allocatable :: longitude_corner  (:)

integer :: error
integer :: ncid_in,ncid_out,ncdim_jdim,ncdim_jdim_p1,ncdim_idim,ncdim_idim_p1,ncdim_time
integer :: varid
integer :: i, j
integer :: land_check
integer*1, parameter ::  nodata_byte = -99
real    :: data_real(4,4)

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

error = nf90_def_var(ncid_out, "land_fraction", NF90_BYTE, (/ncdim_idim,ncdim_jdim,ncdim_time/), varid)
 call netcdf_err(error, "defining variable: land_fraction")
  error = nf90_put_att(ncid_out, varid, "long_name", "2020 Global land fraction product, 30 arcsecond aggregated from 7.5 arcsecond")
   call netcdf_err(error, "defining attribute: long_name variable: land_fraction")
  error = nf90_put_att(ncid_out, varid, "units", "fraction")
   call netcdf_err(error, "defining attribute: units variable: land_fraction")
  error = nf90_put_att(ncid_out, varid, "scale_factor", 0.01)
   call netcdf_err(error, "defining attribute: scale_factor variable: land_fraction")

error = nf90_put_att(ncid_out, NF90_GLOBAL, "description", "derived from 2020 Global water surface fraction (%) product, 7.5 arcsecond, lat/lon original")
 call netcdf_err(error, "defining attribute: description: global")
error = nf90_put_att(ncid_out, NF90_GLOBAL, "data_source", "MOD44W C6 (2011-2015) Updated with 7 circa-2000 10m-30m land cover/water products")
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

allocate(water_fraction_in(idim*4,jdim*4  ))
allocate(land_fraction_out(idim  ,jdim  ,1))

!====================================
! read new data file

error = nf90_open(trim(filename_in), nf90_nowrite, ncid_in)
  call netcdf_err(error, 'opening file: '//trim(filename_in) )
  
error = nf90_inq_varid(ncid_in, 'water_fraction', varid)
 call netcdf_err(error, 'inquire water_fraction variable' )

error = nf90_get_var(ncid_in, varid, water_fraction_in)
 call netcdf_err(error, 'reading water_fraction variable' )

error = nf90_close(ncid_in)
 call netcdf_err(error, 'closing file: '//trim(filename_in) )

print*, 'in max: ', maxval(water_fraction_in)
print*, 'in min: ', minval(water_fraction_in)

! average the 16 sub-grids to the output grid

do i = 1, idim
do j = 1, jdim

  data_real = water_fraction_in(i*4-3:i*4,j*4-3:j*4)
  data_real = 100.0 - data_real  ! convert to land fraction
  data_real = data_real / 16.0
  land_fraction_out(i,j,1) = nint(sum(data_real))

end do
end do

! swap the latitude on the output grid

land_fraction_out(:,:,1) = land_fraction_out(:,21600:1:-1,1)

!====================================
! open and fill output file

error = nf90_open(trim(filename_out),nf90_write, ncid_out)
  call netcdf_err(error, 'opening file: '//trim(filename_out) )

error = nf90_inq_varid(ncid_out, 'land_fraction', varid)
 call netcdf_err(error, 'inquire land_fraction variable' )

error = nf90_put_var(ncid_out, varid, land_fraction_out)
 call netcdf_err(error, 'writing land_fraction variable' )
    
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
 
