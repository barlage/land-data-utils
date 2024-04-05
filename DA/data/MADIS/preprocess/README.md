
`check_missing.perl`: script to check if there are missing hourly files
`create_6hr_madis.perl`: script to combine hourly to six-hourly

Time in filename defines center of window, e.g., 20230411_1800 contains hourly

20230411_1500
20230411_1600
20230411_1700
20230411_1800
20230411_1900
20230411_2000

Manually create two times due to missing hours:

ncrcat -v latitude,longitude,elevation,stationId,observationTime,snowDepthQCR,snowDepth \
 /scratch2/NCEPDEV/land/data/DA/snow_depth/MADIS/hourly/20230411/20230411_1500 \
 /scratch2/NCEPDEV/land/data/DA/snow_depth/MADIS/hourly/20230411/20230411_1600 \
 /scratch2/NCEPDEV/land/data/DA/snow_depth/MADIS/hourly/20230411/20230411_1700 \
 /scratch2/NCEPDEV/land/data/DA/snow_depth/MADIS/hourly/20230411/20230411_1800 \
 /scratch2/NCEPDEV/land/data/DA/snow_depth/MADIS/hourly/20230411/20230411_2000 \
 20230411_1800

ncrcat -v latitude,longitude,elevation,stationId,observationTime,snowDepthQCR,snowDepth \
 /scratch2/NCEPDEV/land/data/DA/snow_depth/MADIS/hourly/20230411/20230411_2200 \
 /scratch2/NCEPDEV/land/data/DA/snow_depth/MADIS/hourly/20230411/20230411_2300 \
 /scratch2/NCEPDEV/land/data/DA/snow_depth/MADIS/hourly/20230412/20230412_0000 \
 /scratch2/NCEPDEV/land/data/DA/snow_depth/MADIS/hourly/20230412/20230412_0100 \
 /scratch2/NCEPDEV/land/data/DA/snow_depth/MADIS/hourly/20230412/20230412_0200 \
 20230412_0000
