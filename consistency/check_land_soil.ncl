;
; script to check the consistency of fix files and sfc_data files
;    the main purpose is to check if input sfc_data files have valid veg and soil for all land_frac>0
; 
;  tests total count and grid-to-grid agreement
;
;  script is not that flexible, so need to 
;    1. set paths of the location of the fix and input tile files
;    2. set res number, e.g., 96, 384, 1152, etc
;    3. set oro file naming convention, e.g., 
;          files named oro_C384.mx025.tileX.nc should set oro_file = "oro_C384.mx025.tile"
;          files named C384_oro_data.tileX.nc should set oro_file = "C384_oro_data.tile"
;    4. set veg and soil file naming convention relative to oro files;
;        may need relative directory additions, e.g., 
;          if they are in sfc/ should set veg_file = "sfc/C384.mx025.vegetation_type.tile"
;          if they are in a directory higher set veg_file = "..//C384.mx025.vegetation_type.tile"
;    5. set sfc_data file naming convention, e.g., most are just "sfc_data.tile"
;    6. set lake_present to True if you want comparison of lake grids 
;          (some old oro files don't have lake info)
;
;  Some problems you may encounter:
;    - the convention for water grids in the vegetation and soil type have changed over time

begin

res = 24

fix_path = "/scratch2/NCEPDEV/land/Michael.Barlage/C24_test/run_atm/INPUT/"
sfc_path = "/scratch2/NCEPDEV/land/Michael.Barlage/C24_test/run_atm/INPUT/"

oro_file = "C24.mx500_oro_data.tile"
veg_file = "../C24.mx500.vegetation_type.tile"
soi_file = "../C24.mx500.soil_type.tile"
sfc_file = "sfc_data.tile"

lake_present = True

 num_oro_land_frac_gt0 = 0                     ; number land_frac > 0 in oro file
 num_oro_lake_frac = 0                         ; number lake_frac > 0 in oro file
 num_oro_land_frac_100 = 0                     ; number land_frac = 100% in oro file
 num_oro_land_frac_ge50 = 0                    ; number land_frac >= 50% in oro file
 num_oro_slmsk = 0                             ; number slmsk = land in oro file
 num_oro_land_frac_gt0_and_no_fix_veg = 0      ; number land_frac > 0 fix file veg_type = ocean
 num_oro_land_frac_gt0_and_no_fix_soil = 0     ; number land_frac > 0 fix file soil_type = ocean
 num_oro_land_frac_gt0_and_no_sfc_veg = 0      ; number land_frac > 0 sfc file veg_type = ocean
 num_oro_land_frac_gt0_and_no_sfc_soil = 0     ; number land_frac > 0 sfc file soil_type = ocean
 num_fix_valid_veg = 0                         ; number fix file veg_type grids /= 17
 num_fix_valid_soil = 0                        ; number fix file soil_type grids /= 14
 num_fix_veg_17 = 0                            ; number fix file veg_type grids = 17
 num_sfc_slmsk = 0                             ; number sfc file slmsk = land
 num_sfc_valid_veg = 0                         ; number sfc file veg_type grids = [1-16,18-20]
 num_sfc_valid_soil = 0                        ; number sfc file soil_type grids = [1-13,15]
 num_sfc_veg_0 = 0                             ; number sfc file veg_type grids = 0
 num_sfc_soil_0 = 0                            ; number sfc file veg_type grids = 0
 num_sfc_veg_17 = 0                            ; number sfc file veg_type grids = 17
 num_sfc_soil_14 = 0                           ; number fix file veg_type grids = 14
 fix_veg_sfc_veg_check = 0                     ; number veg grid inconsistencies between fix and sfc
 fix_soil_sfc_soil_check = 0                   ; number soil grid inconsistencies between fix and sfc
 fix_veg_sfc_soil_check = 0                    ; number fix veg and sfc soil inconsistencies
 fix_soil_sfc_veg_cheeck = 0                   ; number fix soil and sfc veg inconsistencies
 oro_slmsk_sfc_veg_check = 0                   ; number fix slmsk and sfc veg inconsistencies
 oro_slmsk_sfc_soil_check = 0                  ; number fix slmsk and sfc soil inconsistencies
 
do itile = 1,6

print("Starting tile: "+itile)

 fix_oro_file     = addfile(fix_path+oro_file+itile+".nc","r")
 fix_vegtype_file = addfile(fix_path+veg_file+itile+".nc","r")
 fix_soil_file    = addfile(fix_path+soi_file+itile+".nc","r")
 sfc_tile_files   = addfile(sfc_path+sfc_file+itile+".nc","r")
 
 fix_oro_slmsk      = fix_oro_file->slmsk 
 fix_oro_land_frac  = fix_oro_file->land_frac
if(lake_present) then
 fix_oro_lake_frac  = fix_oro_file->lake_frac
end if
 fix_veg_type       = fix_vegtype_file->vegetation_type(0,:,:)
 fix_soil_type      = fix_soil_file->soil_type(0,:,:)
 
 sfc_slmsk          = sfc_tile_files->slmsk(0,:,:)
 sfc_veg_type       = sfc_tile_files->vtype(0,:,:)
 sfc_soil_type      = sfc_tile_files->stype(0,:,:)

 fix_valid_veg  = fix_veg_type
 fix_valid_veg  = where((fix_veg_type.ge. 1.and.fix_veg_type.le.16).or. \ 
                        (fix_veg_type.ge.18.and.fix_veg_type.le.20),1,0)
 fix_valid_soil = fix_veg_type
 fix_valid_soil = where((fix_soil_type.ge. 1.and.fix_soil_type.le.13).or. \ 
                        (fix_soil_type.ge.15.and.fix_soil_type.le.16),1,0)
 
 sfc_valid_veg  = sfc_veg_type
 sfc_valid_veg  = where((sfc_veg_type.ge. 1.and.sfc_veg_type.le.16).or. \ 
                        (sfc_veg_type.ge.18.and.sfc_veg_type.le.20),1,0)
 sfc_valid_soil = sfc_veg_type
 sfc_valid_soil = where((sfc_soil_type.ge. 1.and.sfc_soil_type.le.13).or. \ 
                        (sfc_soil_type.ge.15.and.sfc_soil_type.le.16),1,0)
 
 num_oro_slmsk          = num_oro_slmsk          + num(fix_oro_slmsk.eq.1) 
 num_oro_land_frac_gt0  = num_oro_land_frac_gt0  + num(fix_oro_land_frac.le.1.0.and.fix_oro_land_frac.gt.0) 
 num_oro_land_frac_100  = num_oro_land_frac_100  + num(fix_oro_land_frac.eq.1.0) 
 num_oro_land_frac_ge50 = num_oro_land_frac_ge50 + num(fix_oro_land_frac.le.1.0.and.fix_oro_land_frac.ge.0.5) 
if(lake_present) then
 num_oro_lake_frac      = num_oro_lake_frac      + num(fix_oro_lake_frac.le.1.0.and.fix_oro_lake_frac.gt.0) 
end if
 num_fix_valid_veg      = num_fix_valid_veg      + num(fix_valid_veg.eq.1)
 num_fix_valid_soil     = num_fix_valid_soil     + num(fix_valid_soil.eq.1)
 num_fix_veg_17         = num_fix_veg_17         + num(fix_veg_type.eq.17) 

 num_oro_land_frac_gt0_and_no_fix_veg  = num_oro_land_frac_gt0_and_no_fix_veg  + num(fix_oro_land_frac.le.1.0.and.fix_oro_land_frac.gt.0.and.fix_valid_veg.eq.0) 
 num_oro_land_frac_gt0_and_no_fix_soil = num_oro_land_frac_gt0_and_no_fix_soil + num(fix_oro_land_frac.le.1.0.and.fix_oro_land_frac.gt.0.and.fix_valid_soil.eq.0) 
 num_oro_land_frac_gt0_and_no_sfc_veg  = num_oro_land_frac_gt0_and_no_sfc_veg  + num(fix_oro_land_frac.le.1.0.and.fix_oro_land_frac.gt.0.and.sfc_valid_veg.eq.0) 
 num_oro_land_frac_gt0_and_no_sfc_soil = num_oro_land_frac_gt0_and_no_sfc_soil + num(fix_oro_land_frac.le.1.0.and.fix_oro_land_frac.gt.0.and.sfc_valid_soil.eq.0) 

 num_sfc_slmsk      = num_sfc_slmsk      + num(sfc_slmsk.eq.1)
 num_sfc_valid_veg  = num_sfc_valid_veg  + num(sfc_valid_veg.eq.1)
 num_sfc_valid_soil = num_sfc_valid_soil + num(sfc_valid_soil.eq.1)
 num_sfc_veg_0      = num_sfc_veg_0      + num(sfc_veg_type.eq.0)
 num_sfc_soil_0     = num_sfc_soil_0     + num(sfc_soil_type.eq.0)
 num_sfc_veg_17     = num_sfc_veg_17     + num(sfc_veg_type.eq.17)
 num_sfc_soil_14    = num_sfc_soil_14    + num(sfc_soil_type.eq.14)

 fix_veg_sfc_veg_check    = fix_veg_sfc_veg_check    + num(fix_valid_veg  .ne. sfc_valid_veg)
 fix_soil_sfc_soil_check  = fix_soil_sfc_soil_check  + num(fix_valid_soil .ne. sfc_valid_soil)
 fix_veg_sfc_soil_check   = fix_veg_sfc_soil_check   + num(fix_valid_veg  .ne. sfc_valid_soil)
 fix_soil_sfc_veg_cheeck  = fix_soil_sfc_veg_cheeck  + num(fix_valid_soil .ne. sfc_valid_veg)
 oro_slmsk_sfc_veg_check  = oro_slmsk_sfc_veg_check  + num(fix_oro_slmsk  .ne. sfc_valid_veg)
 oro_slmsk_sfc_soil_check = oro_slmsk_sfc_soil_check + num(fix_oro_slmsk  .ne. sfc_valid_soil)

 print("cumulative fix_oro_slmsk = 1        : " + num_oro_slmsk)
 print("cumulative fix_oro_land_frac (0,1]  : " + num_oro_land_frac_gt0)
 print("cumulative fix_oro_land_frac = 1    : " + num_oro_land_frac_100)
 print("cumulative fix_oro_land_frac [0.5,1]: " + num_oro_land_frac_ge50)
if(lake_present) then
 print("cumulative fix_oro_lake_frac (0,1]:   " + num_oro_lake_frac)
end if
 print("cumulative valid fix veg type                    : " + num_fix_valid_veg)
 print("cumulative valid fix soil type                   : " + num_fix_valid_soil)
 print("cumulative missing fix veg type with land_frac>0 : "+num_oro_land_frac_gt0_and_no_fix_veg)
 print("cumulative missing fix soil type with land_frac>0: "+num_oro_land_frac_gt0_and_no_fix_soil)
 print("cumulative missing sfc veg type with land_frac>0 : "+num_oro_land_frac_gt0_and_no_sfc_veg)
 print("cumulative missing sfc soil type with land_frac>0: "+num_oro_land_frac_gt0_and_no_sfc_soil)
 print("cumulative fix land type = 17                    : "+num_fix_veg_17)

 print("cumulative sfc_slmsk = 1      : "+num_sfc_slmsk)
 print("cumulative valid sfc veg type : "+num_sfc_valid_veg)
 print("cumulative valid sfc soil type: "+num_sfc_valid_soil)
 
 print("cumulative nonsfc veg  type >0  : "+num_sfc_valid_veg)
 print("cumulative sfc soil type /=14: "+num_sfc_valid_soil)
 print("cumulative sfc veg  type =0  : "+num_sfc_veg_0)
 print("cumulative sfc soil type =0  : "+num_sfc_soil_0)
 print("cumulative sfc veg  type =17 : "+num_sfc_veg_17)
 print("cumulative sfc soil type =14 : "+num_sfc_soil_14)

 print("cumulative mismatch veg between fix and sfc  : "+fix_veg_sfc_veg_check)
 print("cumulative mismatch soil between fix and sfc : "+fix_soil_sfc_soil_check)
 print("cumulative mismatch fix_veg and sfc_soil     : "+fix_veg_sfc_soil_check)
 print("cumulative mismatch fix_soil and sfc_veg     : "+fix_soil_sfc_veg_cheeck)
 print("cumulative mismatch oro_slmsk and sfc_veg    : "+oro_slmsk_sfc_veg_check)
 print("cumulative mismatch oro_slmsk and sfc_soil   : "+oro_slmsk_sfc_soil_check)

end do

print("")
print("Comparing oro files: "+fix_path+oro_file+"*.nc")
print(" and veg files: "+fix_path+veg_file+"*.nc")
print(" and soil files: "+fix_path+soi_file+"*.nc")
print(" with sfc_data IC files: "+sfc_path+"*.nc")
print("")

if(num_oro_land_frac_gt0 .eq. num_fix_valid_veg) then
 print("PASS: oro file land_frac consistent with fix vegetation type")
else
 print("FAIL: oro file land_frac not consistent with fix vegetation type")
end if

if(num_oro_land_frac_gt0 .eq. num_fix_valid_soil) then
 print("PASS: oro file land_frac consistent with fix soil type")
else
 print("FAIL: oro file land_frac not consistent with fix soil type")
end if

if(num_oro_land_frac_gt0_and_no_sfc_veg .eq. 0) then
 print("PASS: all land_frac>0 have a valid sfc_data vegetation type")
else
 print("FAIL: some land_frac>0 do not have a valid sfc_data vegetation type")
end if

if(num_oro_land_frac_gt0_and_no_sfc_soil .eq. 0) then
 print("PASS: all land_frac>0 have a valid sfc_data soil type")
else
 print("FAIL: some land_frac>0 do not have a valid sfc_data soil type")
end if

if(num_sfc_valid_veg+num_sfc_veg_0 .eq. res*res*6) then
 print("PASS: all global sfc vegetation grids have a valid value [0-20]")
else
 print("FAIL: some global sfc vegetation grids have an invalid value (<0 or >20)")
end if

if(num_sfc_valid_soil+num_sfc_soil_0 .eq. res*res*6) then
 print("PASS: all global sfc_data soil grids have a valid value [0-16]")
else
 print("FAIL: some global sfc_data soil grids have an invalid value (<0 or >16)")
end if

if(num_oro_land_frac_gt0 .eq. num_sfc_valid_veg) then
 print("PASS: oro file land_frac consistent with sfc_data vegetation type")
else
 print("FAIL: oro file land_frac not consistent with sfc_data vegetation type")
end if

if(num_oro_land_frac_gt0 .eq. num_sfc_valid_soil) then
 print("PASS: oro file land_frac consistent with sfc_data soil type")
else
 print("FAIL: oro file land_frac not consistent with sfc_data soil type")
end if
print("")

end
