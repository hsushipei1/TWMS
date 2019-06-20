begin
; hist: mean of: last 3d, last (one) week, past second week, last one month, last three month, last six month (6)
print("%%%% Enter 'plot_pw_925wind_hist.ncl' %%%% ")

;;----domain
lon1 = 39 
lon2 = 181
lats = -20
latn = 30
plev = 925 ; unit: hPa

;;----read data
f = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_pw_latest.nc","r")
ntime = dimsizes(f->time)
tend = ntime-1 ; latest pw time step (end)
tstart = tend-183 ; time step of two months ago (start)
totpw = f->pw(tstart:tend,{lats:latn},{lon1:lon2}) ;[ntime]x[nlat]x[nlon]
p6m_d = totpw&time ; last 6 month
p3d_d = p6m_d( dimsizes(p6m_d)-3 :dimsizes(p6m_d)-1 ) ; last 3d
p1w_d = p6m_d( dimsizes(p6m_d)-7 :dimsizes(p6m_d)-1 ) ; last first week
p2w_d = p6m_d( dimsizes(p6m_d)-14 :dimsizes(p6m_d)-8 ) ; last second week
p1m_d = p6m_d( dimsizes(p6m_d)-30 :dimsizes(p6m_d)-1 ) ; last 30d (one month)
p3m_d = p6m_d( dimsizes(p6m_d)-91 :dimsizes(p6m_d)-1 ) ; last three month

pw_p3dm = dim_avg_n_Wrap( totpw({p3d_d},:,:), 0) 
pw_p1wm = dim_avg_n_Wrap( totpw({p1w_d},:,:), 0)
pw_p2wm = dim_avg_n_Wrap( totpw({p2w_d},:,:), 0)
pw_p1mm = dim_avg_n_Wrap( totpw({p1m_d},:,:), 0)
pw_p3mm = dim_avg_n_Wrap( totpw({p3m_d},:,:), 0)
pw_p6mm = dim_avg_n_Wrap( totpw({p6m_d},:,:), 0)
printVarSummary( pw_p1mm) 
delete(totpw)

f = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_u"+plev+"_latest.nc","r")
f2 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_v"+plev+"_latest.nc","r")

u_p3dm = dim_avg_n_Wrap( f->u925({p3d_d},{lats:latn},{lon1:lon2}), 0)  ;[nlat]x[nlon]
u_p1wm = dim_avg_n_Wrap( f->u925({p1w_d},{lats:latn},{lon1:lon2}), 0) 
u_p2wm = dim_avg_n_Wrap( f->u925({p2w_d},{lats:latn},{lon1:lon2}), 0) 
u_p1mm = dim_avg_n_Wrap( f->u925({p1m_d},{lats:latn},{lon1:lon2}), 0) 
u_p3mm = dim_avg_n_Wrap( f->u925({p3m_d},{lats:latn},{lon1:lon2}), 0) 
u_p6mm = dim_avg_n_Wrap( f->u925({p6m_d},{lats:latn},{lon1:lon2}), 0) 

v_p3dm = dim_avg_n_Wrap( f2->v925({p3d_d},{lats:latn},{lon1:lon2}), 0) 
v_p1wm = dim_avg_n_Wrap( f2->v925({p1w_d},{lats:latn},{lon1:lon2}), 0) 
v_p2wm = dim_avg_n_Wrap( f2->v925({p2w_d},{lats:latn},{lon1:lon2}), 0) 
v_p1mm = dim_avg_n_Wrap( f2->v925({p1m_d},{lats:latn},{lon1:lon2}), 0) 
v_p3mm = dim_avg_n_Wrap( f2->v925({p3m_d},{lats:latn},{lon1:lon2}), 0) 
v_p6mm = dim_avg_n_Wrap( f2->v925({p6m_d},{lats:latn},{lon1:lon2}), 0) 
printVarSummary( u_p1mm) 
printVarSummary( v_p1mm) 

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
res@tmXBLabelFont = 0
res@tmXBLabelFontHeightF = 0.013
res@tmYLLabelFont = 0
res@tmYLLabelFontHeightF = 0.013
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
res@cnLevelSelectionMode = "explicitlevels"
res@cnLevels = (/-20, -17, -14, -11, -8,-5, -2,2,5,8,11,14,17,20/)  ; anomaly (WH04)
res@lbLabelFont = 0 ; font for label bar
res@pmLabelBarOrthogonalPosF = 0.1 ;  color bar y position
;res@gsnMaximize = True
res@lbLabelBarOn  = False  ; turn off individual color bar
res@cnLineLabelFontHeightF = 1. ; seems to remove contour labels as individual color bars are removed
;res@gsnStringFont = 0 ; font for gsnright/center/leftstring
res@gsnRightStringFontHeightF = 0.015

; reverse color map
cmap = read_colormap_file("GMT_polar")
res@cnFillPalette =   cmap(::-1,:)

