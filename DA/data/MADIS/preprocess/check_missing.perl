#!/usr/bin/perl

@nums = ("00","01","02","03","04","05","06","07","08","09", 
         "10","11","12","13","14","15","16","17","18","19", 
         "20","21","22","23","24","25","26","27","28","29", 
         "30","31");

@ddsinmm = (0,31,28,31,30,31,30,31,31,30,31,30,31);

$path1 = "/scratch2/NCEPDEV/land/data/DA/snow_depth/MADIS/hourly";

for($yyyy=2023; $yyyy<=2023; $yyyy++)
 {

for($mm=1; $mm<=5; $mm++)
 {

  $ddmax = $ddsinmm[$mm];

  if($mm == 2 && ($yyyy == "2012" || $yyyy == "2016" || $yyyy == "2020")) 
   {
    $ddmax = $ddmax + 1;
   }

for($dd=1;$dd<=$ddmax;$dd++)
 {
 
   @filenames = `ls -1 $path1/$yyyy$nums[$mm]$nums[$dd]/*`;
   $numfiles = @filenames;
   if($numfiles != 24 ) 
    {
      print("$yyyy$nums[$mm]$nums[$dd] : $numfiles \n");
    }
 
 }
 }
 }


 

