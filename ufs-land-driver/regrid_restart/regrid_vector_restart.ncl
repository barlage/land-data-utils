; see /scratch2/NCEPDEV/land/Michael.Barlage/forcing/README for generating the weights files

load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

           source_restart = keyword_values("regrid_parameter_assignment",           "source_restart","string")
      destination_restart = keyword_values("regrid_parameter_assignment",      "destination_restart","string")
         weights_filename = keyword_values("regrid_parameter_assignment",         "weights_filename","string")
     weights_veg_filename = keyword_values("regrid_parameter_assignment",     "weights_veg_filename","string")
    weights_bare_filename = keyword_values("regrid_parameter_assignment",    "weights_bare_filename","string")
    weights_snow_filename = keyword_values("regrid_parameter_assignment",    "weights_snow_filename","string")
weights_veg_bare_filename = keyword_values("regrid_parameter_assignment","weights_veg_bare_filename","string")
       destination_static = keyword_values("regrid_parameter_assignment",       "destination_static","string")
            source_static = keyword_values("regrid_parameter_assignment",            "source_static","string")

; These variable have some missing values over glacial/bare areas that might cause a problem.
;(9)     leaf_area_index
;(10)    stem_area_index
;(21)    canopy_wet_fraction
;(23)    depth_water_table
;(32)    temperature_canopy_air
;(34)    temperature_leaf
;(36)    vapor_pres_canopy_air
;(42)    canopy_liquid
;(43)    canopy_ice
;(44)    aquifer_water
;(45)    saturated_water
;(46)    lake_water
;(49)    leaf_carbon
;(50)    root_carbon
;(51)    stem_carbon
;(52)    wood_carbon
;(53)    soil_carbon_stable
;(54)    soil_carbon_fast
;(59)    transpiration_heat
;(60)    latent_heat_canopy
;(64)    precip_adv_heat_total

special_variables = (/9,10,21,23,32,34,36,42,43,44,45,46,49,50,51,52,53,54,59,60,64/)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; read in information on the destination and source grids
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

destination_infile = addfile(destination_static,"r")
destination_vegtype = destination_infile->vegetation_category
destination_soiltype = destination_infile->soil_category
destination_elevation = destination_infile->elevation
destination_tile = destination_infile->cube_tile
destination_i = destination_infile->cube_i
destination_j = destination_infile->cube_j
destination_latitude = destination_infile->latitude
destination_longitude = destination_infile->longitude

source_infile = addfile(source_static,"r")
source_vegtype = source_infile->vegetation_category
source_soiltype = source_infile->soil_category
source_elevation = source_infile->elevation
source_tile = source_infile->cube_tile
source_i = source_infile->cube_i
source_j = source_infile->cube_j
source_latitude = source_infile->latitude
source_longitude = source_infile->longitude

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; hard code porosity from the soil tables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

porosity = (/-999.,0.339,0.421,0.434,0.476,0.484,0.439,0.404,0.464, \ ; add fake at beginning for soil type 0
                   0.465,0.406,0.468,0.468,0.439,1.000,0.200,0.421, \
                   0.468,0.200,0.339/)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; read in all the weights files info for the different mappings
;  source_lookup: source grid that maps to the destination grid, 1-based
;  destination_lookup: for nearest neighbor, 1-based
;     this will just be a grid count or a list of grids that fit criteria
;  weights: for nearest neighbor, this will = 1.0
;  the length of each vector will be the number of corresponding destination grids, 
;     e.g., weights=total destination grids, weights_snow=total number of glacier grids
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

weights_file = addfile(weights_filename,"r")
source_lookup      = weights_file->col
destination_lookup = weights_file->row
weights            = weights_file->S

weights_file = addfile(weights_veg_filename,"r")
source_lookup_veg      = weights_file->col
destination_lookup_veg = weights_file->row
weights_veg            = weights_file->S

weights_file = addfile(weights_bare_filename,"r")
source_lookup_bare      = weights_file->col
destination_lookup_bare = weights_file->row
weights_bare            = weights_file->S

weights_file = addfile(weights_snow_filename,"r")
source_lookup_snow      = weights_file->col
destination_lookup_snow = weights_file->row
weights_snow            = weights_file->S

