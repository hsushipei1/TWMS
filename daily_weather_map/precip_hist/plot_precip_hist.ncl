begin
; hist: mean of: last 3d, last (one) week, past second week, last one month, last three month, last six month (6)
print("%%%% Enter 'plot_precip_hist.ncl' %%%% ")

;;----domain
lon1 = 39 
lon2 = 181
lats = -20
latn = 30
totd = 30 ; total days for the longest period

;;----read data
fils = systemfunc ("ls /data5/hsushipei/data/total_field/Precip/GPM/realtime/3B-DAY-E.MS.MRG.3IMERG.*-S000000-E235959.V0*.nc4")
fils_li = fils( dimsizes(fils)-totd:dimsizes(fils)-1 ) 
dates_arr = str_split_by_length( fils_li, (/77, 8, 24/) )
dates = dates_arr( :,1 ) ; yyyymmdd
f = addfiles (fils_li, "r")
ListSetType(f, "cat") ; For IMERG V6, the coordinate of Precip in single file is time x lon lat, so use "cat" here.
pcp = f[:]->precipitationCal(:,{lon1:lon2},{lats:latn}) ; time(unit: relative) x lon x lat 
;printVarSummary(pcp)

;;  ;;  ; define time coordinate
;;  ft = addfile("/data5/hsushipei/data/total_field/U/ei075_uprs_1979_2015_daily_clim.nc","r")
;;  timeb = ft->time(0) ; borrow attribute from another file
;;  time = new( totd, typeof(timeb) )
;;  time = todouble( dates )
;;  copy_VarAtts( timeb, time )
;;  delete(time@_FillValue)
;;  ;printVarSummary(time)
;;  
;;  pcp!0 = "time"
;;  pcp&time = time
;;  ;pcp=pcp/24. ; accumulated rainfall to daily rain rate
printVarSummary(pcp) ; time x lon x lat
;print(pcp(:,10,20))

;;---- Choose period for various plots
p1m_d = pcp&time
p1p_d = p1m_d( dimsizes(p1m_d)- 5:dimsizes(p1m_d)- 1 ) 
p2p_d = p1m_d( dimsizes(p1m_d)-10:dimsizes(p1m_d)- 6 ) 
p3p_d = p1m_d( dimsizes(p1m_d)-15:dimsizes(p1m_d)-11 )
p4p_d = p1m_d( dimsizes(p1m_d)-20:dimsizes(p1m_d)-16 )
p5p_d = p1m_d( dimsizes(p1m_d)-25:dimsizes(p1m_d)-21 )
p6p_d = p1m_d( dimsizes(p1m_d)-30:dimsizes(p1m_d)-26 )

pcp_p1pm = dim_avg_n_Wrap( pcp({p1p_d},:,:), 0) 
pcp_p2pm = dim_avg_n_Wrap( pcp({p2p_d},:,:), 0)
pcp_p3pm = dim_avg_n_Wrap( pcp({p3p_d},:,:), 0)
pcp_p4pm = dim_avg_n_Wrap( pcp({p4p_d},:,:), 0)
pcp_p5pm = dim_avg_n_Wrap( pcp({p5p_d},:,:), 0)
pcp_p6pm = dim_avg_n_Wrap( pcp({p6p_d},:,:), 0)
printVarSummary( pcp_p1pm) 
delete(pcp)

;;----resource
res=True
res@gsnDraw      = False                ; don't draw yet
res@gsnFrame     = False                ; don't advance frame yet
res@mpMinLatF    = lats       ; Set the domain of map (not the domain
res@mpMaxLatF    = latn       ; of data). If the data's domain is
res@mpMinLonF    = lon1       ; smaller than the map's, you'll see
res@mpMaxLonF    = lon2       ; blank(white) area on plot (missing).
res@mpCenterLonF = (lon1+lon2)/2 ; Center lon of this plot.
res@gsnAddCyclic = False ; if the map domain isn't global
res@tmXBTickSpacingF = 20
res@tmYLTickSpacingF = 10
res@tmXBLabelFont = 21
res@tmXBLabelFontHeightF = 0.015
res@tmYLLabelFont = 21
res@tmYLLabelFontHeightF = 0.015
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = (/ 5, 10, 30, 60, 100, 150, 200/)
;res@cnMinLevelValF = 0.1
;res@cnMaxLevelValF = 1.7
;res@cnLevelSpacingF = 0.2
res@lbLabelFont = 21 ; font for label bar
res@pmLabelBarOrthogonalPosF = -0.01 ;  color bar y position
;res@gsnMaximize = True
res@lbLabelBarOn  = False  ; turn off individual color bar
res@cnLineLabelFontHeightF = 1. ; seems to remove contour labels as individual color bars are removed
;res@gsnStringFont = 0 ; font for gsnright/center/leftstring
res@gsnRightStringFontHeightF = 0.015
res@gsnLeftStringFontHeightF = 0.016

