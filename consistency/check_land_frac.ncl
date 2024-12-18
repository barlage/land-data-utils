;
; script to compare two sets of oro_data files on their agreement for:
;    slmsk         : ocean generated land mask grids
;    land_frac > 0 : sfc_climo_gen determined land fraction on grid
;    lake_frac > 0 : sfc_climo_gen determined lake fraction on grid
; 
;  tests total count and grid-to-grid agreement
;
;  script is not that flexible, so need to 
;    1. set paths of the location of the oro tile files
;    2. set res number, e.g., 96, 384, 1152, etc
;    3. set oro file naming convention, e.g., 
;          files named oro_C384.mx025.tileX.nc should set oro_file1 = "oro_C384.mx025.tile"
;          files named C384_oro_data.tileX.nc should set oro_file1 = "C384_oro_data.tile"
;    4. set lake_present to True if you want comparison of lake grids 
;          (some old oro files don't have lake info)

begin

res = 384

fix_path1 = "/scratch1/NCEPDEV/global/glopara/fix/orog/20231027/C384/"
fix_path2 = "/scratch1/NCEPDEV/global/glopara/fix/orog/20240917/C384/"

oro_file1 = "C384.mx025_oro_data.tile"
oro_file2 = "C384.mx025_oro_data.tile"

lake_present = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  shouldn't need to change anything below this line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 num_oro1_land_frac_gt0 = 0
 num_oro1_lake_frac_gt0 = 0
 num_oro1_slmsk = 0
 num_oro2_land_frac_gt0 = 0
 num_oro2_lake_frac_gt0 = 0
 num_oro2_slmsk = 0
 num_land_frac_eq = 0
 num_lake_frac_eq = 0
 num_slmsk_eq = 0

do itile = 1,6

print("Starting tile: "+itile)

 fix_oro1_file    = addfile(fix_path1+oro_file1+itile+".nc","r")
 fix_oro2_file    = addfile(fix_path2+oro_file2+itile+".nc","r")
 
 fix_oro1_slmsk      = fix_oro1_file->slmsk 
 fix_oro1_land_frac  = fix_oro1_file->land_frac
if(lake_present) then
 fix_oro1_lake_frac  = fix_oro1_file->lake_frac
end if
 
 fix_oro2_slmsk      = fix_oro2_file->slmsk 
 fix_oro2_land_frac  = fix_oro2_file->land_frac
if(lake_present) then
 fix_oro2_lake_frac  = fix_oro2_file->lake_frac
end if
  
 num_oro1_slmsk          = num_oro1_slmsk + num(fix_oro1_slmsk.eq.1) 
 num_oro1_land_frac_gt0  = num_oro1_land_frac_gt0 + num(fix_oro1_land_frac.le.1.0.and.fix_oro1_land_frac.gt.0) 
if(lake_present) then
 num_oro1_lake_frac_gt0  = num_oro1_lake_frac_gt0 + num(fix_oro1_lake_frac.le.1.0.and.fix_oro1_lake_frac.gt.0) 
end if

 num_oro2_slmsk          = num_oro2_slmsk + num(fix_oro2_slmsk.eq.1) 
 num_oro2_land_frac_gt0  = num_oro2_land_frac_gt0 + num(fix_oro2_land_frac.le.1.0.and.fix_oro2_land_frac.gt.0) 
if(lake_present) then
 num_oro2_lake_frac_gt0  = num_oro2_lake_frac_gt0 + num(fix_oro2_lake_frac.le.1.0.and.fix_oro2_lake_frac.gt.0) 
end if

 num_land_frac_eq     = num_land_frac_eq  + num(fix_oro1_land_frac .eq. fix_oro2_land_frac) 
 num_lake_frac_eq     = num_lake_frac_eq  + num(fix_oro1_lake_frac .eq. fix_oro2_lake_frac) 
 num_slmsk_eq         = num_slmsk_eq  + num(fix_oro1_slmsk .eq. fix_oro2_slmsk) 

 print("number of cumulative data1 fix_oro_slmsk = 1        : " + num_oro1_slmsk)
 print("number of cumulative data1 fix_oro_land_frac (0,1]  : " + num_oro1_land_frac_gt0)
if(lake_present) then
 print("number of cumulative data1 fix_oro_lake_frac (0,1]  : " + num_oro1_lake_frac_gt0)
end if

 print("number of cumulative data2 fix_oro_slmsk = 1        : " + num_oro2_slmsk)
 print("number of cumulative data2 fix_oro_land_frac (0,1]  : " + num_oro2_land_frac_gt0)
if(lake_present) then
 print("number of cumulative data2 fix_oro_lake_frac (0,1]  : " + num_oro2_lake_frac_gt0)
end if
 print("number of cumulative equal fix_oro_slmsk = 1        : " + num_slmsk_eq)
 print("number of cumulative equal fix_oro_land_frac (0,1]  : " + num_land_frac_eq)
if(lake_present) then
 print("number of cumulative equal fix_oro_lake_frac (0,1]  : " + num_lake_frac_eq)
end if

end do

print("total number of grids :   " + (384*384*6))

print("")
print("Comparing oro files: "+fix_path1+oro_file1+"*.nc")
print(" with oro files: "+fix_path2+oro_file2+"*.nc")
print("")


end
