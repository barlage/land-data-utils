program data_regrid

  use netcdf
  implicit none

  double precision      :: sec_since
  
  character*100                :: source_path
  character*100                :: destination_path
  character*100                :: weights_path

  character*120                :: source_filename
  character*120                :: destination_filename
  character*120                :: weights_filename
  
  character*10                 :: cgrid

  character*50     :: suffix        ! smops NC fix suffix
  character*50     :: out_name      ! smops output file name
  character*19     :: current_date  ! current date
  character*19     :: since_date = "1970-01-01 00:00:00"
  character*4      :: yyyy
  character*2      :: mm, dd  

  integer, parameter           :: source_lats           = 720
  integer, parameter           :: source_lons           = 1440

! ---- Get values from smops bilinear_wts.nc  ---------------
! ---- destination_locs=n_b,  weight_locs=n_s ----------------

  integer, parameter           :: destination_locs      = 1410
  integer, parameter           :: weight_locs           = 5640

  integer :: latloc, lonloc, iwt
  integer :: i, j, itotal, io
  integer :: offset_ss

  real   , dimension(source_lons,source_lats) :: source_input
  real   , dimension(source_lons,source_lats) :: error_input
  integer, dimension(weight_locs)             :: source_lookup, destination_lookup
  real*8 , dimension(weight_locs)             :: weights
  real   , dimension(destination_locs)        :: soilMoisture = 0.0
  real   , dimension(destination_locs)        :: uncertainty = 0.0
  real   , dimension(destination_locs)        :: soilMoistureWT = 0.0
  real   , dimension(destination_locs)        :: uncertaintyWT = 0.0

  real   , dimension(destination_locs)        :: xcb    ! destination lon
  real   , dimension(destination_locs)        :: ycb    ! destination lat

  integer :: ncid, dimid, varid, status, ierr   ! netcdf identifiers
  integer :: dim_id_i, dim_id_j,dim_id_t        ! netcdf dimension identifiers

  logical :: file_exists
  real*4  fillVal;
  fillVal = -9999.0

  namelist/regrid_smops_nml/cgrid, source_path, weights_path, destination_path

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! read namelist
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

 inquire(file='regrid_smops.nml', exist=file_exists)

 if (.not. file_exists) then
        print *, 'namelistfile does not exist, exiting'
        stop 10
 endif

