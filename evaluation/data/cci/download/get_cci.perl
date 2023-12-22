#!/usr/bin/perl

# Set the days you want to download
$dd_beg   = 1;  # 305=Nov 1
$dd_end   = 279;  # 181=Jun 30; 212=Jul 31; 243=Aug 31
$yyyy_beg = 2018;
$yyyy_end = 2022;
$ddinc    = 1;

$ftpmain = "https://dap.ceda.ac.uk/neodc/esacci/soil_moisture/data/daily_files/COMBINED/v08.1/";

# Utilities
@nums = ("00","01","02","03","04","05","06","07","08","09","10",
         "11","12","13","14","15","16","17","18","19","20",
         "21","22","23","24","25","26","27","28","29","30",
         "31","32","33","34","35","36","37","38","39","40",
         "41","42","43","44","45","46","47","48","49","50",
         "51","52","53","54","55","56","57","58","59","60",
         "61","62","63","64","65","66","67","68","69","70",
         "71","72","73","74","75","76","77","78","79","80",
         "81","82","83","84","85","86","87","88","89","90",
         "91","92","93","94","95","96","97","98","99");

@days      = (0,31,59,90,120,151,181,212,243,273,304,334,365);
@leap_days = (0,31,60,91,121,152,182,213,244,274,305,335,366);

# This will be the outer time loop

for($yyyy=$yyyy_beg;$yyyy<=$yyyy_end;$yyyy=$yyyy+1)

 { 

$dd_end_check = $dd_end;
if($yyyy%4 != 0 && $dd_end==366) { $dd_end_check = 365 }

for($julday=$dd_beg;$julday<=$dd_end_check;$julday=$julday+$ddinc)

 { 

 # This little section finds the text month and day
 
 for($mm=1;$mm<=12;$mm++)
  {
  if($yyyy%4 == 0) 
   {
    if($julday>$leap_days[$mm-1] && $julday<=$leap_days[$mm]) 
     {
       $start_mm = $mm;
       $start_dd = $julday - $leap_days[$mm-1];
     }
   }else{
    if($julday>$days[$mm-1] && $julday<=$days[$mm]) 
     {
       $start_mm = $mm;
       $start_dd = $julday - $days[$mm-1];
     }
    }
  }
  
  $datestring = "$yyyy$nums[$start_mm]$nums[$start_dd]";

  print("checking $datestring \n");

  $fullfile = "ESACCI-SOILMOISTURE-L3S-SSMV-COMBINED-${datestring}000000-fv08.1.nc";
  
  if(-e $fullfile)
  {}else{
    print("wgetting $datestring \n");
    system("wget -nv -np -nd $ftpmain/$yyyy/$fullfile");
  }
 }

 }