res2 = True
res2@gsnDraw       = False                ; don't draw yet
res2@gsnFrame      = False                ; don't advance frame yet
res2@gsnAddCyclic  = False
;res2@vcMinMagnitudeF      = 0.05    ;  arrow with magnitude under this value will not be drawn.
res2@vcRefLengthF         = 0.02    ;  length of unit reference vector
res2@vcRefMagnitudeF      =  15.    ;  magnitude of the reference vector
res2@vcMinDistanceF       = 0.015    ;  Vector density: distance between arrows
res2@vcLineArrowHeadMinSizeF = 0.003
res2@vcLineArrowHeadMaxSizeF = 0.003
res2@vcRefAnnoOrthogonalPosF = 0.2 ; y position of vector reference annotation
res2@vcRefAnnoFont = 0 ; font for vector reference annotation
res2@vcRefAnnoString2On = False ; turn off string "Reference vector" in vector ref annotation box
res2@vcRefAnnoOrthogonalPosF = 0.2 ; y coordinate of vector ref annotation box
res2@vcRefAnnoParallelPosF = 0.95 ; x coordinate of vector ref annotation box

; resource for panel 
resP = True
resP@gsnMaximize = True ; maximize plot
resP@gsnPanelLabelBar = True ; adds a common label bar at the bottom of the plot
resP@lbLabelFont = 0 ; font type of labels of common color bar  
resP@lbLabelFontHeightF = 0.005 ; font height of labels of common color bar  
resP@pmLabelBarOrthogonalPosF = 0.04 ; y position of label bar
resP@txString = "PW and 925-hPa Wind Anomaly for the Past" ; add common title
resP@txFontHeightF = 0.012 ; font size for common title
resP@txFont = 13 ; font for common title


txres = True
txres@txFontHeightF = 0.02 ; font height

mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.5

;;----plot
pltdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/pw_wind_anomaly_hist/"
pltn = "pw_fnl025_925wind_anomaly_hist"
wks = gsn_open_wks("pdf", pltdir+pltn)
;gsn_define_colormap(wks,"GMT_polar")   ; define color map
plot = new(6,graphic) ; create plot array
lines = new(6,graphic)
 
delete(pw_p3dm@long_name)
delete(pw_p3dm@standard_name)
delete(pw_p3dm@units)
delete(u_p3dm@long_name)
delete(u_p3dm@units)
delete(v_p3dm@long_name)
delete(v_p3dm@units)
pw_p3dm@long_name = "Past 3d"
res@gsnRightString = p3d_d(0)+"-"+p3d_d( dimsizes(p3d_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, pw_p3dm, res)
plot2 = gsn_csm_vector(wks,u_p3dm, v_p3dm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(0) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(0) = plot1

delete(pw_p1wm@long_name)
delete(pw_p1wm@standard_name)
delete(pw_p1wm@units)
delete(u_p1wm@long_name)
delete(u_p1wm@units)
delete(v_p1wm@long_name)
delete(v_p1wm@units)
pw_p1wm@long_name = "Last one week"
res@gsnRightString = p1w_d(0)+"-"+p1w_d( dimsizes(p1w_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, pw_p1wm, res)
plot2 = gsn_csm_vector(wks,u_p1wm, v_p1wm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(1) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(1) = plot1

delete(pw_p2wm@long_name)
delete(pw_p2wm@standard_name)
delete(pw_p2wm@units)
delete(u_p2wm@long_name)
delete(u_p2wm@units)
delete(v_p2wm@long_name)
delete(v_p2wm@units)
pw_p2wm@long_name = "Last second week"
res@gsnRightString = p2w_d(0)+"-"+p2w_d( dimsizes(p2w_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, pw_p2wm, res)
plot2 = gsn_csm_vector(wks,u_p2wm, v_p2wm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(2) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(2) = plot1

delete(pw_p1mm@long_name)
delete(pw_p1mm@standard_name)
delete(pw_p1mm@units)
delete(u_p1mm@long_name)
delete(u_p1mm@units)
delete(v_p1mm@long_name)
delete(v_p1mm@units)
pw_p1mm@long_name = "Last 1 month"
res@gsnRightString = p1m_d(0)+"-"+p1m_d( dimsizes(p1m_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, pw_p1mm, res)
plot2 = gsn_csm_vector(wks,u_p1mm, v_p1mm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(3) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(3) = plot1

delete(pw_p3mm@long_name)
delete(pw_p3mm@standard_name)
delete(pw_p3mm@units)
delete(u_p3mm@long_name)
delete(u_p3mm@units)
delete(v_p3mm@long_name)
delete(v_p3mm@units)
pw_p3mm@long_name = "Last 3 month"
res@gsnRightString = p3m_d(0)+"-"+p3m_d( dimsizes(p3m_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, pw_p3mm, res)
plot2 = gsn_csm_vector(wks,u_p3mm, v_p3mm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(4) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(4) = plot1

delete(pw_p6mm@long_name)
delete(pw_p6mm@standard_name)
delete(pw_p6mm@units)
delete(u_p6mm@long_name)
delete(u_p6mm@units)
delete(v_p6mm@long_name)
delete(v_p6mm@units)
pw_p6mm@long_name = "Last 6 month"
res@gsnRightString = p6m_d(0)+"-"+p6m_d( dimsizes(p6m_d)-1 ) ; showing period 
res2@vcRefAnnoOn = True ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, pw_p6mm, res)
plot2 = gsn_csm_vector(wks,u_p6mm, v_p6mm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(5) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(5) = plot1

gsn_panel(wks,(/plot(0),plot(1),plot(2),plot(3),plot(4),plot(5)/),(/3,2/),resP)

print("Plot created-> "+pltn)
print("%%%% Leave 'plot_pw_925wind_hist.ncl' %%%% ")

end
