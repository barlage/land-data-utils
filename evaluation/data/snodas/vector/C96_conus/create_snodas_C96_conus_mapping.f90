program create_snodas_C96_conus_mapping

  use netcdf
  implicit none
  
  character*100      :: dest_file = "/scratch2/NCEPDEV/land/data/evaluation/domains/C96_conus/ufs-land_C96_conus_corners.nc"
  integer, parameter :: dest_size = 1410
  real*8             :: dest_lat_max =  53.5
  real*8             :: dest_lat_min =  24.6
  real*8             :: dest_lon_max = 294.1
  real*8             :: dest_lon_min = 233.9
  real*8 , dimension(4,dest_size)  :: dest_lat, dest_lon

  character*100      :: sorc_file = "/scratch2/NCEPDEV/land/data/evaluation/SNODAS/orig/SNODAS_unmasked_20131001.nc"
  integer, parameter                 :: sorc_i_size = 8192
  integer, parameter                 :: sorc_j_size = 4096
  real*8 , dimension(sorc_j_size)    :: sorc_lat
  real*8 , dimension(sorc_i_size)    :: sorc_lon

  character*100      :: map_file = "/scratch2/NCEPDEV/land/data/evaluation/SNODAS/C96_conus/mapping/snodas_C96_conus_mapping.nc"
  integer, dimension(sorc_i_size,sorc_j_size) :: sorc_i
  
  logical            :: include_source_latlon = .true.
  logical            :: perturb_source_latlon = .false.  ! if lat/lon not found, then add a small value to nudge off boundary
  real, parameter    :: perturb_value         = 1.d-4    ! a small adjustment to lat/lon to find [radians]
  integer            :: quick_search_pad = 1

  integer :: dest_i_index, sorc_i_index, sorc_j_index, dest_i_save, pad_i_min, pad_i_max
  logical :: found, inside_a_polygon
  real    :: lat2find, lon2find
  integer :: ncid, dimid, varid, status   ! netcdf identifiers
  integer :: dim_id_i, dim_id_j           ! netcdf dimension identifiers
  character*100 :: filename
  real, parameter :: deg2rad = 3.1415926535897931/180.0

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Read source lat/lon
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
  filename = trim(sorc_file)

  status = nf90_open(filename, NF90_NOWRITE, ncid)
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_inq_varid(ncid, "lon", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_get_var(ncid, varid , sorc_lon)
    if (status /= nf90_noerr) call handle_err(status)
  
  where(sorc_lon < 0) sorc_lon = sorc_lon + 360.0
  
  status = nf90_inq_varid(ncid, "lat", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_get_var(ncid, varid , sorc_lat)
    if (status /= nf90_noerr) call handle_err(status)
  
  status = nf90_close(ncid)
    if (status /= nf90_noerr) call handle_err(status)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Read destination lat/lon
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  filename = trim(dest_file)

  status = nf90_open(filename, NF90_NOWRITE, ncid)
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_inq_varid(ncid, "longitude_corners", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_get_var(ncid, varid , dest_lon)
    if (status /= nf90_noerr) call handle_err(status)
  
  status = nf90_inq_varid(ncid, "latitude_corners", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_get_var(ncid, varid , dest_lat)
    if (status /= nf90_noerr) call handle_err(status)
  
  status = nf90_close(ncid)
    if (status /= nf90_noerr) call handle_err(status)
  
  dest_lat = dest_lat * deg2rad
  dest_lon = dest_lon * deg2rad

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! loop through the source points
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  sorc_i = -9999
  
  sorc_i_loop : do sorc_i_index = 1, sorc_i_size
  sorc_j_loop : do sorc_j_index = 1, sorc_j_size
  
    found = .false.
    lat2find = sorc_lat(sorc_j_index)
    lon2find = sorc_lon(sorc_i_index)

    if(lat2find < dest_lat_min .or. lat2find > dest_lat_max  .or. &
       lon2find < dest_lon_min .or. lon2find > dest_lon_max) cycle sorc_j_loop     ! skip if out of projection
    
    lat2find = deg2rad*lat2find
    lon2find = deg2rad*lon2find
    
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! check around the last found i
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    pad_i_min = max(dest_i_save-quick_search_pad,1)
    pad_i_max = min(dest_i_save+quick_search_pad,dest_size)
    
    do dest_i_index = pad_i_min, pad_i_max
      
      found = inside_a_polygon(lon2find, lat2find, 4, dest_lon(:,dest_i_index), dest_lat(:,dest_i_index))
        
      if(found) then
        sorc_i(sorc_i_index,sorc_j_index) = dest_i_index
        dest_i_save = dest_i_index
        cycle sorc_j_loop
      end if
        
    end do
      
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! not found so do a general check
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    print*, "Did not find, doing general search"
    
    do dest_i_index = 1, dest_size
 
      found = inside_a_polygon(lon2find, lat2find, 4, dest_lon(:,dest_i_index), dest_lat(:,dest_i_index))
        
      if(found) then
        sorc_i(sorc_i_index,sorc_j_index) = dest_i_index
        dest_i_save = dest_i_index
        cycle sorc_j_loop
      end if
      
    end do
    
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! not found so do a general check with a perturbation
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    if(perturb_source_latlon) then

      print*, "Did not find, add perturbation"
    
      lat2find = lat2find + perturb_value
      lon2find = lon2find + perturb_value
    
      do dest_i_index = 1, dest_size
      
        found = inside_a_polygon(lon2find, lat2find, 4, dest_lon(:,dest_i_index), dest_lat(:,dest_i_index))
        
        if(found) then
          sorc_i(sorc_i_index,sorc_j_index) = dest_i_index
          cycle sorc_j_loop
        end if
       
      end do
        
    end if
    
    if(.not.found) then
      print*, "Did not find in destination:", sorc_lat(sorc_j_index), ",", sorc_lon(sorc_i_index)
    end if

  end do sorc_j_loop
     if(mod(sorc_i_index,10) == 0) print *, "finished loop: ",sorc_i_index, " of ", sorc_i_size
  end do sorc_i_loop


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! create the output filename and netcdf file (overwrite old)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  status = nf90_create(trim(map_file), NF90_CLOBBER, ncid)
    if (status /= nf90_noerr) call handle_err(status)

! Define dimensions in the file.

  status = nf90_def_dim(ncid, "lon"   , sorc_i_size , dim_id_i)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_def_dim(ncid, "lat"   , sorc_j_size , dim_id_j)
    if (status /= nf90_noerr) call handle_err(status)
  
! Define variables in the file.

  status = nf90_def_var(ncid, "vector_location", NF90_INT, (/dim_id_i, dim_id_j/), varid)
    if (status /= nf90_noerr) call handle_err(status)

    status = nf90_put_att(ncid, varid, "long_name", "i location in C96_conus vector")
      if (status /= nf90_noerr) call handle_err(status)
    status = nf90_put_att(ncid, varid, "missing_value", -9999)
      if (status /= nf90_noerr) call handle_err(status)

 if(include_source_latlon) then

  status = nf90_def_var(ncid, "lat", NF90_FLOAT, (/dim_id_j/), varid)
    if (status /= nf90_noerr) call handle_err(status)

    status = nf90_put_att(ncid, varid, "long_name", "source latitude")
      if (status /= nf90_noerr) call handle_err(status)
    status = nf90_put_att(ncid, varid, "missing_value", -9999.)
      if (status /= nf90_noerr) call handle_err(status)
    status = nf90_put_att(ncid, varid, "units", "degrees_north")
      if (status /= nf90_noerr) call handle_err(status)

  status = nf90_def_var(ncid, "lon", NF90_FLOAT, (/dim_id_i/), varid)
    if (status /= nf90_noerr) call handle_err(status)

    status = nf90_put_att(ncid, varid, "long_name", "source longitude")
      if (status /= nf90_noerr) call handle_err(status)
    status = nf90_put_att(ncid, varid, "missing_value", -9999.)
      if (status /= nf90_noerr) call handle_err(status)
    status = nf90_put_att(ncid, varid, "units", "degrees_east")
      if (status /= nf90_noerr) call handle_err(status)
  
 end if

  status = nf90_enddef(ncid)

  status = nf90_inq_varid(ncid, "vector_location", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_var(ncid, varid , sorc_i)
    if (status /= nf90_noerr) call handle_err(status)

 if(include_source_latlon) then

  status = nf90_inq_varid(ncid, "lat", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_var(ncid, varid , sorc_lat)
    if (status /= nf90_noerr) call handle_err(status)

  status = nf90_inq_varid(ncid, "lon", varid)
    if (status /= nf90_noerr) call handle_err(status)
  status = nf90_put_var(ncid, varid , sorc_lon)
    if (status /= nf90_noerr) call handle_err(status)
  
 end if

 status = nf90_close(ncid)

end program

  subroutine latlon2xyz(siz,lon, lat, x, y, z)
  implicit none
  integer, intent(in) :: siz
  real, intent(in) :: lon(siz), lat(siz)
  real, intent(out) :: x(siz), y(siz), z(siz)
  
  integer n

  do n = 1, siz
    x(n) = cos(lat(n))*cos(lon(n))
    y(n) = cos(lat(n))*sin(lon(n))
    z(n) = sin(lat(n))
  enddo

  end subroutine latlon2xyz

  FUNCTION spherical_angle(v1, v2, v3)
    implicit none
    real, parameter :: EPSLN30 = 1.e-30
    real, parameter :: PI=3.1415926535897931
    real v1(3), v2(3), v3(3)
    real  spherical_angle
 
    real px, py, pz, qx, qy, qz, ddd;
  
    ! vector product between v1 and v2 
    px = v1(2)*v2(3) - v1(3)*v2(2)
    py = v1(3)*v2(1) - v1(1)*v2(3)
    pz = v1(1)*v2(2) - v1(2)*v2(1)
    ! vector product between v1 and v3 
    qx = v1(2)*v3(3) - v1(3)*v3(2);
    qy = v1(3)*v3(1) - v1(1)*v3(3);
    qz = v1(1)*v3(2) - v1(2)*v3(1);

    ddd = (px*px+py*py+pz*pz)*(qx*qx+qy*qy+qz*qz);
    if ( ddd <= 0.0 ) then
      spherical_angle = 0. 
    else 
      ddd = (px*qx+py*qy+pz*qz) / sqrt(ddd);
      if( abs(ddd-1) < EPSLN30 ) ddd = 1;
      if( abs(ddd+1) < EPSLN30 ) ddd = -1;
      if ( ddd>1. .or. ddd<-1. ) then
    !FIX to correctly handle co-linear points (angle near pi or 0) */
    if (ddd < 0.) then
      spherical_angle = PI
    else
      spherical_angle = 0.
    endif
      else
    spherical_angle = acos( ddd )
      endif
    endif  

    return

  END FUNCTION spherical_angle

  FUNCTION inside_a_polygon(lon1, lat1, npts, lon2, lat2)
    implicit none
    real, parameter :: EPSLN10 = 1.e-10
    real, parameter :: EPSLN8 = 1.e-8
    real, parameter :: PI=3.1415926535897931
    real, parameter :: RANGE_CHECK_CRITERIA=0.05
    real :: anglesum, angle, spherical_angle
    integer i, ip1
    real lon1, lat1
    integer npts
    real lon2(npts), lat2(npts)
    real x2(npts), y2(npts), z2(npts)
    real lon1_1d(1), lat1_1d(1)
    real x1(1), y1(1), z1(1)
    real pnt0(3),pnt1(3),pnt2(3)
    logical inside_a_polygon
    real max_x2,min_x2,max_y2,min_y2,max_z2,min_z2
    !first convert to cartesian grid */
    call latlon2xyz(npts,lon2, lat2, x2, y2, z2);
    lon1_1d(1) = lon1
    lat1_1d(1) = lat1
    call latlon2xyz(1,lon1_1d, lat1_1d, x1, y1, z1);
    inside_a_polygon = .false.
    max_x2 = maxval(x2)
    if( x1(1) > max_x2+RANGE_CHECK_CRITERIA ) return
    min_x2 = minval(x2)
    if( x1(1)+RANGE_CHECK_CRITERIA < min_x2 ) return
    max_y2 = maxval(y2)
    if( y1(1) > max_y2+RANGE_CHECK_CRITERIA ) return
    min_y2 = minval(y2)
    if( y1(1)+RANGE_CHECK_CRITERIA < min_y2 ) return
    max_z2 = maxval(z2)
    if( z1(1) > max_z2+RANGE_CHECK_CRITERIA ) return
    min_z2 = minval(z2)
    if( z1(1)+RANGE_CHECK_CRITERIA < min_z2 ) return

    pnt0(1) = x1(1)
    pnt0(2) = y1(1)
    pnt0(3) = z1(1)
    
    anglesum = 0;
    do i = 1, npts
       if(abs(x1(1)-x2(i)) < EPSLN10 .and. &
          abs(y1(1)-y2(i)) < EPSLN10 .and. &
          abs(z1(1)-z2(i)) < EPSLN10 ) then ! same as the corner point
      inside_a_polygon = .true.
      return
       endif
       ip1 = i+1
       if(ip1>npts) ip1 = 1
       pnt1(1) = x2(i)
       pnt1(2) = y2(i)
       pnt1(3) = z2(i)
       pnt2(1) = x2(ip1)
       pnt2(2) = y2(ip1)
       pnt2(3) = z2(ip1)

       angle = spherical_angle(pnt0, pnt2, pnt1);
!       anglesum = anglesum + spherical_angle(pnt0, pnt2, pnt1);
       anglesum = anglesum + angle
    enddo

    if(abs(anglesum-2*PI) < EPSLN8) then
       inside_a_polygon = .true.
    else
       inside_a_polygon = .false.
    endif

    return
    
  end FUNCTION inside_a_polygon

  subroutine handle_err(status)
    use netcdf
    integer, intent ( in) :: status
 
    if(status /= nf90_noerr) then
      print *, trim(nf90_strerror(status))
      stop "Stopped"
    end if
  end subroutine handle_err
