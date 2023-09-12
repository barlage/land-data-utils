
; the script creates 
;    - monthly mean diurnal cycles at metar/synop locations for each month 2010 - 2022
;         - sites are filtered by user-defined data availability
;    - climatological monthly mean diurnal cycles for each month 2013 - 2022
;         - including the number of years that went into the climatology
;    - after visual inspection of the climatological cycles, several are manually removed

begin

missing_threshold = 0.9
yyyy_beg = 2010
yyyy_end = 2022
nyear = yyyy_end - yyyy_beg + 1
years = new(nyear, integer)
years!0 = "year"

; manually remove some stations after visual inspection

bad_stations = (/  0,  120,  152,  259,  276,  392,  433,  436,  478,  530, \  ; first three rows (28), strange cycles for July
                 638,  729,  776,  787,  812,  913, 1144, 1384, 1490, 1638, \
                1684, 2063, 3503, 3553, 3658, 3678, 3731, 3802,             \
                1899, 2811, 3151,                                           \  ; these three look like time is shifted or very cold
                 342,  834,  844, 1066, 1283, 1418, 1550, 1641, 1715, 1880, \  ; 10 removed from January analysis
                 498, 1198, 1709, 3098, 3550,                               \  ; 5 removed from February analysis
                1363                                                       /)  ; 1 removed from December analysis

do yyyy = yyyy_beg, yyyy_end

  infile = addfile("/scratch2/NCEPDEV/land/data/evaluation/METAR_SYNOP/METAR_SYNOP_"+yyyy+".nc", "r")

  iyyyy = yyyy-yyyy_beg
  years(iyyyy) = yyyy

  if(iyyyy .eq. 0) then
    dsizes = getfiledimsizes(infile)
    nstations = dsizes(1)

    latitude = infile->latitude
    longitude = infile->longitude

    t2_monthly_diurnal = new((/nstations,nyear,12,24/),float)
     t2_monthly_diurnal!0 = "stations"
     t2_monthly_diurnal!1 = "year"
     t2_monthly_diurnal!2 = "month"
     t2_monthly_diurnal!3 = "hour"
     t2_monthly_diurnal@long_name = "temperature 2m monthly mean diurnal cycle"
    t2_monthly_diurnal_climo = new((/nstations,12,24/),float)
     t2_monthly_diurnal_climo!0 = "stations"
     t2_monthly_diurnal_climo!1 = "month"
     t2_monthly_diurnal_climo!2 = "hour"
     t2_monthly_diurnal_climo@long_name = "temperature 2m monthly mean diurnal cycle climatology (2013-2022)"
    t2_climo_count = new((/nstations,12/),float)
     t2_climo_count!0 = "stations"
     t2_climo_count!1 = "month"
     t2_climo_count@long_name = "number of years in climatology (10 max); sum(not missing hours)/24"
    td2_monthly_diurnal = new((/nstations,nyear,12,24/),float)
     td2_monthly_diurnal!0 = "stations"
     td2_monthly_diurnal!1 = "year"
     td2_monthly_diurnal!2 = "month"
     td2_monthly_diurnal!3 = "hour"
     td2_monthly_diurnal@long_name = "dewpoint 2m monthly mean diurnal cycle"
    td2_monthly_diurnal_climo = new((/nstations,12,24/),float)
     td2_monthly_diurnal_climo!0 = "stations"
     td2_monthly_diurnal_climo!1 = "month"
     td2_monthly_diurnal_climo!2 = "hour"
     td2_monthly_diurnal_climo@long_name = "dewpoint 2m monthly mean diurnal cycle climatology (2013-2022)"
    td2_climo_count = new((/nstations,12/),float)
     td2_climo_count!0 = "stations"
     td2_climo_count!1 = "month"
     td2_climo_count@long_name = "number of years in climatology (10 max); sum(not missing hours)/24"

    good_flag_t = new(nstations,logical)
    good_flag_td = new(nstations,logical)

  end if

  infile_time = infile->time

  time_beg = 0
  time_end = -1

