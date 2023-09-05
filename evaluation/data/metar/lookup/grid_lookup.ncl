
begin

create_output_file = False   ; if True, will clobber existing file
create_C96_vector = True
create_C96_conus_vector = False
create_HR1_grid = False
create_P8_grid = False

outname = "/scratch2/NCEPDEV/land/data/evaluation/METAR_SYNOP/metar_allgrids_lookup.nc"
if(create_output_file) then
   system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")
else
  outfile = addfile(outname,"w")
end if

infile = addfile("/scratch2/NCEPDEV/land/data/evaluation/METAR_SYNOP/map_metar_master_reorder.nc", "r")

inlat = infile->metar_lat
inlon = infile->metar_lon

; C96 vector

if(create_C96_vector) then

  infile = addfile("/scratch2/NCEPDEV/land/Michael.Barlage/forcing/C96/vector/ufs-land_C96_static_fields_hr2.nc","r")
  latitude = infile->latitude
  longitude = infile->longitude
  vegetation_type = infile->vegetation_category
  soil_type = infile->soil_category
  elevation = infile->elevation

  C96_lookup = new(dimsizes(inlat),integer)
   C96_lookup!0 = "location"
   C96_lookup@description = "location (0-based) in C96 vector closest to observation"
  C96_vegetation_type = C96_lookup
   C96_vegetation_type@description = "vegetation type at C96 location"
  C96_soil_type = C96_lookup
   C96_soil_type@description = "soil type at C96 location"
  C96_latitude = new(dimsizes(inlat),float)
   C96_latitude!0 = "location"
   C96_latitude@units = "degrees_north"
   C96_latitude@description = "latitude at C96 location"
  C96_longitude = C96_latitude
   C96_longitude@units = "degrees_east"
   C96_longitude@description = "longitude at C96 location"
  C96_distance = C96_latitude
   C96_distance@units = "km"
   C96_distance@description = "distance from model grid center"
  C96_elevation = C96_latitude
   C96_elevation@units = "m"
   C96_elevation@description = "elevation at C96 location"

  do iloc = 0, dimsizes(inlat)-1

    max_dist = 9999999.0

    do icheck = 0, dimsizes(latitude)-1
  
      this_dist = gc_latlon(inlat(iloc),inlon(iloc),latitude(icheck),longitude(icheck),20,4)
    
      if(this_dist .lt. max_dist) then
        max_dist = this_dist
        C96_lookup   (iloc) = icheck
        C96_latitude (iloc) = (/ latitude(icheck) /)
        C96_longitude(iloc) = (/ longitude(icheck) /)
        C96_distance (iloc) = max_dist
        C96_vegetation_type(iloc) = (/ vegetation_type(icheck) /)
        C96_soil_type      (iloc) = (/ soil_type(icheck) /)
        C96_elevation      (iloc) = (/ elevation(icheck) /)
        print("iloc: "+iloc+" icheck: "+icheck+" max_dist: "+max_dist)
        print(inlat(iloc)+" "+inlon(iloc)+" "+latitude(icheck)+" "+longitude(icheck))
      end if

    end do
    
    print("iloc: "+iloc+" icheck: "+C96_lookup(iloc)+" max_dist: "+max_dist)
  
  end do

  delete(C96_distance@gclat)
  delete(C96_distance@gclon)

  outfile->C96_lookup          = C96_lookup
  outfile->C96_latitude        = C96_latitude
  outfile->C96_longitude       = C96_longitude
  outfile->C96_distance        = C96_distance
  outfile->C96_vegetation_type = C96_vegetation_type
  outfile->C96_soil_type       = C96_soil_type
  outfile->C96_elevation       = C96_elevation
  
  delete(latitude)
  delete(longitude)
  delete(vegetation_type)
  delete(soil_type)
  delete(elevation)
  
end if ; create_C96_vector

; C96 conus vector

