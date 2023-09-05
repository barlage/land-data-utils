
METAR/SYNOP observations retrieved from /glade/collections/rda/data/ds461.0

Observations extracted

    lat, lon, name, time, ps, elevation, t2, td2, wspd, wdir

Lat/Lon Range: 20N to 70N, -170E to -60E

Hourly data for 2010 - 2022, stored in annual files

Data location: /scratch2/NCEPDEV/land/data/evaluation/METAR_SYNOP

The data files (METAR_SYNOP_2010.nc) contain all the hourly data for the year at any station observing at least once in the full time range

Observation at nearest hour is saved

Observations are reorganized so that stations are in the same order in each file, generally from north to south

====================

/scratch2/NCEPDEV/land/data/evaluation/METAR_SYNOP/map_metar_master_reorder.nc

contains lat and lon of each station in the order in the data files
also contains the number of months that have at least one obs from the station

====================

Additional tools:

lookup/grid_lookup.ncl

find the location in output grid for several configurations:
	C96 vector
	C96_conus vector
	P8 gaussian grid
	HR gaussian grid

/scratch2/NCEPDEV/land/data/evaluation/METAR_SYNOP/metar_allgrids_lookup.nc