do imm = 1, 12

  hrs_in_month = days_in_month(yyyy,imm) * 24
  time_beg = time_end + 1
  time_end = time_end + hrs_in_month

  print("month: "+imm+" beg: "+time_beg+" end: "+time_end)

  indata_t2 = infile->temperature_2m(:,time_beg:time_end)
  indata_td2 = infile->dewpoint_2m(:,time_beg:time_end)

  good_flag_t = False
  good_flag_td = False

  do istation = 0, nstations - 1

    do ibad = 0, dimsizes(bad_stations) - 1
      if(istation .eq. bad_stations(ibad)) then
        indata_t2(istation,:) = indata_t2@_FillValue
        indata_td2(istation,:) = indata_td2@_FillValue
      end if
    end do

    num_good = num(.not.ismissing(indata_t2(istation,:)))

    if(num_good .gt. missing_threshold*hrs_in_month) then
      good_flag_t(istation) = True
      do ihh = 0, 23
        if(num(.not.ismissing(indata_t2(istation,ihh::24))) .gt. 0) then
          t2_monthly_diurnal(istation,iyyyy,imm-1,ihh) = (/ avg(indata_t2(istation,ihh::24)) /)
        end if
      end do
    end if

    num_good = num(.not.ismissing(indata_td2(istation,:)))

    if(num_good .gt. missing_threshold*hrs_in_month) then
      good_flag_td(istation) = True
      do ihh = 0, 23
        if(num(.not.ismissing(indata_td2(istation,ihh::24))) .gt. 0) then
          td2_monthly_diurnal(istation,iyyyy,imm-1,ihh) = (/ avg(indata_td2(istation,ihh::24)) /)
        end if
      end do
    end if

  end do

  print("num good T2 during month: "+num(good_flag_t))
  print("num good Td2 during month: "+num(good_flag_td))

  delete(indata_t2)
  delete(indata_td2)

end do

  delete(infile_time)

end do      

t2_climo_count = 0
td2_climo_count = 0

do imm = 1, 12

  do istation = 0, nstations - 1

    do ihh = 0, 23
      if(num(.not.ismissing(t2_monthly_diurnal(istation,3:12,imm-1,ihh))) .gt. 0) then
        t2_monthly_diurnal_climo(istation,imm-1,ihh) = (/ avg(t2_monthly_diurnal(istation,:,imm-1,ihh)) /)
        t2_climo_count(istation,imm-1) = t2_climo_count(istation,imm-1) + num(.not.ismissing(t2_monthly_diurnal(istation,3:12,imm-1,ihh)))
      end if
    end do

    do ihh = 0, 23
      if(num(.not.ismissing(td2_monthly_diurnal(istation,3:12,imm-1,ihh))) .gt. 0) then
        td2_monthly_diurnal_climo(istation,imm-1,ihh) = (/ avg(td2_monthly_diurnal(istation,:,imm-1,ihh)) /)
        td2_climo_count(istation,imm-1) = td2_climo_count(istation,imm-1) + num(.not.ismissing(td2_monthly_diurnal(istation,3:12,imm-1,ihh)))
      end if
    end do

  end do

end do

 t2_climo_count =  t2_climo_count / 24.0
td2_climo_count = td2_climo_count / 24.0

outname = "/scratch2/NCEPDEV/land/data/evaluation/METAR_SYNOP/dinural/metar_diurnal.nc"
  system("if [ -e "+outname+" ]; then rm -f "+outname+ ";fi")
  outfile = addfile(outname,"c")

outfile->years                     = years
outfile->latitude                  = latitude
outfile->longitude                 = longitude
outfile->t2_monthly_diurnal        = t2_monthly_diurnal
outfile->t2_monthly_diurnal_climo  = t2_monthly_diurnal_climo
outfile->t2_climo_count            = t2_climo_count
outfile->td2_monthly_diurnal       = td2_monthly_diurnal
outfile->td2_monthly_diurnal_climo = td2_monthly_diurnal_climo
outfile->td2_climo_count           = td2_climo_count
  
end


