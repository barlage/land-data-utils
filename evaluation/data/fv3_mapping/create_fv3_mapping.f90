program create_fv3_mapping

  use netcdf
  implicit none

! namelist inputs

  integer            :: atm_resolution 
  integer            :: ocn_resolution
  integer            :: number_of_tiles
  character*128      :: fv3_file_path 
  character*128      :: source_path
  character*128      :: source_lat_name
  character*128      :: source_lon_name
  character*128      :: source_dim1_name
  character*128      :: source_dim2_name
  character*10       :: source_name
  character*128      :: mapping_file_path 

  logical            :: include_source_latlon      = .false.    ! put the source latlon in the mapping file
  logical            :: include_fv3_orography      = .false.    ! put the source orography in the mapping file
  real, parameter    :: perturb_value              = 1.d-4      ! a small adjustment to lat/lon to find [radians]

  integer            :: grid_size                               ! = 2*atm_resolution + 1
  integer            :: quick_search_pad = 1                    ! do a first search +/- this many grids around the current
  integer            :: fv3_search_order(7) = (/3,1,2,5,6,4,0/) ! do the general search in this order, logical choice is most land first
                                                                ! 7th element is to trick the regional option

  real   , allocatable, dimension(:,:,:) :: fv3_lat             ! grid file latitude, contains edges and centers
  real   , allocatable, dimension(:,:,:) :: fv3_lon             ! grid file longitude, contains edges and centers
  real   , allocatable, dimension(:,:,:) :: fv3_lat_center      ! grid file latitude of grid center
  real   , allocatable, dimension(:,:,:) :: fv3_lon_center      ! grid file longitude of grid center
  real   , allocatable, dimension(:,:,:) :: fv3_elevation       ! orog file grid elevation

  integer, allocatable, dimension(:,:)   :: lookup_tile         ! fv3 tile of source grid
  integer, allocatable, dimension(:,:)   :: lookup_i            ! fv3 i of source grid
  integer, allocatable, dimension(:,:)   :: lookup_j            ! fv3 j of source grid
  real   , allocatable, dimension(:,:)   :: source_lat          ! source grid latitude
  real   , allocatable, dimension(:,:)   :: source_lon          ! source grid longitude, needs to be 0 - 360
  real   , allocatable, dimension(:,:)   :: source_data         ! use if lat/lon flipping needed
  
  real, dimension(4) :: lat_vertex, lon_vertex
  
  integer         :: itile, tile_index, tile_i_index, tile_j_index
  integer         :: tile_index_beg, tile_index_end
  integer         :: source_i_index, source_j_index
  integer         :: source_i_size, source_j_size
  integer         :: tile_save, tile_i_save, tile_j_save
  integer         :: pad_i_min, pad_i_max, pad_j_min, pad_j_max
  logical         :: found, inside_a_polygon
  real            :: lat2find, lon2find
  integer         :: ncid, varid, ierr
  integer         :: dim_id, dim_id_i, dim_id_j
  integer         :: dim_id_i_fv3, dim_id_j_fv3, dim_id_t_fv3
  character*128   :: filename
  logical         :: file_exists 
  character*9     :: string_tile
  character*20    :: string_atm
  character*20    :: string_ocn
  real, parameter :: deg2rad = 3.1415926535897931/180.0

  namelist/fv3_mapping_nml/ atm_resolution, ocn_resolution, number_of_tiles, fv3_file_path,  &
                            source_path, source_lat_name, source_lon_name,                   &
                            source_dim1_name, source_dim2_name,                              &
                            source_name, mapping_file_path

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Setup inputs and read namelist
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! read namelist
 
  inquire(file='fv3_mapping.nml', exist=file_exists)

  if (.not. file_exists) then
    print *, 'namelist file does not exist, exiting'
    stop
  endif

  open(10, action='read', file='fv3_mapping.nml')
   read(10, fv3_mapping_nml)
  close(10)

  write(*,*) "Namelist atm_resolution:   ",atm_resolution
  write(*,*) "Namelist ocn_resolution:   ",ocn_resolution
  write(*,*) "Namelist number_of_tiles:  ",number_of_tiles
  write(*,*) "Namelist fv3_file_path:    ",fv3_file_path
  write(*,*) "Namelist source_path:      ",source_path
  write(*,*) "Namelist source_lat_name:  ",source_lat_name
  write(*,*) "Namelist source_lon_name:  ",source_lon_name
  write(*,*) "Namelist source_dim1_name: ",source_dim1_name
  write(*,*) "Namelist source_dim2_name: ",source_dim2_name
  write(*,*) "Namelist source_name:      ",source_name
  write(*,*) "Namelist mapping_file_path:",mapping_file_path

  grid_size= atm_resolution*2 + 1

  if(number_of_tiles == 1) fv3_search_order = 1

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Read source lat/lon and get source dimensions
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
  ierr = nf90_open(source_path, NF90_NOWRITE, ncid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"open source_path")

  ierr = nf90_inq_dimid(ncid, source_dim1_name, dim_id)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inq_dimid source_dim1_name")

  ierr = nf90_inquire_dimension(ncid, dim_id, len = source_i_size)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inquire_dimension source_dim1_name")
   
  ierr = nf90_inq_dimid(ncid, source_dim2_name, dim_id)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inq_dimid source_dim2_name")

  ierr = nf90_inquire_dimension(ncid, dim_id, len = source_j_size)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inquire_dimension source_dim2_name")
   
  allocate(source_lat (source_i_size,source_j_size))
  allocate(source_lon (source_i_size,source_j_size))

  ierr = nf90_inq_varid(ncid, source_lat_name, varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inq varid source_latname")

  ierr = nf90_get_var(ncid, varid , source_lat)
    if (ierr /= nf90_noerr) call handle_error(ierr,"get_var source_lat")
  
  ierr = nf90_inq_varid(ncid, source_lon_name, varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inq varid source_lonname")

  ierr = nf90_get_var(ncid, varid , source_lon)
    if (ierr /= nf90_noerr) call handle_error(ierr,"get_var source_lon")
  
  ierr = nf90_close(ncid)


  allocate(fv3_lat       (grid_size,grid_size,number_of_tiles))
  allocate(fv3_lon       (grid_size,grid_size,number_of_tiles))
  allocate(fv3_lon_center(atm_resolution,atm_resolution,number_of_tiles))
  allocate(fv3_lat_center(atm_resolution,atm_resolution,number_of_tiles))

  if(include_fv3_orography) allocate(fv3_elevation(atm_resolution,atm_resolution,number_of_tiles))

  allocate(lookup_tile(source_i_size,source_j_size))  
  allocate(lookup_i   (source_i_size,source_j_size))
  allocate(lookup_j   (source_i_size,source_j_size))

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Read FV3 tile information
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  write(string_atm,*)  atm_resolution
  string_atm = "C"//trim(adjustl(string_atm))
  write(string_ocn,*)  ocn_resolution
  string_ocn = ".mx"//trim(adjustl(string_ocn))

  if(number_of_tiles == 6) then
    tile_index_beg = 1
    tile_index_end = 6
  elseif(number_of_tiles == 1) then
    tile_index_beg = 7
    tile_index_end = 7
  else
    print *, "Unsupported number of tiles: ",number_of_tiles
    stop
  end if

  do itile = tile_index_beg, tile_index_end
 
    tile_index = itile - tile_index_beg + 1   ! deal with regional where tile number is 7, but dimension is 1

    write(string_tile,'(a5,i1,a3)')  ".tile", itile, ".nc"

    filename = trim(fv3_file_path)//trim(string_atm)//"/"//trim(string_atm)//"_grid"//string_tile
    write(*,*) 'Reading tile grid file' , filename

    ierr = nf90_open(filename, NF90_NOWRITE, ncid)
      if (ierr /= nf90_noerr) call handle_error(ierr,"open grid file")

    ierr = nf90_inq_varid(ncid, "x", varid)
      if (ierr /= nf90_noerr) call handle_error(ierr,"inq_varid x")
    ierr = nf90_get_var(ncid, varid , fv3_lon(:,:,tile_index))
      if (ierr /= nf90_noerr) call handle_error(ierr,"get_var fv3_lon")
  
    ierr = nf90_inq_varid(ncid, "y", varid)
      if (ierr /= nf90_noerr) call handle_error(ierr,"inq_varid y")
    ierr = nf90_get_var(ncid, varid , fv3_lat(:,:,tile_index))
      if (ierr /= nf90_noerr) call handle_error(ierr,"get_var fv3_lat")

    ierr = nf90_close(ncid)

    ! get orography

    if(include_fv3_orography) then

      filename = trim(fv3_file_path)//"/"//trim(adjustl(string_atm))//".mx"//trim(adjustl(string_ocn))//"_oro_data"//string_tile
      write(*,*) 'Reading orography file' , filename

      ierr = nf90_open(filename, NF90_NOWRITE, ncid)
       if (ierr /= nf90_noerr) call handle_error(ierr,"open orography file")

      ierr = nf90_inq_varid(ncid, "orog_filt", varid)
       if (ierr /= nf90_noerr) call handle_error(ierr,"inq_varid orog_filt")
      ierr = nf90_get_var(ncid, varid , fv3_elevation(:,:,itile))
       if (ierr /= nf90_noerr) call handle_error(ierr,"get_var fv3_elevation")

      ierr = nf90_close(ncid)

    end if
  
! get center of grid cell for output

    do tile_i_index = 1, atm_resolution 
      do tile_j_index = 1, atm_resolution 
        fv3_lon_center(tile_i_index,tile_j_index,tile_index) = fv3_lon(tile_i_index*2,tile_j_index*2,tile_index)
        fv3_lat_center(tile_i_index,tile_j_index,tile_index) = fv3_lat(tile_i_index*2,tile_j_index*2,tile_index)
      end do 
    end do

  end do
  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! loop through the source points
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  lookup_tile = -9999
  lookup_i = -9999
  lookup_j = -9999
  
  tile_save = fv3_search_order(1)
  tile_i_save = 1
  tile_j_save = 1
  
  source_i_loop : do source_i_index = 1, source_i_size
  source_j_loop : do source_j_index = 1, source_j_size
  
    found = .false.
    lat2find = source_lat(source_i_index, source_j_index)
    lon2find = source_lon(source_i_index, source_j_index)
    
    if(lat2find < -90. .or. lat2find > 90.  .or. &
       lon2find <   0. .or. lon2find > 360.) cycle source_j_loop     ! skip if out of projection
   
    ! input is in degrees. 
    lat2find = deg2rad * lat2find
    lon2find = deg2rad * lon2find
    
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! check around the last found tile/i/j
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    pad_i_min = max(tile_i_save-quick_search_pad,1)
    pad_i_max = min(tile_i_save+quick_search_pad,atm_resolution)
    pad_j_min = max(tile_j_save-quick_search_pad,1)
    pad_j_max = min(tile_j_save+quick_search_pad,atm_resolution)
    
    tile_index = tile_save
    
    do tile_i_index = pad_i_min, pad_i_max
    do tile_j_index = pad_j_min, pad_j_max
      
      lat_vertex(1) = fv3_lat((tile_i_index - 1) * 2 + 1,(tile_j_index - 1) * 2 + 1,tile_index)  ! LL
      lat_vertex(2) = fv3_lat((tile_i_index - 1) * 2 + 3,(tile_j_index - 1) * 2 + 1,tile_index)  ! LR
      lat_vertex(3) = fv3_lat((tile_i_index - 1) * 2 + 3,(tile_j_index - 1) * 2 + 3,tile_index)  ! UR
      lat_vertex(4) = fv3_lat((tile_i_index - 1) * 2 + 1,(tile_j_index - 1) * 2 + 3,tile_index)  ! UL
      
      lon_vertex(1) = fv3_lon((tile_i_index - 1) * 2 + 1,(tile_j_index - 1) * 2 + 1,tile_index)  ! LL
      lon_vertex(2) = fv3_lon((tile_i_index - 1) * 2 + 3,(tile_j_index - 1) * 2 + 1,tile_index)  ! LR
      lon_vertex(3) = fv3_lon((tile_i_index - 1) * 2 + 3,(tile_j_index - 1) * 2 + 3,tile_index)  ! UR
      lon_vertex(4) = fv3_lon((tile_i_index - 1) * 2 + 1,(tile_j_index - 1) * 2 + 3,tile_index)  ! UL
        
      lat_vertex = lat_vertex * deg2rad
      lon_vertex = lon_vertex * deg2rad
      
      found = inside_a_polygon(lon2find, lat2find, 4, lon_vertex, lat_vertex)
        
      if(found) then
        lookup_tile(source_i_index,source_j_index) = tile_index
        lookup_i   (source_i_index,source_j_index) = tile_i_index
        lookup_j   (source_i_index,source_j_index) = tile_j_index
        tile_save = tile_index
        tile_i_save = tile_i_index
        tile_j_save = tile_j_index
        cycle source_j_loop
      end if
        
    end do
    end do
      
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! not found so do a general check
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    do itile = tile_index_beg, tile_index_end

      tile_index = fv3_search_order(itile)
      
      do tile_i_index = 1, atm_resolution
      do tile_j_index = 1, atm_resolution
      
        lat_vertex(1) = fv3_lat((tile_i_index - 1) * 2 + 1,(tile_j_index - 1) * 2 + 1,tile_index)  ! LL
        lat_vertex(2) = fv3_lat((tile_i_index - 1) * 2 + 3,(tile_j_index - 1) * 2 + 1,tile_index)  ! LR
        lat_vertex(3) = fv3_lat((tile_i_index - 1) * 2 + 3,(tile_j_index - 1) * 2 + 3,tile_index)  ! UR
        lat_vertex(4) = fv3_lat((tile_i_index - 1) * 2 + 1,(tile_j_index - 1) * 2 + 3,tile_index)  ! UL
      
        lon_vertex(1) = fv3_lon((tile_i_index - 1) * 2 + 1,(tile_j_index - 1) * 2 + 1,tile_index)  ! LL
        lon_vertex(2) = fv3_lon((tile_i_index - 1) * 2 + 3,(tile_j_index - 1) * 2 + 1,tile_index)  ! LR
        lon_vertex(3) = fv3_lon((tile_i_index - 1) * 2 + 3,(tile_j_index - 1) * 2 + 3,tile_index)  ! UR
        lon_vertex(4) = fv3_lon((tile_i_index - 1) * 2 + 1,(tile_j_index - 1) * 2 + 3,tile_index)  ! UL
        
        lat_vertex = lat_vertex * deg2rad
        lon_vertex = lon_vertex * deg2rad
      
        found = inside_a_polygon(lon2find, lat2find, 4, lon_vertex, lat_vertex)
        
        if(found) then
          lookup_tile(source_i_index,source_j_index) = tile_index
          lookup_i   (source_i_index,source_j_index) = tile_i_index
          lookup_j   (source_i_index,source_j_index) = tile_j_index
          tile_save = tile_index
          tile_i_save = tile_i_index
          tile_j_save = tile_j_index
          cycle source_j_loop
        end if
        
      end do
      end do
      
    end do

  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ! not found so do a general check with a perturbation
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    print*, "Did not find, add perturbation"
  
    lat2find = lat2find + perturb_value
    lon2find = lon2find + perturb_value
  
    do itile = tile_index_beg, tile_index_end

      tile_index = fv3_search_order(itile)

      do tile_i_index = 1, atm_resolution
      do tile_j_index = 1, atm_resolution

        lat_vertex(1) = fv3_lat((tile_i_index - 1) * 2 + 1,(tile_j_index - 1) * 2 + 1,tile_index)  ! LL
        lat_vertex(2) = fv3_lat((tile_i_index - 1) * 2 + 3,(tile_j_index - 1) * 2 + 1,tile_index)  ! LR
        lat_vertex(3) = fv3_lat((tile_i_index - 1) * 2 + 3,(tile_j_index - 1) * 2 + 3,tile_index)  ! UR
        lat_vertex(4) = fv3_lat((tile_i_index - 1) * 2 + 1,(tile_j_index - 1) * 2 + 3,tile_index)  ! UL

        lon_vertex(1) = fv3_lon((tile_i_index - 1) * 2 + 1,(tile_j_index - 1) * 2 + 1,tile_index)  ! LL
        lon_vertex(2) = fv3_lon((tile_i_index - 1) * 2 + 3,(tile_j_index - 1) * 2 + 1,tile_index)  ! LR
        lon_vertex(3) = fv3_lon((tile_i_index - 1) * 2 + 3,(tile_j_index - 1) * 2 + 3,tile_index)  ! UR
        lon_vertex(4) = fv3_lon((tile_i_index - 1) * 2 + 1,(tile_j_index - 1) * 2 + 3,tile_index)  ! UL

        lat_vertex = lat_vertex * deg2rad
        lon_vertex = lon_vertex * deg2rad

        found = inside_a_polygon(lon2find, lat2find, 4, lon_vertex, lat_vertex)
  
        if(found) then
          lookup_tile(source_i_index,source_j_index) = tile_index
          lookup_i   (source_i_index,source_j_index) = tile_i_index
          lookup_j   (source_i_index,source_j_index) = tile_j_index
          tile_save = tile_index
          tile_i_save = tile_i_index
          tile_j_save = tile_j_index
          cycle source_j_loop
        end if

      end do
      end do

    end do
   
    if(.not.found) then
      if(number_of_tiles == 6) then
        print*, "This is global grid"
        print*, "Did not find in cube sphere:", source_lat(source_i_index, source_j_index), ",", source_lon(source_i_index, source_j_index)
        stop
      elseif(number_of_tiles == 1) then
        print*, "This is regional grid so all source grids need not be located somewhere"
        print*, "Did not find in regional cube sphere:", source_lat(source_i_index, source_j_index), ",", source_lon(source_i_index, source_j_index)
      end if
    end if

  end do source_j_loop
     if(mod(source_i_index,10) == 0) print *, "finished loop: ",source_i_index, " of ", source_i_size
  end do source_i_loop


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! create the output filename and netcdf file (overwrite old)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
  filename= trim(mapping_file_path)//trim(source_name)//"_to_FV3_mapping."//trim(string_atm)//trim(string_ocn)//".nc"
  write(6,*) 'writing indexes to ', trim(filename)

  ierr = nf90_create(filename, NF90_NETCDF4, ncid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"nf90_create mapping file")

! Define dimensions in the file.

  ierr = nf90_def_dim(ncid, "idim"   , source_i_size , dim_id_i)
    if (ierr /= nf90_noerr) call handle_error(ierr,"def_dim idim")
  ierr = nf90_def_dim(ncid, "jdim"   , source_j_size , dim_id_j)
    if (ierr /= nf90_noerr) call handle_error(ierr,"def_dim jdim")

! fv3 lat/lon
  ierr = nf90_def_dim(ncid, "idim_fv3"   , atm_resolution , dim_id_i_fv3)
    if (ierr /= nf90_noerr) call handle_error(ierr,"def_dim idim_fv3")
  ierr = nf90_def_dim(ncid, "jdim_fv3"   , atm_resolution , dim_id_j_fv3)
    if (ierr /= nf90_noerr) call handle_error(ierr,"def_dim jdim_fv3")
  ierr = nf90_def_dim(ncid, "tdim_fv3"   , number_of_tiles , dim_id_t_fv3)
    if (ierr /= nf90_noerr) call handle_error(ierr,"def_dim tdim_fv3")
  
! Define variables in the file.

  ierr = nf90_def_var(ncid, "tile", NF90_INT, (/dim_id_j, dim_id_i/), varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"def_var tile")

    ierr = nf90_put_att(ncid, varid, "long_name", "fv3 tile location")
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att tile long_name")
    ierr = nf90_put_att(ncid, varid, "missing_value", -9999)
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att tile missing_value")

  ierr = nf90_def_var(ncid, "tile_i", NF90_INT, (/dim_id_j, dim_id_i/), varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"def_var tile_i")

    ierr = nf90_put_att(ncid, varid, "long_name", "fv3 i location in tile")
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att tile_i long_name")
    ierr = nf90_put_att(ncid, varid, "missing_value", -9999)
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att tile_i missing_value")

  ierr = nf90_def_var(ncid, "tile_j", NF90_INT, (/dim_id_j, dim_id_i/), varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"def_var tile_j")

    ierr = nf90_put_att(ncid, varid, "long_name", "fv3 j location in tile")
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att tile_j long_name")
    ierr = nf90_put_att(ncid, varid, "missing_value", -9999)
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att tile_j missing_value")

  ierr = nf90_def_var(ncid, "lon_fv3", NF90_FLOAT, (/dim_id_j_fv3, dim_id_i_fv3,dim_id_t_fv3/), varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"def_var lon_fv3")

    ierr = nf90_put_att(ncid, varid, "long_name", "longitude fv3 grid")
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att lon_fv3 long_name")
    ierr = nf90_put_att(ncid, varid, "missing_value", -9999)
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att lon_fv3 missing_value")
    ierr = nf90_put_att(ncid, varid, "units", "degrees_east")
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att lon_fv3 units")

  ierr = nf90_def_var(ncid, "lat_fv3", NF90_FLOAT, (/dim_id_j_fv3, dim_id_i_fv3,dim_id_t_fv3/), varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"def_var lat_fv3")

    ierr = nf90_put_att(ncid, varid, "long_name", "latitude fv3 grid")
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att lat_fv3 long_name")
    ierr = nf90_put_att(ncid, varid, "missing_value", -9999)
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att lat_fv3 missing_value")
    ierr = nf90_put_att(ncid, varid, "units", "degrees_north")
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att lon_fv3 units")

 if(include_fv3_orography) then

  ierr = nf90_def_var(ncid, "oro_fv3", NF90_FLOAT, (/dim_id_j_fv3, dim_id_i_fv3,dim_id_t_fv3/), varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"def_var oro_fv3")

    ierr = nf90_put_att(ncid, varid, "long_name", "orography fv3 grid")
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att oro_fv3 long_name")
    ierr = nf90_put_att(ncid, varid, "missing_value", -9999)
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att oro_fv3 missing_value")

 end if

 if(include_source_latlon) then

  ierr = nf90_def_var(ncid, "source_lat", NF90_FLOAT, (/dim_id_j, dim_id_i/), varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"def_var source_lat")

    ierr = nf90_put_att(ncid, varid, "long_name", "ims latitude")
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att source_lat long_name")
    ierr = nf90_put_att(ncid, varid, "missing_value", -9999.)
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att source_lat missing_value")
    ierr = nf90_put_att(ncid, varid, "units", "degrees_north")
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att source_lat units")

  ierr = nf90_def_var(ncid, "source_lon", NF90_FLOAT, (/dim_id_j, dim_id_i/), varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"def_var source_lon")

    ierr = nf90_put_att(ncid, varid, "long_name", "ims longitude")
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att source_lon long_name")
    ierr = nf90_put_att(ncid, varid, "missing_value", -9999.)
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att source_lon missing_value")
    ierr = nf90_put_att(ncid, varid, "units", "degrees_east")
      if (ierr /= nf90_noerr) call handle_error(ierr,"put_att source_lon units")
  
 end if

  ierr = nf90_enddef(ncid)

  ierr = nf90_inq_varid(ncid, "tile", varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inq_varid tile")
  ierr = nf90_put_var(ncid, varid , lookup_tile)
    if (ierr /= nf90_noerr) call handle_error(ierr,"put_var lookup_tile")

  ierr = nf90_inq_varid(ncid, "tile_i", varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inq_varid tile_i")
  ierr = nf90_put_var(ncid, varid , lookup_i)
    if (ierr /= nf90_noerr) call handle_error(ierr,"put_var lookup_i")

  ierr = nf90_inq_varid(ncid, "tile_j", varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inq_varid tile_j")
  ierr = nf90_put_var(ncid, varid , lookup_j)
    if (ierr /= nf90_noerr) call handle_error(ierr,"put_var tile_j")

  ierr = nf90_inq_varid(ncid, "lon_fv3", varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inq_varid lon_fv3")
  ierr = nf90_put_var(ncid, varid , fv3_lon_center)
    if (ierr /= nf90_noerr) call handle_error(ierr,"put_var fv3_lon_center")

  ierr = nf90_inq_varid(ncid, "lat_fv3", varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inq_varid lat_fv3")
  ierr = nf90_put_var(ncid, varid , fv3_lat_center)
    if (ierr /= nf90_noerr) call handle_error(ierr,"put_var fv3_lat_center")

 if(include_source_latlon) then

  ierr = nf90_inq_varid(ncid, "oro_fv3", varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inq_varid oro_fv3")
  ierr = nf90_put_var(ncid, varid , fv3_elevation)
    if (ierr /= nf90_noerr) call handle_error(ierr,"put_var fv3_elevation")

 end if

 if(include_source_latlon) then

  ierr = nf90_inq_varid(ncid, "source_lat", varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inq_varid source_lat")
  ierr = nf90_put_var(ncid, varid , source_lat)
    if (ierr /= nf90_noerr) call handle_error(ierr,"put_var source_lat")

  ierr = nf90_inq_varid(ncid, "source_lon", varid)
    if (ierr /= nf90_noerr) call handle_error(ierr,"inq_varid source_lon")
  ierr = nf90_put_var(ncid, varid , source_lon)
    if (ierr /= nf90_noerr) call handle_error(ierr,"put_var source_lon")
  
 end if

 ierr = nf90_close(ncid)

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

  subroutine handle_error(ierr,message)
    use netcdf
    integer, intent(in) :: ierr
    character*128, intent(in) :: message
 
    if(ierr /= nf90_noerr) then
      print *, "Error in: ", message
      print *, trim(nf90_strerror(ierr))
      stop "Stopped"
    end if
  end subroutine handle_error
