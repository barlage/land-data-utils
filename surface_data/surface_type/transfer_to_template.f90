program transfer_to_template

use netcdf

implicit none

character*256 :: filename_in  = '/scratch2/NCEPDEV/land/data/input_data/vegetation_type/raw/v3/SNPP-N20_VIIRS_AST_EMC20types_2012-2019Climatology_30arcsec_v3.nc'
character*256 :: filename_out = '/scratch2/NCEPDEV/land/data/input_data/vegetation_type/vegetation_type.viirs.v3.igbp.30s.nc'

integer*1, allocatable :: surface_type_out (:,:,:)
integer*2, allocatable :: surface_type_in    (:,:)

integer :: error, ncid, dimid, varid(2), modis_i, modis_j, location
integer :: nlocations, idim_modis_length, jdim_modis_length
integer :: land_check
integer*1, parameter ::  nodata_byte = -9

allocate(surface_type_in(43200,21600))
allocate(surface_type_out(43200,21600,1))

!====================================
! read new data file

error = nf90_open(trim(filename_in), nf90_nowrite, ncid)
  call netcdf_err(error, 'opening file: '//trim(filename_in) )
  
error = nf90_inq_varid(ncid, 'surface_type', varid(1))
 call netcdf_err(error, 'inquire surface_type variable' )

error = nf90_get_var(ncid, varid(1), surface_type_in)
 call netcdf_err(error, 'reading surface_type variable' )

error = nf90_close(ncid)
 call netcdf_err(error, 'closing file: '//trim(filename_in) )

print*, 'in max: ', maxval(surface_type_in)
print*, 'in min: ', minval(surface_type_in)

surface_type_out(:,:,1) = surface_type_in(:,21600:1:-1)
!where(surface_type_out == 17) surface_type_out = nodata_byte

!====================================
! write to template file

error = nf90_open(trim(filename_out),nf90_write, ncid)
  call netcdf_err(error, 'opening file: '//trim(filename_out) )

error = nf90_inq_varid(ncid, 'vegetation_type', varid(1))
 call netcdf_err(error, 'inquire vegetation_type variable' )

error = nf90_put_var(ncid, varid(1), surface_type_out)
 call netcdf_err(error, 'writing vegetation_type variable' )
    
error = nf90_close(ncid)
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
 
