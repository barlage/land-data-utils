
#!/usr/bin/perl

$file_in  = "/scratch2/NCEPDEV/land/data/forcing/gefs/weights/C768/GEFS-C768_bilinear_wts.nc";
$file_out = "/scratch2/NCEPDEV/land/data/forcing/gefs/weights/C768/GEFS-C768_land_driver_wts.nc";
$file_elv = "";

if (-e $file_out) { system("rm -Rf $file_out ") }

# extract weights from ESMF file

if ($file_elv eq "") {
  system("ncap2 -h -s 'elevation_difference = 0.f*float(yc_b)' $file_in blah.nc ");
  system("ncks -h -v src_grid_dims,dst_grid_dims,col,row,S,elevation_difference blah.nc $file_out ");
  system("rm blah.nc ");
}else{
  system("ncks -h -v src_grid_dims,dst_grid_dims,col,row,S $file_in $file_out ");
}

# change some variable names and attributes

system("ncrename -h -v S,regrid_weights $file_out ");
system("ncatted -h -a description,regrid_weights,c,c,'ESMF regrid weights' $file_out ");
system("ncrename -h -v col,source_lookup $file_out ");
system("ncatted -h -a description,source_lookup,c,c,'ESMF regrid source vector location' $file_out ");
system("ncrename -h -v row,destination_lookup $file_out ");
system("ncatted -h -a description,destination_lookup,c,c,'ESMF regrid destination vector location' $file_out ");
system("ncatted -h -a description,dst_grid_dims,c,c,'destination vector length' $file_out ");
system("ncatted -h -a description,src_grid_dims,c,c,'source dimensions' $file_out ");

# extract elevation difference from elevation file

if ($file_elv eq "") {
}else{
  system("ncks -h -A -v elevation_difference $file_elv $file_out ");
}

# change some attributes

system("ncatted -h -a description2,elevation_difference,c,c,'destination grid -> vector elevation difference' $file_out ");
system("ncatted -h -a units,elevation_difference,m,c,'meters' $file_out ");