open (action='read', file='regrid_smops.nml', iostat=ierr, newunit=io)
read (nml=regrid_smops_nml, iostat=ierr, unit=io)
close (io)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  offset_ss=0
  open(20, file='date_input.txt', status='old')
  read(20,'(A4, A2, A2)') yyyy, mm, dd
  close(20)
  current_date=yyyy//'-'//mm//'-'//dd//' 00:00:00'
  call calc_sec_since(since_date, current_date, offset_ss, sec_since)

  suffix=yyyy//mm//dd//'_extn.nc'
  out_name='smops_sm_'//yyyy//mm//dd//'_'//trim(cgrid)//'.nc'
  write(*,*) current_date
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Read input, weight, and output data path
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  source_filename=trim(source_path)//'NPR_SMOPS_CMAP_D'//trim(suffix)
  
  status = nf90_open(trim(source_filename), NF90_NOWRITE, ncid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_inq_varid(ncid, "Blended_SM", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_get_var(ncid, varid , source_input, start = (/1,1,1/), count = (/source_lons,source_lats,1/))
    if (status /= nf90_noerr) call handle_err(status)

   status = nf90_inq_varid(ncid, "Blended_SM_SD", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_get_var(ncid, varid , error_input, start = (/1,1,1/), count = (/source_lons,source_lats,1/))
    if (status /= nf90_noerr) call handle_err(status) 

  status = nf90_close(ncid)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Read weights file
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  weights_filename=trim(weights_path)//'SMOPS-'//trim(cgrid)//'_bilinear_wts.nc'
  
  status = nf90_open(trim(weights_filename), NF90_NOWRITE, ncid)
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_inq_varid(ncid, "col", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_get_var(ncid, varid , source_lookup)
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_inq_varid(ncid, "row", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_get_var(ncid, varid , destination_lookup)
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_inq_varid(ncid, "S", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_get_var(ncid, varid , weights)
    if (status /= nf90_noerr) call handle_err(status)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Read lattitude and longitude data
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   status = nf90_inq_varid(ncid, "yc_b", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_get_var(ncid, varid , ycb)
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_inq_varid(ncid, "xc_b", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_get_var(ncid, varid , xcb)
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_close(ncid)
  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Regrid the data
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  do iwt = 1, weight_locs

    latloc = source_lookup(iwt)/source_lons + 1
    lonloc = source_lookup(iwt) - (latloc-1)*source_lons
    
    if(source_input(lonloc,latloc) > 0.0 ) then
    soilMoisture(destination_lookup(iwt)) = soilMoisture(destination_lookup(iwt)) + weights(iwt) * source_input(lonloc,latloc)
    soilMoistureWT(destination_lookup(iwt)) = soilMoistureWT(destination_lookup(iwt)) + weights(iwt)
    end if

    if(error_input(lonloc,latloc) > 0.0 ) then
    uncertainty(destination_lookup(iwt)) = uncertainty(destination_lookup(iwt)) + weights(iwt) * error_input(lonloc,latloc)
    uncertaintyWT(destination_lookup(iwt)) = uncertaintyWT(destination_lookup(iwt)) + weights(iwt)
    end if

  end do
  
  do iwt = 1, destination_locs

!    convert unit into m3/m3
    if(soilMoistureWT(iwt) > 0.0 ) then
    soilMoisture(iwt) = 0.0001*soilMoisture(iwt)/soilMoistureWT(iwt)
    end if

    if(uncertaintyWT(iwt) > 0.0 ) then
    uncertainty(iwt) = 0.0001*uncertainty(iwt)/uncertaintyWT(iwt)
    if(uncertainty(iwt)>soilMoistureWT(iwt)) uncertainty(iwt) = -9999.0
    end if
  
  end do

  where(soilMoisture <= 0.0 .or. uncertainty <= 0.0) soilMoisture = -9999.0
  where(soilMoisture <= 0.0 .or. uncertainty <= 0.0) uncertainty = -9999.0

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Write the destination file
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  destination_filename=trim(destination_path)//trim(out_name)
  
  status = nf90_create(trim(destination_filename), NF90_CLOBBER, ncid)
    if (status /= nf90_noerr) call handle_err(status)

! Define dimensions in the file.

  status = nf90_def_dim(ncid, "location"   , destination_locs, dim_id_i)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_def_dim(ncid, "time"   , NF90_UNLIMITED , dim_id_t)
    if (status /= nf90_noerr) call handle_err(status)
  
! Define variables in the file.

  status = nf90_def_var(ncid, "time", NF90_DOUBLE, dim_id_t, varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_att(ncid, varid, "long_name", "time")
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_att(ncid, varid, "units", "seconds since "//since_date)
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_def_var(ncid, "lat", NF90_FLOAT, (/dim_id_i/), varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_att(ncid, varid, "long_name", "latitude")
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_att(ncid, varid, "units", "degrees_north")
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_def_var(ncid, "lon", NF90_FLOAT, (/dim_id_i/), varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_att(ncid, varid, "long_name", "longitude")
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_att(ncid, varid, "unit", "degrees_east")
    if (status /= nf90_noerr) call handle_err(status) 

  status = nf90_def_var(ncid, "soilMoisture", NF90_FLOAT, (/dim_id_i, dim_id_t/), varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_att(ncid, varid, "long_name", "surface soil moisture")
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_att(ncid, varid, "units", "m3 m-3")
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_att(ncid, varid, "_FillValue", fillVal)
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_def_var(ncid, "uncertainty", NF90_FLOAT, (/dim_id_i, dim_id_t/), varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_att(ncid, varid, "long_name", "soil moisture uncertainty")
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_att(ncid, varid, "units", "m3 m-3")
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_att(ncid, varid, "_FillValue", fillVal)
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_enddef(ncid)
    if (status /= nf90_noerr) call handle_err(status)

! Write variables in the file.
  
  status = nf90_inq_varid(ncid, "lat", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_var(ncid, varid , ycb, start = (/1/), count = (/destination_locs/))
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_inq_varid(ncid, "lon", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_var(ncid, varid , xcb, start = (/1/), count = (/destination_locs/))
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_inq_varid(ncid, "time", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_var(ncid, varid , sec_since )
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_inq_varid(ncid, "soilMoisture", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_var(ncid, varid , soilMoisture, start = (/1,1/), count = (/destination_locs,1/))
    if (status /= nf90_noerr) call handle_err(status)
 
  status = nf90_inq_varid(ncid, "uncertainty", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_var(ncid, varid , uncertainty, start = (/1,1/), count = (/destination_locs,1/))
    if (status /= nf90_noerr) call handle_err(status)

 status = nf90_close(ncid)

end program

  subroutine handle_err(status)
    use netcdf
    integer, intent ( in) :: status
 
    if(status /= nf90_noerr) then
      print *, trim(nf90_strerror(status))
      stop "Stopped"
    end if
  end subroutine handle_err

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Calculate time in seconds
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

subroutine calc_sec_since(since_date, current_date, offset_ss, sec_since)

! calculate number of seconds between since_date and current_date

double precision      :: sec_since
character*19 :: since_date, current_date  ! format: yyyy-mm-dd hh:nn:ss
integer      :: offset_ss
integer      :: since_yyyy, since_mm, since_dd, since_hh, since_nn, since_ss
integer      :: current_yyyy, current_mm, current_dd, current_hh, current_nn, current_ss
logical      :: leap_year = .false.
integer      :: iyyyy, imm
integer, dimension(12), parameter :: days_in_mm = (/31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 /)

  sec_since = 0

  read(since_date( 1: 4),  '(i4)') since_yyyy
  read(since_date( 6: 7),  '(i2)') since_mm
  read(since_date( 9:10),  '(i2)') since_dd
  read(since_date(12:13),  '(i2)') since_hh
  read(since_date(15:16),  '(i2)') since_nn
  read(since_date(18:19),  '(i2)') since_ss

  read(current_date( 1: 4),  '(i4)') current_yyyy
  read(current_date( 6: 7),  '(i2)') current_mm
  read(current_date( 9:10),  '(i2)') current_dd
  read(current_date(12:13),  '(i2)') current_hh
  read(current_date(15:16),  '(i2)') current_nn
  read(current_date(18:19),  '(i2)') current_ss

! not worrying about the complexity of non-recent leap years 

! calculate number of seconds in all years  
  do iyyyy = since_yyyy, current_yyyy
    if(mod(iyyyy,4) == 0) then
      sec_since = sec_since + 366*86400
    else
      sec_since = sec_since + 365*86400
    end if
  end do
  
! remove seconds from since_year 
  if(mod(since_yyyy,4) == 0) leap_year = .true.
  
  do imm = 1,since_mm-1
    sec_since = sec_since - days_in_mm(imm)*86400
  end do

  if(leap_year .and. since_mm > 2) sec_since = sec_since - 86400
  
  sec_since = sec_since - (since_dd - 1) * 86400
  
  sec_since = sec_since - (since_hh) * 3600

  sec_since = sec_since - (since_nn) * 60

  sec_since = sec_since - (since_ss)
  
! remove seconds in current_year 
  leap_year = .false.
  if(mod(current_yyyy,4) == 0) leap_year = .true.
  
  do imm = current_mm+1, 12
    sec_since = sec_since - days_in_mm(imm)*86400
  end do
  if(leap_year .and. current_mm < 3) sec_since = sec_since - 86400
  
  sec_since = sec_since - (days_in_mm(current_mm) - current_dd) * 86400
  
  sec_since = sec_since - (23 - current_hh) * 3600

  sec_since = sec_since - (59 - current_nn) * 60

  sec_since = sec_since - (60 - current_ss)
  
  sec_since = sec_since + offset_ss
  
end subroutine calc_sec_since