weights_file = addfile(weights_veg_bare_filename,"r")  ; these are the vegetation grids that are mapped to bare
source_lookup_veg_bare      = weights_file->col
destination_lookup_veg_bare = weights_file->row
weights_veg_bare            = weights_file->S

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; create some source information on the destination grid
;  source_to_destination_map: 0-based source to 0-based destination mapping
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

source_to_destination_map = new(dimsizes(destination_lookup),integer)
source_to_destination_map@_FillValue = -999
source_to_destination_map = -999

source_soil_type_on_destination = source_to_destination_map
source_veg_type_on_destination = source_to_destination_map

source_elevation_on_destination = new(dimsizes(destination_lookup),float)
source_elevation_on_destination@_FillValue = -999.
source_elevation_on_destination = -999.

source_latitude_on_destination = source_elevation_on_destination
source_longitude_on_destination = source_elevation_on_destination

print("missing source_to_destination_map: "+num(ismissing(source_to_destination_map)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; for the three mappings populate the source information
;  there should be no empty grids
;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; veg-to-veg grids

do iloc = 0, dimsizes(weights_veg)-1

  destination_map = destination_lookup_veg(iloc)-1
  source_map = source_lookup_veg(iloc)-1
  type_check = .not.((destination_vegtype(destination_map) .eq. 16 .and. source_vegtype(source_map) .eq. 16) .or. \
                     (destination_vegtype(destination_map) .eq. 15 .and. source_vegtype(source_map) .eq. 15))
  if(ismissing(source_to_destination_map(destination_map) .and. type_check)) then
    source_to_destination_map(destination_map) = source_map
    source_soil_type_on_destination(destination_map) = source_soiltype(source_map)
    source_veg_type_on_destination(destination_map) = source_vegtype(source_map)
    source_elevation_on_destination(destination_map) = source_elevation(source_map)
    source_latitude_on_destination(destination_map) = source_latitude(source_map)
    source_longitude_on_destination(destination_map) = source_longitude(source_map)
  else
    print("already a mapped source grid at 0-based bare destination: "+destination_map)
    print("or type_check error: "+destination_vegtype(destination_map) +" "+ source_vegtype(source_map))
  end if

end do

print("missing source_to_destination_map: "+num(ismissing(source_to_destination_map)))

; snow-to-snow grids

do iloc = 0, dimsizes(weights_snow)-1

  destination_map = destination_lookup_snow(iloc)-1   ; 0-based location in destination vector
  source_map = source_lookup_snow(iloc)-1
  type_check = destination_vegtype(destination_map) .eq. 15 .and. source_vegtype(source_map) .eq. 15
  if(ismissing(source_to_destination_map(destination_map) .and. type_check)) then
    source_to_destination_map(destination_map) = source_map
    source_soil_type_on_destination(destination_map) = source_soiltype(source_map)
    source_veg_type_on_destination(destination_map) = source_vegtype(source_map)
    source_elevation_on_destination(destination_map) = source_elevation(source_map)
    source_latitude_on_destination(destination_map) = source_latitude(source_map)
    source_longitude_on_destination(destination_map) = source_longitude(source_map)
  else
    print("already a mapped source grid at 0-based snow destination: "+destination_map)
    print("or type_check error: "+destination_vegtype(destination_map) +" "+ source_vegtype(source_map))
  end if

end do

print("missing source_to_destination_map: "+num(ismissing(source_to_destination_map)))

; bare-to-bare grids

do iloc = 0, dimsizes(weights_bare)-1

  destination_map = destination_lookup_bare(iloc)-1
  source_map = source_lookup_bare(iloc)-1
  type_check = destination_vegtype(destination_map) .eq. 16 .and. source_vegtype(source_map) .eq. 16
  if(ismissing(source_to_destination_map(destination_map) .and. type_check)) then
    source_to_destination_map(destination_map) = source_map
    source_soil_type_on_destination(destination_map) = source_soiltype(source_map)
    source_veg_type_on_destination(destination_map) = source_vegtype(source_map)
    source_elevation_on_destination(destination_map) = source_elevation(source_map)
    source_latitude_on_destination(destination_map) = source_latitude(source_map)
    source_longitude_on_destination(destination_map) = source_longitude(source_map)
  else
    print("already a mapped source grid at 0-based bare destination: "+destination_map)
    print("or type_check error: "+destination_vegtype(destination_map) +" "+ source_vegtype(source_map))
  end if

end do

print("missing source_to_destination_map: "+num(ismissing(source_to_destination_map)))

if(num(ismissing(source_to_destination_map)).ne.0) then
  print("mapping did not get filled")
  exit
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; first pass of mapping done, now check if there are "bad" mapping grids
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mapping_distance = gc_latlon(destination_latitude,destination_longitude,source_latitude_on_destination,source_longitude_on_destination,2,3)

elevation_difference_d2s = new(dimsizes(destination_lookup),float)
elevation_difference_d2s = destination_elevation - source_elevation_on_destination

print("elevation_equal_count: "+num(elevation_difference_d2s.eq.0.0))
print("max d-s elevation difference: "+max(elevation_difference_d2s))
print("min d-s elevation difference: "+min(elevation_difference_d2s))

; check on the big elevation difference

elevation_check_print = False
if(elevation_check_print) then  
 do iloc = 0, dimsizes(destination_lookup)-1
  if(abs(elevation_difference_d2s(iloc)).gt.4000) then  
    print("dest tile: "+destination_tile(iloc))
    print("dest i: "+destination_i(iloc))
    print("dest j: "+destination_j(iloc))
    print("dest elevation: "+destination_elevation(iloc))
    print("dest land cover: "+destination_vegtype(iloc))

    print("source tile: "+source_tile(source_to_destination_map(iloc)))
    print("source i: "+source_i(source_to_destination_map(iloc)))
    print("source j: "+source_j(source_to_destination_map(iloc)))
    print("source elevation: "+source_elevation_on_destination(iloc))
    print("source elevation: "+source_elevation(source_to_destination_map(iloc)))
  end if
 end do
 exit
end if

elevation_threshold = 1500.0

bare_problem_grids = ((abs(elevation_difference_d2s).gt.elevation_threshold) ) \
                       .and. (destination_vegtype.eq.16)

snow_problem_grids = ((abs(elevation_difference_d2s).gt.elevation_threshold) ) \
                       .and. (destination_vegtype.eq.15)

 veg_problem_grids = ((abs(elevation_difference_d2s).gt.elevation_threshold) ) \
                       .and. (destination_vegtype.ne.16.and.destination_vegtype.ne.15)

     problem_grids = ((abs(elevation_difference_d2s).gt.elevation_threshold) )

print("bare_problem_grids: "+num(bare_problem_grids))
print("snow_problem_grids: "+num(snow_problem_grids))
print("veg_problem_grids : "+num(veg_problem_grids))
print("problem_grids     : "+num(problem_grids))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fix the bare_problem_grids by using nearest vegetation grid
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; veg-to-bare grids

bare_problems_fixed = 0
do iloc = 0, dimsizes(destination_lookup)-1

 if(bare_problem_grids(iloc)) then
  print("fixing bare_problem_grid: "+iloc)
  print("source was: "+source_to_destination_map(iloc))

  found = False
  do ifind = 0, dimsizes(weights_veg_bare)-1
    if(.not.found) then
      if(iloc .eq. destination_lookup_veg_bare(ifind)-1) then
        destination_map = destination_lookup_veg_bare(ifind)-1
        source_map = source_lookup_veg_bare(ifind)-1
        found = True
      end if
    end if
  end do
  if(.not.found) then
    print("did not find a fix")
    exit
  end if

  print("destination, source now: "+destination_map+" "+source_map)
  print("elevation difference was: "+elevation_difference_d2s(iloc))

  type_check = destination_vegtype(destination_map) .eq. 16 .and. source_vegtype(source_map) .ne. 16 .and. \
                                                                  source_vegtype(source_map) .ne. 15
  if(type_check) then
    source_to_destination_map(destination_map) = source_map
    source_soil_type_on_destination(destination_map) = source_soiltype(source_map)
    source_veg_type_on_destination(destination_map) = source_vegtype(source_map)
    source_elevation_on_destination(destination_map) = source_elevation(source_map)
    source_latitude_on_destination(destination_map) = source_latitude(source_map)
    source_longitude_on_destination(destination_map) = source_longitude(source_map)
  else
    print("type_check error: "+destination_vegtype(destination_map) +" "+ source_vegtype(source_map))
  end if

  print("elevation difference now: "+(destination_elevation(iloc)-source_elevation_on_destination(iloc)))
  bare_problems_fixed = bare_problems_fixed + 1
  print("Fixing bare_problem_grid count: "+bare_problems_fixed)

 end if ; bare_problem_grids

end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; recheck elevation difference
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

elevation_difference_d2s = destination_elevation - source_elevation_on_destination

print("elevation_equal_count: "+num(elevation_difference_d2s.eq.0.0))
print("max d-s elevation difference: "+max(elevation_difference_d2s))
print("min d-s elevation difference: "+min(elevation_difference_d2s))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; calculate porosity adjustment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

porosity_adjustment = new(dimsizes(destination_lookup),float)
porosity_adjustment = -999.0
porosity_adjustment_count = 0
porosity_equal_count = 0

; for snow grids porosity_adjustment should be 1.0 (do nothing)

do iloc = 0, dimsizes(destination_lookup)-1

  if(destination_vegtype(iloc) .eq. 15) then ; permanent snow
    porosity_adjustment(iloc) = -1.0  ; nothing will be done for adjustment<0 later
  else
    if(destination_soiltype(iloc).ne.source_soil_type_on_destination(iloc)) then ; soil mismatch
      porosity_adjustment(iloc) = porosity(destination_soiltype(iloc)) \
                                / porosity(source_soil_type_on_destination(iloc))
      porosity_adjustment_count = porosity_adjustment_count + 1
      if(porosity(destination_soiltype(iloc)).eq.porosity(source_soil_type_on_destination(iloc))) then
        porosity_equal_count = porosity_equal_count + 1  ;grids with different soil type but same porosity
      end if
    else
      porosity_adjustment(iloc) = -1.0  ; nothing will be done for adjustment<0 later
    end if
  end if

end do

print("porosity_adjustment_count: "+porosity_adjustment_count)
print("porosity_equal_count: "+porosity_equal_count)

num_bad_porosity  = num(porosity_adjustment .le. -998.0)

if(num_bad_porosity .gt. 0) then
  print("num_bad_porosity: "+num_bad_porosity)
  exit
end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; finally start replacement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

infile = addfile(source_restart,"r")
invars = getfilevarnames(infile)
print(invars)
;exit

system("if [ -e "+destination_restart+" ]; then rm -f "+destination_restart+ ";fi")
outfile = addfile(destination_restart,"c")

outfile->time = infile->time
outfile->timestep = infile->timestep

Opt = True

do ivar = 2, 69 ;30,30;34,34 ; 2, 69

  print("Processing: "+invars(ivar))
  invar = infile->$invars(ivar)$
  dimnames = getfilevardimnames(infile,invars(ivar))
  dimlen   = dimsizes(invar)

  outvar          = ESMF_regrid_with_weights(invar,weights_filename,Opt)

  if(dimsizes(dimlen).gt.2) then  ; 3D soil or snow or albedo variable

    do ilev = 0, dimlen(1)-1

      outvar(0,ilev,:) = invar(0,ilev,source_to_destination_map)

      if(invars(ivar).eq."soil_moisture_vol") then
        outvar(0,ilev,:) = where(porosity_adjustment.gt.0, outvar(0,ilev,:) * porosity_adjustment, outvar(0,ilev,:))
        outvar(0,ilev,:) = where(outvar(0,ilev,:).lt.0.02,0.02,outvar(0,ilev,:))
      end if 

      if(invars(ivar).eq."soil_liquid_vol") then
        outvar(0,ilev,:) = where(porosity_adjustment.gt.0, outvar(0,ilev,:) * porosity_adjustment, outvar(0,ilev,:))
      end if 

      if(invars(ivar).eq."temperature_soil") then
        outvar(0,ilev,:) = outvar(0,ilev,:) - 0.0065*elevation_difference_d2s
      end if 

      if(invars(ivar).eq."temperature_snow") then
        outvar(0,ilev,:) = where(outvar(0,ilev,:).gt.0, outvar(0,ilev,:) - 0.0065*elevation_difference_d2s, outvar(0,ilev,:))
        outvar(0,ilev,:) = where(outvar(0,ilev,:).gt.273.15, 273.15, outvar(0,ilev,:))
      end if 

    end do

  else

    outvar(0,:) = invar(0,source_to_destination_map)

  end if

  outvar!1 = dimnames(1)
  if(dimsizes(dimlen).gt.2) then
    outvar!2 = dimnames(2)
  end if
  delete(outvar@lat1d)
  delete(outvar@lon1d)

  outfile->$invars(ivar)$ = outvar

  delete(invar)
  delete(outvar)
  delete(dimnames)
  delete(dimlen)

end do

end

