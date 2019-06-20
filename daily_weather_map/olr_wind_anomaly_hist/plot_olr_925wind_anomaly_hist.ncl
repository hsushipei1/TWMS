begin
; hist: mean of: last 3d, last (one) week, past second week, last one month, last three month, last six month (6)
print("%%%% Enter 'plot_olr_925wind_anomaly_hist.ncl' %%%% ")

;;----domain
lon1 = 39 
lon2 = 181
lats = -20
latn = 30
plev = 925 ; unit: hPa

;;----read data
f = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_olr_latest.nc","r")
ntime = dimsizes(f->time)
tend = ntime-16 ; end of "RT", ignore forecast
tstart = tend-35 ; time step of two months ago (start)
totolr = f->olr(tstart:tend,{lats:latn},{lon1:lon2}) ;[ntime]x[nlat]x[nlon]
printVarSummary(totolr)
p1m_d = totolr&time ; last 1 month
p1p_d = p1m_d( dimsizes(p1m_d)-5 :dimsizes(p1m_d)-1 ) ; penta
p2p_d = p1m_d( dimsizes(p1m_d)-10 :dimsizes(p1m_d)-6 )
p3p_d = p1m_d( dimsizes(p1m_d)-15 :dimsizes(p1m_d)-11 )
p4p_d = p1m_d( dimsizes(p1m_d)-20 :dimsizes(p1m_d)-16 )
p5p_d = p1m_d( dimsizes(p1m_d)-25 :dimsizes(p1m_d)-21 )
p6p_d = p1m_d( dimsizes(p1m_d)-30 :dimsizes(p1m_d)-26 ) 

olr_p1pm = dim_avg_n_Wrap( totolr({p1p_d},:,:), 0)
olr_p2pm = dim_avg_n_Wrap( totolr({p2p_d},:,:), 0)
olr_p3pm = dim_avg_n_Wrap( totolr({p3p_d},:,:), 0)
olr_p4pm = dim_avg_n_Wrap( totolr({p4p_d},:,:), 0)
olr_p5pm = dim_avg_n_Wrap( totolr({p5p_d},:,:), 0)
olr_p6pm = dim_avg_n_Wrap( totolr({p6p_d},:,:), 0) 
;printVarSummary( olr_p1pm) 
delete(totolr)

f2 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_u"+plev+"_latest.nc","r")
f3 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_v"+plev+"_latest.nc","r")
u = f2->u925({p1m_d},{lats:latn},{lon1:lon2})
v = f3->v925({p1m_d},{lats:latn},{lon1:lon2})
printVarSummary(u)

u_p1pm = dim_avg_n_Wrap( u({p1p_d},{lats:latn},{lon1:lon2}), 0)  ;[nlat]x[nlon]
u_p2pm = dim_avg_n_Wrap( u({p2p_d},{lats:latn},{lon1:lon2}), 0)
u_p3pm = dim_avg_n_Wrap( u({p3p_d},{lats:latn},{lon1:lon2}), 0)
u_p4pm = dim_avg_n_Wrap( u({p4p_d},{lats:latn},{lon1:lon2}), 0)
u_p5pm = dim_avg_n_Wrap( u({p5p_d},{lats:latn},{lon1:lon2}), 0)
u_p6pm = dim_avg_n_Wrap( u({p6p_d},{lats:latn},{lon1:lon2}), 0)

