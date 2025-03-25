#!/usr/bin/perl

###

$yyyy_beg   = 2022;
$yyyy_end   = 2022;

$mm_beg     = 1;
$mm_end     = 12;

@nums = ("00","01","02","03","04","05","06","07","08","09", 
         "10","11","12","13","14","15","16","17","18","19", 
         "20","21","22","23","24","25","26","27","28","29", 
         "30","31","32","33","34","35","36","37","38","39",
         "40","41","42","43","44","45","46","47","48","49",
         "50","51","52","53","54","55","56","57","58","59",
         "60","61","62","63","64","65","66","67","68","69",
         "70","71","72","73","74","75","76","77","78","79",
         "80","81","82","83","84","85","86","87","88","89",
         "90","91","92","93","94","95","96","97","98","99");

@ddinmm = (31,28,31,30,31,30,31,31,30,31,30,31);

for($yyyy=$yyyy_beg; $yyyy<=$yyyy_end; $yyyy++)
 {
for($mm=$mm_beg; $mm<=$mm_end; $mm++)
 {

 $dds = $ddinmm[$mm-1];
 if ($yyyy%4 == 0 && $mm == 2) {$dds = 29}

for($dd=1; $dd<=$dds; $dd++)
 {

 $datestring = "$yyyy$nums[$mm]$nums[$dd]";
 
 print("Starting $datestring\n");
 
 $filename = "SNODAS_unmasked_${datestring}.tar";
 
 $outname = "SNODAS_unmasked_${datestring}.nc";
 
 chdir("/glade/scratch/barlage/snodas");
 
 system("tar xf $filename");
 
# Process SWE
 
 $swename = "zz_ssmv11034tS__T0001TTNATS${datestring}05HP001.dat";
 
 system("gzip -d $swename.gz");
 
 $hdrname = "zz_ssmv11034tS__T0001TTNATS${datestring}05HP001.hdr";
 
 system("cp ~/data/snodas/header_template $hdrname");
 
 system("gdal_translate -of NetCDF -a_srs '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs' -a_nodata -9999 -a_ullr -130.51666666666667 58.23333333333333 -62.25000000000000 24.10000000000000 $swename $outname");
 
 system("ncrename -h -v Band1,snow_water_equivalent $outname");
 system("ncatted -h -a long_name,snow_water_equivalent,m,c,'snow water equivalent' $outname");
 system("ncatted -h -a units,snow_water_equivalent,c,c,'meters' $outname");
 system("ncatted -h -a scale_factor,snow_water_equivalent,c,f,0.001 $outname");
 
# Process depth into temp file blah.nc
 
 $dphname = "zz_ssmv11036tS__T0001TTNATS${datestring}05HP001.dat";
 
 system("gzip -d $dphname.gz");
 
 $hdrname = "zz_ssmv11036tS__T0001TTNATS${datestring}05HP001.hdr";
 
 system("cp ~/data/snodas/header_template $hdrname");
 
 system("gdal_translate -of NetCDF -a_srs '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs' -a_nodata -9999 -a_ullr -130.51666666666667 58.23333333333333 -62.25000000000000 24.10000000000000 $dphname blah.nc");
 
 system("ncrename -h -v Band1,snow_depth blah.nc");
 system("ncatted -h -a long_name,snow_depth,m,c,'snow depth' blah.nc");
 system("ncatted -h -a units,snow_depth,c,c,'meters' blah.nc");
 system("ncatted -h -a scale_factor,snow_depth,c,f,0.001 blah.nc");
 
 system("ncks -h -A -v snow_depth blah.nc $outname");
 system("rm blah.nc");

# Process rainfall into temp file blah.nc
 
 $dphname = "zz_ssmv01025SlL00T0024TTNATS${datestring}05DP001.dat";

 system("gzip -d $dphname.gz");
 
 $hdrname = "zz_ssmv01025SlL00T0024TTNATS${datestring}05DP001.hdr";
 
 system("cp ~/data/snodas/header_template $hdrname");
 
 system("gdal_translate -of NetCDF -a_srs '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs' -a_nodata -9999 -a_ullr -130.51666666666667 58.23333333333333 -62.25000000000000 24.10000000000000 $dphname blah.nc");
 
 system("ncrename -h -v Band1,liquid_precipitation blah.nc");
 system("ncatted -h -a long_name,liquid_precipitation,m,c,'liquid precipitation' blah.nc");
 system("ncatted -h -a units,liquid_precipitation,c,c,'mm/day' blah.nc");
 system("ncatted -h -a scale_factor,liquid_precipitation,c,f,0.1 blah.nc");
 
 system("ncks -h -A -v liquid_precipitation blah.nc $outname");
 system("rm blah.nc");

# Process snowfall into temp file blah.nc
 
 $dphname = "zz_ssmv01025SlL01T0024TTNATS${datestring}05DP001.dat";

 system("gzip -d $dphname.gz");
 
 $hdrname = "zz_ssmv01025SlL01T0024TTNATS${datestring}05DP001.hdr";
 
 system("cp ~/data/snodas/header_template $hdrname");
 
 system("gdal_translate -of NetCDF -a_srs '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs' -a_nodata -9999 -a_ullr -130.51666666666667 58.23333333333333 -62.25000000000000 24.10000000000000 $dphname blah.nc");
 
 system("ncrename -h -v Band1,solid_precipitation blah.nc");
 system("ncatted -h -a long_name,solid_precipitation,m,c,'liquid-equivalent solid precipitation' blah.nc");
 system("ncatted -h -a units,solid_precipitation,c,c,'mm/day' blah.nc");
 system("ncatted -h -a scale_factor,solid_precipitation,c,f,0.1 blah.nc");
 
 system("ncks -h -A -v solid_precipitation blah.nc $outname");
 system("rm blah.nc");

# Clean up and compress

 system("rm *.dat *.gz *.hdr");
 system("ncks -O -h -4 -L 1 $outname $outname");
   
 }  #dd loop
     
 }  #mm loop
 }  #yyyy loop
 
