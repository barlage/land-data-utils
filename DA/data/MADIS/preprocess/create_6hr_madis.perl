#!/usr/bin/perl

$yyyy_beg = 2021;
$yyyy_end = 2021;
$mm_beg   = 1;
$mm_end   = 12;
$dd_beg   = 1;
$dd_end   = -999; # currently only does to the end of the month
$hh_beg   = 0;
$hh_end   = 18;
$hh_inc   = 6;

$datapath = "/scratch2/NCEPDEV/land/data/DA/snow_depth/MADIS/hourly/";

@nums = ("00","01","02","03","04","05","06","07","08","09",
         "10","11","12","13","14","15","16","17","18","19",
         "20","21","22","23","24","25","26","27","28","29",
         "30","31","32","33","34","35","36","37","38","39");

@leap_days    = (0,31,29,31,30,31,30,31,31,30,31,30,31);
@nonleap_days = (0,31,28,31,30,31,30,31,31,30,31,30,31);

for($iyyyy=$yyyy_beg; $iyyyy<=$yyyy_end; $iyyyy++)
 {
  @days = @nonleap_days;
  if( $iyyyy%4 == 0 ) {@days = @leap_days}
for($imm=$mm_beg; $imm<=$mm_end; $imm++)
 {
for($idd=$dd_beg; $idd<=$days[$imm]; $idd++)
#for($idd=$dd_beg; $idd<=1; $idd++)
 {
for($ihh=$hh_beg; $ihh<=$hh_end; $ihh=$ihh+$hh_inc)
 {

  if($ihh == 0) {
    $prev_dd = $idd- 1;
    $prev_mm = $imm;
    $prev_yyyy = $iyyyy;
    if($prev_dd < 1)
       { 
         $prev_mm = $imm - 1;
         if($prev_mm < 1)
           { 
            $prev_mm = 12;
            $prev_yyyy = $iyyyy - 1;
           }
        $prev_dd = $days[$prev_mm];
       }

    $hr1 = "${datapath}${prev_yyyy}$nums[$prev_mm]$nums[$prev_dd]/${prev_yyyy}$nums[$prev_mm]$nums[$prev_dd]_2100";
    $hr2 = "${datapath}${prev_yyyy}$nums[$prev_mm]$nums[$prev_dd]/${prev_yyyy}$nums[$prev_mm]$nums[$prev_dd]_2200";
    $hr3 = "${datapath}${prev_yyyy}$nums[$prev_mm]$nums[$prev_dd]/${prev_yyyy}$nums[$prev_mm]$nums[$prev_dd]_2300";
    $hr4 = "${datapath}${iyyyy}$nums[$imm]$nums[$idd]/${iyyyy}$nums[$imm]$nums[$idd]_$nums[$ihh]00";
    $hr5 = "${datapath}${iyyyy}$nums[$imm]$nums[$idd]/${iyyyy}$nums[$imm]$nums[$idd]_$nums[$ihh+1]00";
    $hr6 = "${datapath}${iyyyy}$nums[$imm]$nums[$idd]/${iyyyy}$nums[$imm]$nums[$idd]_$nums[$ihh+2]00";
    
    }else{
    
    $hr1 = "${datapath}${iyyyy}$nums[$imm]$nums[$idd]/${iyyyy}$nums[$imm]$nums[$idd]_$nums[$ihh-3]00";
    $hr2 = "${datapath}${iyyyy}$nums[$imm]$nums[$idd]/${iyyyy}$nums[$imm]$nums[$idd]_$nums[$ihh-2]00";
    $hr3 = "${datapath}${iyyyy}$nums[$imm]$nums[$idd]/${iyyyy}$nums[$imm]$nums[$idd]_$nums[$ihh-1]00";
    $hr4 = "${datapath}${iyyyy}$nums[$imm]$nums[$idd]/${iyyyy}$nums[$imm]$nums[$idd]_$nums[$ihh]00";
    $hr5 = "${datapath}${iyyyy}$nums[$imm]$nums[$idd]/${iyyyy}$nums[$imm]$nums[$idd]_$nums[$ihh+1]00";
    $hr6 = "${datapath}${iyyyy}$nums[$imm]$nums[$idd]/${iyyyy}$nums[$imm]$nums[$idd]_$nums[$ihh+2]00";
    
    }
    
    print "${iyyyy}$nums[$imm]$nums[$idd]_$nums[$ihh]00 \n";
    print "$hr1 \n";
    print "$hr2 \n";
    print "$hr3 \n";
    print "$hr4 \n";
    print "$hr5 \n";
    print "$hr6 \n\n";
        
    system("ncrcat -v latitude,longitude,elevation,stationId,observationTime,snowDepthQCR,snowDepth $hr1 $hr2 $hr3 $hr4 $hr5 $hr6 6hourly/${iyyyy}$nums[$imm]$nums[$idd]_$nums[$ihh]00");

    }
    }
    }
    }

    