v_p1pm = dim_avg_n_Wrap( v({p1p_d},{lats:latn},{lon1:lon2}), 0)
v_p2pm = dim_avg_n_Wrap( v({p2p_d},{lats:latn},{lon1:lon2}), 0)
v_p3pm = dim_avg_n_Wrap( v({p3p_d},{lats:latn},{lon1:lon2}), 0)
v_p4pm = dim_avg_n_Wrap( v({p4p_d},{lats:latn},{lon1:lon2}), 0)
v_p5pm = dim_avg_n_Wrap( v({p5p_d},{lats:latn},{lon1:lon2}), 0)
v_p6pm = dim_avg_n_Wrap( v({p6p_d},{lats:latn},{lon1:lon2}), 0) 
;printVarSummary( u_p1pm) 
;printVarSummary( v_p1pm) 

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
res@cnLevelSelectionMode = "explicitlevels"
res@cnLevels = (/-75,-60,-45,-30,-15,-5,5,15,30,45,60,75/)  ; anomaly (WH04)
res@lbLabelFont = 21 ; font for label bar
res@pmLabelBarOrthogonalPosF = 0.13
;res@gsnMaximize = True
res@lbLabelBarOn  = False  ; turn off individual color bar
res@cnLineLabelFontHeightF = 1. ; seems to remove contour labels as individual color bars are removed
;res@gsnStringFont = 0 ; font for gsnright/center/leftstring
res@gsnRightStringFontHeightF = 0.015
res@gsnLeftStringFontHeightF = 0.016

res2 = True
res2@gsnDraw       = False                ; don't draw yet
res2@gsnFrame      = False                ; don't advance frame yet
res2@gsnAddCyclic  = False
;res2@vcMinMagnitudeF      = 0.05    ;  arrow with magnitude under this value will not be drawn.
res2@vcRefLengthF         = 0.025    ;  length of unit reference vector
res2@vcRefMagnitudeF      =  10.    ;  magnitude of the reference vector
res2@vcMinDistanceF       = 0.025    ;  Vector density: distance between arrows
res2@vcLineArrowHeadMinSizeF = 0.0053
res2@vcLineArrowHeadMaxSizeF = 0.0053
res2@vcLineArrowThicknessF = 2.5 ; arrow thickness
res2@vcRefAnnoOrthogonalPosF = 0.2 ; y position of vector reference annotation
res2@vcRefAnnoFont = 21 ; font for vector reference annotation
res2@vcRefAnnoFontHeightF = 0.011 ; font for vector reference annotation
res2@vcRefAnnoString2On = False ; turn off string "Reference vector" in vector ref annotation box
res2@vcRefAnnoOrthogonalPosF = 0.15 ; y coordinate of vector ref annotation box
res2@vcRefAnnoParallelPosF = 0.95 ; x coordinate of vector ref annotation box

; resource for panel 
resP = True
resP@gsnMaximize = True ; maximize plot
resP@gsnPanelLabelBar = True ; adds a common label bar at the bottom of the plot
resP@lbLabelFont = 21 ; font type of labels of common color bar  
resP@lbLabelFontHeightF = 0.012 ; font height of labels of common color bar  
resP@pmLabelBarWidthF = 0.5
resP@pmLabelBarOrthogonalPosF = 0.007 ; y position of label bar
resP@txString = "OLR and 925-hPa Wind Anomaly for the Past" ; add common title
resP@txFontHeightF = 0.015 ; font size for common title
resP@txFont = 22 ; font for common title

txres = True
txres@txFontHeightF = 0.02 ; font height

mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.5

;;----plot
pltdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/olr_wind_anomaly_hist/"
pltn = "olr_fnl025_925wind_anomaly_hist"

wks_type = "pdf"
wks_type@wkPaperWidthF  = 16.666666667  ; in inches
wks_type@wkPaperHeightF = 16.666666667  ; in inches

wks = gsn_open_wks(wks_type, pltdir+pltn)
gsn_define_colormap(wks,"sunshine_diff_12lev")   ; define color map
plot = new(6,graphic) ; create plot array
lines = new(6,graphic)
 
