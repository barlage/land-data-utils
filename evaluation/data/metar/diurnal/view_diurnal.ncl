
; script to plot all climo diurnal cycles for manual inspection for one user-defined month

begin

infile = addfile("/scratch2/NCEPDEV/land/data/evaluation/METAR_SYNOP/dinural/metar_diurnal.nc", "r")
screen = False

mm_to_plot = 5
diurnal_t = infile->t2_monthly_diurnal_climo(:,mm_to_plot,:)

name = "diurnal_test_"+mm_to_plot
if(screen) then
  wks = gsn_open_wks("x11",name) 
else
  wks = gsn_open_wks("pdf",name) 
end if
  
res                   = True
res@xyMarkLineMode    = "Lines"
res@tmLabelAutoStride = True                     ; nice tick mark labels
res@xyLineThicknessF     = 2.0                     ; Marker size (default 0.01)

res@pmLegendDisplayMode    = "Always"            ; turn on legend
res@pmLegendSide           = "Top"               ; Change location of 
res@pmLegendParallelPosF   = .15                  ; move units right
res@pmLegendOrthogonalPosF = -0.45                ; move units down
res@pmLegendWidthF         = 0.20                ; Change width and
res@pmLegendHeightF        = 0.30                ; height of legend.
res@lgPerimOn              = False               ; turn off box around
res@lgLabelFontHeightF     = .02                 ; label font height
res@gsnDraw = False
res@gsnFrame = False
  
res@xyDashPatterns = (/0,0,0,1,1,1,2,2,2,3,3,3,4,4,4/) 
res@xyLineColors = (/"red","blue","black","red","blue","black","red","blue","black","red","blue","black"/)

time = ispan(0,23,1)
station_min = 0
station_max = -1

  do ipage = 0, 19

   plots = new(16,graphic)
  
   do iplot = 0, 15

     station_min = station_max + 1
     station_max = station_max + 12 
     if(station_max .gt. 3821) then 
       station_max = 3821
     end if
     station_numbers = ispan(station_min,station_max,1)

     print("page: "+ipage+" plot: "+iplot+" min: "+station_min+" max: "+station_max)

     if(station_min .le. 3821) then

       diurnal_subset = diurnal_t(station_min:station_max,:)

       res@xyExplicitLegendLabels = station_numbers
       res@tiYAxisString    = ""
   
       plots(iplot)  = gsn_csm_xy(wks,time,diurnal_subset,res) ; create plot

       delete(diurnal_subset)
       delete(station_numbers)
       delete(res@xyExplicitLegendLabels)

     end if

   end do 

   resp = True
   gsn_panel(wks,plots,(/4,4/),resp)

   delete(plots)

  end do

end