res@cnFillMode = "RasterFill"

; resource for panel 
resP = True
resP@gsnMaximize = True ; maximize plot
resP@gsnPanelLabelBar = True ; adds a common label bar at the bottom of the plot
resP@lbLabelFont = 21 ; font type of labels of common color bar  
resP@lbLabelFontHeightF = 0.012 ;; font height of labels of common color bar  
resP@pmLabelBarWidthF = 0.5
resP@pmLabelBarOrthogonalPosF = 0.0055 ; y position of label bar
resP@txString = "GPM IMERG Rainfall(mm) for the Past" ; add common title
resP@txFontHeightF = 0.015 ; font size for common title
resP@txFont = 22 ; font for common title

txres = True
txres@txFontHeightF = 0.02 ; font height

mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.5

;;----plot
pltdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/precip_hist/"
pltn = "GPM_precip_hist"

wks_type = "pdf"
wks_type@wkPaperWidthF  = 16.666666667  ; in inches
wks_type@wkPaperHeightF = 16.666666667  ; in inches

wks = gsn_open_wks(wks_type, pltdir+pltn)
gsn_define_colormap(wks,"precip2_17lev")   ; define color map
plot = new(6,graphic) ; create plot array
lines = new(6,graphic)
 
delete(pcp_p1pm@long_name)
delete(pcp_p1pm@standard_name)
delete(pcp_p1pm@units)
pcp_p1pm@long_name = "5d avg(0)"
res@gsnRightString = p1p_d(0)+"-"+p1p_d( dimsizes(p1p_d)-1 ) ; showing period
plot1 = gsn_csm_contour_map_ce(wks, pcp_p1pm(lat|:, lon|:), res)
lines(0) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(0) = plot1

delete(pcp_p2pm@long_name)
delete(pcp_p2pm@standard_name)
delete(pcp_p2pm@units)
pcp_p2pm@long_name = "5d avg(-1)"
res@gsnRightString = p2p_d(0)+"-"+p2p_d( dimsizes(p2p_d)-1 ) ; showing period 
plot1 = gsn_csm_contour_map_ce(wks, pcp_p2pm(lat|:, lon|:), res)
lines(1) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(1) = plot1

delete(pcp_p3pm@long_name)
delete(pcp_p3pm@standard_name)
delete(pcp_p3pm@units)
pcp_p3pm@long_name = "5d avg(-2)"
res@gsnRightString = p3p_d(0)+"-"+p3p_d( dimsizes(p3p_d)-1 ) ; showing period 
plot1 = gsn_csm_contour_map_ce(wks, pcp_p3pm(lat|:, lon|:), res)
lines(2) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(2) = plot1

delete(pcp_p4pm@long_name)
delete(pcp_p4pm@standard_name)
delete(pcp_p4pm@units)
pcp_p4pm@long_name = "5d avg(-3)"
res@gsnRightString = p4p_d(0)+"-"+p4p_d( dimsizes(p4p_d)-1 ) ; showing period 
plot1 = gsn_csm_contour_map_ce(wks, pcp_p4pm(lat|:, lon|:), res)
lines(3) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(3) = plot1

delete(pcp_p5pm@long_name)
delete(pcp_p5pm@standard_name)
delete(pcp_p5pm@units)
pcp_p5pm@long_name = "Last 5 pentad"
res@gsnRightString = p5p_d(0)+"-"+p5p_d( dimsizes(p5p_d)-1 ) ; showing period 
plot1 = gsn_csm_contour_map_ce(wks, pcp_p5pm(lat|:, lon|:), res)
lines(4) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(4) = plot1

delete(pcp_p6pm@long_name)
delete(pcp_p6pm@standard_name)
delete(pcp_p6pm@units)
pcp_p6pm@long_name = "Last 6 pentad"
res@gsnRightString = p6p_d(0)+"-"+p6p_d( dimsizes(p6p_d)-1 ) ; showing period 
plot1 = gsn_csm_contour_map_ce(wks, pcp_p6pm(lat|:, lon|:), res)
lines(5) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(5) = plot1

;gsn_panel(wks,(/plot(0),plot(1),plot(2),plot(3),plot(4),plot(5)/),(/3,2/),resP)
;gsn_text_ndc(wks,"Daily accumulated rainfall (mm)",0.5,0.3,txres)
gsn_panel(wks,(/plot(2), plot(1), plot(0)/),(/3,1/),resP)

print("Plot created-> "+pltn)
print("%%%% Leave 'plot_precip_hist.ncl' %%%% ")

end