if(create_C96_conus_vector) then

  infile = addfile("/scratch2/NCEPDEV/land/Michael.Barlage/forcing/C96/vector/ufs-land_C96_conus_static_fields_hr2.nc","r")
  latitude = infile->latitude
  longitude = infile->longitude
  vegetation_type = infile->vegetation_category
  soil_type = infile->soil_category
  elevation = infile->elevation

  C96_conus_lookup = new(dimsizes(inlat),integer)
   C96_conus_lookup!0 = "location"
   C96_conus_lookup@description = "location (0-based) in C96_conus vector closest to observation"
  C96_conus_vegetation_type = C96_conus_lookup
   C96_conus_vegetation_type@description = "vegetation type at C96_conus location"
  C96_conus_soil_type = C96_conus_lookup
   C96_conus_soil_type@description = "soil type at C96_conus location"
  C96_conus_latitude = new(dimsizes(inlat),float)
   C96_conus_latitude!0 = "location"
   C96_conus_latitude@units = "degrees_north"
   C96_conus_latitude@description = "latitude at C96_conus location"
  C96_conus_longitude = C96_conus_latitude
   C96_conus_longitude@units = "degrees_east"
   C96_conus_longitude@description = "longitude at C96_conus location"
  C96_conus_distance = C96_conus_latitude
   C96_conus_distance@units = "km"
   C96_conus_distance@description = "distance from model grid center"
  C96_conus_elevation = C96_conus_latitude
   C96_conus_elevation@units = "m"
   C96_conus_elevation@description = "elevation at C96_conus location"

  do iloc = 0, dimsizes(inlat)-1

    max_dist = 9999999.0

    do icheck = 0, dimsizes(latitude)-1
  
      this_dist = gc_latlon(inlat(iloc),inlon(iloc),latitude(icheck),longitude(icheck),20,4)
    
      if(this_dist .lt. max_dist) then
        max_dist = this_dist
        C96_conus_lookup   (iloc) = icheck
        C96_conus_latitude (iloc) = (/ latitude(icheck) /)
        C96_conus_longitude(iloc) = (/ longitude(icheck) /)
        C96_conus_distance (iloc) = max_dist
        C96_conus_vegetation_type(iloc) = (/ vegetation_type(icheck) /)
        C96_conus_soil_type      (iloc) = (/ soil_type(icheck) /)
        C96_conus_elevation      (iloc) = (/ elevation(icheck) /)
        print("iloc: "+iloc+" icheck: "+icheck+" max_dist: "+max_dist)
        print(inlat(iloc)+" "+inlon(iloc)+" "+latitude(icheck)+" "+longitude(icheck))
      end if

    end do
    
    print("iloc: "+iloc+" icheck: "+C96_conus_lookup(iloc)+" max_dist: "+max_dist)
  
  end do

  delete(C96_conus_distance@gclat)
  delete(C96_conus_distance@gclon)

  outfile->C96_conus_lookup          = C96_conus_lookup
  outfile->C96_conus_latitude        = C96_conus_latitude
  outfile->C96_conus_longitude       = C96_conus_longitude
  outfile->C96_conus_distance        = C96_conus_distance
  outfile->C96_conus_vegetation_type = C96_conus_vegetation_type
  outfile->C96_conus_soil_type       = C96_conus_soil_type
  outfile->C96_conus_elevation       = C96_conus_elevation
  
  delete(latitude)
  delete(longitude)
  delete(vegetation_type)
  delete(soil_type)
  delete(elevation)
  
end if ; create_C96_conus_vector

; HR1 grid

