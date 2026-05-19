
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

idim = 40000
jdim = 20000
longitude_source = new(idim,double)
latitude_source  = new(jdim,double)
dlon = todouble(360)/idim
dlat = todouble(180)/jdim
print(dlon)
print(dlat)

do i = 0, idim-1
  longitude_source(i) = -180.0 + dlon/2.0 + i*dlon 
end do

do j = 0, jdim-1
  latitude_source(j) = 90.0 - dlat/2.0 - j*dlat
end do

print(longitude_source(0))
print(longitude_source(idim-1))
print(latitude_source(0))
print(latitude_source(jdim-1))

; Create source grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "VIIRS LAI grid"

  rectilinear_to_SCRIP("viirs_lai_source_SCRIP.nc",latitude_source,longitude_source,Opt)

idim = 43200
jdim = 21600
longitude_dest = new(idim,double)
latitude_dest  = new(jdim,double)
dlon = todouble(360)/idim
dlat = todouble(180)/jdim
print(dlon)
print(dlat)

do i = 0, idim-1
  longitude_dest(i) = -180.0 + dlon/2.0 + i*dlon 
end do

do j = 0, jdim-1
  latitude_dest(j) = 90.0 - dlat/2.0 - j*dlat
end do

print(longitude_dest(0))
print(longitude_dest(idim-1))
print(latitude_dest(0))
print(latitude_dest(jdim-1))

; Create dest grid
;----------------------------------------------------------------------
  Opt                = True
  Opt@ForceOverwrite = True
  Opt@PrintTimings   = True
  Opt@Title          = "VIIRS LAI grid"

  rectilinear_to_SCRIP("viirs_lai_dest_SCRIP.nc",latitude_dest,longitude_dest,Opt)

end

