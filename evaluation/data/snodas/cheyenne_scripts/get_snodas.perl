#!/usr/bin/perl

$yyyy_beg = 2021;
$yyyy_end = 2022;

$ftpmain = "ftp://sidads.colorado.edu/DATASETS/NOAA/G02158/unmasked";

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

@mms = ("01_Jan","02_Feb","03_Mar","04_Apr","05_May","06_Jun",
        "07_Jul","08_Aug","09_Sep","10_Oct","11_Nov","12_Dec");

# This will be the outer time loop

for($yyyy=$yyyy_beg;$yyyy<=$yyyy_end;$yyyy=$yyyy+1)

 { 

for($mm=0;$mm<=11;$mm=$mm+1)

 { 

  print("wgetting $yyyy $mms[$mm] \n");
  
  system("wget --ftp-user=anonymous -nv -np -nd -r -A.tar $ftpmain/$yyyy/$mms[$mm]/ ");

 }
 }