if(create_HR1_grid) then

  infile = addfile("/scratch2/NCEPDEV/land/data/evaluation/domains/hr/hr1_vegsoil.nc","r")
  latitude = infile->lat
  longitude = infile->lon
  longitude_shift = where(longitude.ge.180,longitude-360,longitude)
  vegetation_type = infile->vegetation_type
  soil_type = infile->soil_type
  elevation = infile->elevation

  HR1_lookup_i = new(dimsizes(inlat),integer)
   HR1_lookup_i!0 = "location"
   HR1_lookup_i@description = "i location (0-based) in HR1 output grid closest to observation"
  HR1_lookup_j = HR1_lookup_i
   HR1_lookup_j@description = "j location (0-based) in HR1 output grid closest to observation"
  HR1_vegetation_type = HR1_lookup_i
   HR1_vegetation_type@description = "vegetation type at HR1 output grid location"
  HR1_soil_type = HR1_lookup_i
   HR1_soil_type@description = "soil type at HR1 output grid location"

  HR1_latitude = new(dimsizes(inlat),float)
   HR1_latitude!0 = "location"
   HR1_latitude@description = "latitude at HR1 output grid location"
   HR1_latitude@units = "degrees_north"
  HR1_longitude = HR1_latitude
   HR1_longitude@description = "longitude at HR1 output grid location"
   HR1_longitude@units = "degrees_east"
  HR1_distance = HR1_latitude
   HR1_distance@description = "distance from model grid center"
   HR1_distance@units = "km"
  HR1_elevation = HR1_latitude
   HR1_elevation@description = "elevation at HR1 output grid location"
   HR1_elevation@units = "m"

  
  nearest_lat_j = ind_nearest_coord(inlat,latitude,0)
  nearest_lon_i = ind_nearest_coord(inlon,longitude_shift,0)

  nearest_lat_j_min = nearest_lat_j - 1
  nearest_lon_i_min = nearest_lon_i - 1
  nearest_lat_j_max = nearest_lat_j + 1
  nearest_lon_i_max = nearest_lon_i + 1
  
  nearest_lat_j_min = where(nearest_lat_j_min.ge.0,nearest_lat_j_min,0)
  nearest_lon_i_min = where(nearest_lon_i_min.ge.0,nearest_lon_i_min,0)
  nearest_lat_j_max = where(nearest_lat_j_max.lt.dimsizes(latitude),nearest_lat_j_max,dimsizes(latitude)-1)
  nearest_lon_i_max = where(nearest_lon_i_max.lt.dimsizes(longitude),nearest_lon_i_max,dimsizes(longitude)-1)
  
  do iloc = 0, dimsizes(inlat)-1

    max_dist = 9999999.0

    do icheck = nearest_lon_i_min(iloc), nearest_lon_i_max(iloc)
    do jcheck = nearest_lat_j_min(iloc), nearest_lat_j_max(iloc)
  
      this_dist = gc_latlon(inlat(iloc),inlon(iloc),latitude(jcheck),longitude(icheck),20,4)
    
      if(this_dist .lt. max_dist) then
        max_dist = this_dist
        HR1_lookup_i (iloc) = icheck
        HR1_lookup_j (iloc) = jcheck
        HR1_latitude (iloc) = (/ latitude(jcheck) /)
        HR1_longitude(iloc) = (/ longitude(icheck) /)
        HR1_distance (iloc) = max_dist
        HR1_vegetation_type(iloc) = (/ vegetation_type(jcheck,icheck) /)
        HR1_soil_type      (iloc) = (/ soil_type(jcheck,icheck) /)
        HR1_elevation      (iloc) = (/ elevation(jcheck,icheck) /)
;        print("iloc: "+iloc+" icheck: "+icheck+" jcheck: "+jcheck+" max_dist: "+max_dist)
      end if

    end do
    end do
    
    print("iloc: "+iloc+" icheck: "+HR1_lookup_i(iloc)+" jcheck: "+HR1_lookup_j(iloc)+" max_dist: "+max_dist)

  end do

  delete(HR1_distance@gclat)
  delete(HR1_distance@gclon)

  outfile->HR1_lookup_i        = HR1_lookup_i
  outfile->HR1_lookup_j        = HR1_lookup_j
  outfile->HR1_latitude        = HR1_latitude
  outfile->HR1_longitude       = HR1_longitude
  outfile->HR1_distance        = HR1_distance
  outfile->HR1_vegetation_type = HR1_vegetation_type
  outfile->HR1_soil_type       = HR1_soil_type
  outfile->HR1_elevation       = HR1_elevation
  
  delete(latitude)
  delete(longitude)
  delete(longitude_shift)
  delete(vegetation_type)
  delete(soil_type)
  delete(elevation)
  
end if ; create_HR1_grid

; P8 grid