delete(olr_p1pm@long_name)
delete(olr_p1pm@standard_name)
delete(olr_p1pm@units)
delete(u_p1pm@long_name)
delete(u_p1pm@units)
delete(v_p1pm@long_name)
delete(v_p1pm@units)
olr_p1pm@long_name = "5d avg(0)"
res@gsnRightString = p1p_d(0)+"-"+p1p_d( dimsizes(p1p_d)-1 ) ; showing period 
;res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, olr_p1pm, res)
plot2 = gsn_csm_vector(wks,u_p1pm, v_p1pm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(0) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(0) = plot1

delete(olr_p2pm@long_name)
delete(olr_p2pm@standard_name)
delete(olr_p2pm@units)
delete(u_p2pm@long_name)
delete(u_p2pm@units)
delete(v_p2pm@long_name)
delete(v_p2pm@units)
olr_p2pm@long_name = "5d avg(-1)"
res@gsnRightString = p2p_d(0)+"-"+p2p_d( dimsizes(p2p_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, olr_p2pm, res)
plot2 = gsn_csm_vector(wks,u_p2pm, v_p2pm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(1) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(1) = plot1

delete(olr_p3pm@long_name)
delete(olr_p3pm@standard_name)
delete(olr_p3pm@units)
delete(u_p3pm@long_name)
delete(u_p3pm@units)
delete(v_p3pm@long_name)
delete(v_p3pm@units)
olr_p3pm@long_name = "5d avg(-2)"
res@gsnRightString = p3p_d(0)+"-"+p3p_d( dimsizes(p3p_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, olr_p3pm, res)
plot2 = gsn_csm_vector(wks,u_p3pm, v_p3pm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(2) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(2) = plot1
;
;delete(olr_p1mm@long_name)
;delete(olr_p1mm@standard_name)
;delete(olr_p1mm@units)
;delete(u_p1mm@long_name)
;delete(u_p1mm@units)
;delete(v_p1mm@long_name)
;delete(v_p1mm@units)
;olr_p1mm@long_name = "Last 1 month"
;res@gsnRightString = p1m_d(0)+"-"+p1m_d( dimsizes(p1m_d)-1 ) ; showing period 
;res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
;plot1 = gsn_csm_contour_map_ce(wks, olr_p1mm, res)
;plot2 = gsn_csm_vector(wks,u_p1mm, v_p1mm, res2) ; vector, for smaller plot domain 
;overlay(plot1, plot2)
;lines(3) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
;plot(3) = plot1
;
;delete(olr_p3mm@long_name)
;delete(olr_p3mm@standard_name)
;delete(olr_p3mm@units)
;delete(u_p3mm@long_name)
;delete(u_p3mm@units)
;delete(v_p3mm@long_name)
;delete(v_p3mm@units)
;olr_p3mm@long_name = "Last 3 month"
;res@gsnRightString = p3m_d(0)+"-"+p3m_d( dimsizes(p3m_d)-1 ) ; showing period 
;res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
;plot1 = gsn_csm_contour_map_ce(wks, olr_p3mm, res)
;plot2 = gsn_csm_vector(wks,u_p3mm, v_p3mm, res2) ; vector, for smaller plot domain 
;overlay(plot1, plot2)
;lines(4) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
;plot(4) = plot1
;
;delete(olr_p6mm@long_name)
;delete(olr_p6mm@standard_name)
;delete(olr_p6mm@units)
;delete(u_p6mm@long_name)
;delete(u_p6mm@units)
;delete(v_p6mm@long_name)
;delete(v_p6mm@units)
;olr_p6mm@long_name = "Last 6 month"
;res@gsnRightString = p6m_d(0)+"-"+p6m_d( dimsizes(p6m_d)-1 ) ; showing period 
;res2@vcRefAnnoOn = True ; turn off individual vector ref annotation box, only turn on for the last plot
;plot1 = gsn_csm_contour_map_ce(wks, olr_p6mm, res)
;plot2 = gsn_csm_vector(wks,u_p6mm, v_p6mm, res2) ; vector, for smaller plot domain 
;overlay(plot1, plot2)
;lines(5) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
;plot(5) = plot1
;
;gsn_panel(wks,(/plot(0),plot(1),plot(2),plot(3),plot(4),plot(5)/),(/3,2/),resP)
gsn_panel(wks,(/plot(2),plot(1),plot(0)/),(/3,1/),resP)

print("Plot created-> "+pltn)
print("%%%% Leave 'plot_olr_925wind_anomaly_hist.ncl' %%%% ")

end