if(create_P8_grid) then

  infile = addfile("/scratch2/NCEPDEV/land/data/evaluation/domains/prototype/prototype8_vegsoil.nc","r")
  latitude = infile->lat
  longitude = infile->lon
  longitude_shift = where(longitude.ge.180,longitude-360,longitude)
  vegetation_type = infile->vegetation_type
  soil_type = infile->soil_type

  P8_lookup_i = new(dimsizes(inlat),integer)
   P8_lookup_i!0 = "location"
   P8_lookup_i@description = "i location (0-based) in P8 output grid closest to observation"
  P8_lookup_j = P8_lookup_i
   P8_lookup_j@description = "j location (0-based) in P8 output grid closest to observation"
  P8_vegetation_type = P8_lookup_i
   P8_vegetation_type@description = "vegetation type at P8 output grid location"
  P8_soil_type = P8_lookup_i
   P8_soil_type@description = "soil type at P8 output grid location"

  P8_latitude = new(dimsizes(inlat),float)
   P8_latitude!0 = "location"
   P8_latitude@description = "latitude at P8 output grid location"
   P8_latitude@units = "degrees_north"
  P8_longitude = P8_latitude
   P8_longitude@description = "longitude at P8 output grid location"
   P8_longitude@units = "degrees_east"
  P8_distance = P8_latitude
   P8_distance@description = "distance from model grid center"
   P8_distance@units = "km"
  
  nearest_lat_j = ind_nearest_coord(inlat,latitude,0)
  nearest_lon_i = ind_nearest_coord(inlon,longitude_shift,0)

  nearest_lat_j_min = nearest_lat_j - 1
  nearest_lon_i_min = nearest_lon_i - 1
  nearest_lat_j_max = nearest_lat_j + 1
  nearest_lon_i_max = nearest_lon_i + 1
  
  nearest_lat_j_min = where(nearest_lat_j_min.ge.0,nearest_lat_j_min,0)
  nearest_lon_i_min = where(nearest_lon_i_min.ge.0,nearest_lon_i_min,0)
  nearest_lat_j_max = where(nearest_lat_j_max.lt.dimsizes(latitude),nearest_lat_j_max,dimsizes(latitude)-1)
  nearest_lon_i_max = where(nearest_lon_i_max.lt.dimsizes(longitude),nearest_lon_i_max,dimsizes(longitude)-1)
  
  do iloc = 0, dimsizes(inlat)-1

    max_dist = 9999999.0

    do icheck = nearest_lon_i_min(iloc), nearest_lon_i_max(iloc)
    do jcheck = nearest_lat_j_min(iloc), nearest_lat_j_max(iloc)
  
      this_dist = gc_latlon(inlat(iloc),inlon(iloc),latitude(jcheck),longitude(icheck),20,4)
    
      if(this_dist .lt. max_dist) then
        max_dist = this_dist
        P8_lookup_i (iloc) = icheck
        P8_lookup_j (iloc) = jcheck
        P8_latitude (iloc) = (/ latitude(jcheck) /)
        P8_longitude(iloc) = (/ longitude(icheck) /)
        P8_distance (iloc) = max_dist
        P8_vegetation_type(iloc) = (/ vegetation_type(jcheck,icheck) /)
        P8_soil_type      (iloc) = (/ soil_type(jcheck,icheck) /)
;        print("iloc: "+iloc+" icheck: "+icheck+" jcheck: "+jcheck+" max_dist: "+max_dist)
      end if

    end do
    end do
    
    print("iloc: "+iloc+" icheck: "+P8_lookup_i(iloc)+" jcheck: "+P8_lookup_j(iloc)+" max_dist: "+max_dist)

  end do

  delete(P8_distance@gclat)
  delete(P8_distance@gclon)

  outfile->P8_lookup_i        = P8_lookup_i
  outfile->P8_lookup_j        = P8_lookup_j
  outfile->P8_latitude        = P8_latitude
  outfile->P8_longitude       = P8_longitude
  outfile->P8_distance        = P8_distance
  outfile->P8_vegetation_type = P8_vegetation_type
  outfile->P8_soil_type       = P8_soil_type
  
  delete(latitude)
  delete(longitude)
  delete(longitude_shift)
  delete(vegetation_type)
  delete(soil_type)
  
end if ; create_P8_grid

end


