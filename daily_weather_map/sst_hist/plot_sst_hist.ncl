begin

lon1 = 39   ; WNP
lon2 = 181
lats = -20
latn = 30

;; read data
; Real time data 
fils = systemfunc ("ls /data5/hsushipei/data/total_field/SST/noaa_oisst_v2/sst.day.mean.*.v2.nc")
f = addfiles (fils( dimsizes(fils)-2:dimsizes(fils)-1 ) , "r")
ListSetType (f, "cat")
totntime = dimsizes( f[:]->time ) 
rel_t = f[:]->time( totntime-36: )
ntime = dimsizes( rel_t )

; convert relative to absolute time 
abs_t = cd_calendar(rel_t, 2) 
sst = f[:]->sst(  totntime-36: ,{lats:latn},{lon1:lon2}) ; t x lat x lon
sst&time = tointeger( abs_t ) 
printVarSummary(sst)

;;---- calculate each penta
p1p_d = abs_t( ntime-5:ntime-1 )
p2p_d = abs_t( ntime-10:ntime-6 )
p3p_d = abs_t( ntime-15:ntime-11 )
p4p_d = abs_t( ntime-20:ntime-16 )
p5p_d = abs_t( ntime-25:ntime-21 )
p6p_d = abs_t( ntime-30:ntime-26 )
;print(p1p_d)
;print(p2p_d)

p1pm =  dim_avg_n_Wrap( sst( {p1p_d},:,: ), 0 )
p2pm =  dim_avg_n_Wrap( sst( {p2p_d},:,: ), 0 )
p3pm =  dim_avg_n_Wrap( sst( {p3p_d},:,: ), 0 )
p4pm =  dim_avg_n_Wrap( sst( {p4p_d},:,: ), 0 )
p5pm =  dim_avg_n_Wrap( sst( {p5p_d},:,: ), 0 )
p6pm =  dim_avg_n_Wrap( sst( {p6p_d},:,: ), 0 )
printVarSummary(p1pm)

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
res@cnLevels = (/21, 23, 25, 27,  28,28.5,  29,29.5, 30 /)
res@lbLabelFont = 21 ; font for label bar
;res@pmLabelBarOrthogonalPosF = 0.4 ;  color bar y position
;res@gsnMaximize = True
res@lbLabelBarOn  = False  ; turn off individual color bar
res@cnLineLabelFontHeightF = 1. ; seems to remove contour labels as individual color bars are removed
;res@gsnStringFont = 0 ; font for gsnright/center/leftstring
res@gsnRightStringFontHeightF = 0.015
res@gsnLeftStringFontHeightF = 0.016

; resource for panel 
resP = True
resP@gsnMaximize = True ; maximize plot
resP@gsnPanelLabelBar = True ; adds a common label bar at the bottom of the plot
resP@lbLabelFont = 21 ; font type of labels of common color bar  
resP@lbLabelFontHeightF = 0.012 ; font height of labels of common color bar  
resP@pmLabelBarWidthF = 0.5
resP@pmLabelBarOrthogonalPosF = 0.0055 ; y position of label bar
resP@txString = "OISST for the Past" ; add common title
resP@txFontHeightF = 0.015 ; font size for common title
resP@txFont = 22 ; font for common title

txres = True
txres@txFontHeightF = 0.02 ; font height

mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.5

;;----plot
pltdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/sst_hist/"
pltn = "oisst_hist"

wks_type = "pdf"
wks_type@wkPaperWidthF  = 16.666666667  ; in inches
wks_type@wkPaperHeightF = 16.666666667  ; in inches

wks = gsn_open_wks(wks_type, pltdir+pltn)
gsn_define_colormap(wks,"precip2_17lev")   ; define color map
plot = new(6,graphic) ; create plot array
lines = new(6,graphic)
 
delete(p1pm@long_name)
delete(p1pm@standard_name)
delete(p1pm@units)
p1pm@long_name = "5d avg(0)"
res@gsnRightString = p1p_d(0)+"-"+p1p_d( dimsizes(p1p_d)-1 ) ; showing period
plot1 = gsn_csm_contour_map_ce(wks, p1pm, res)
lines(0) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(0) = plot1

delete(p2pm@long_name)
delete(p2pm@standard_name)
delete(p2pm@units)
p2pm@long_name = "5d avg(-1)"
res@gsnRightString = p2p_d(0)+"-"+p2p_d( dimsizes(p2p_d)-1 ) ; showing period
plot1 = gsn_csm_contour_map_ce(wks, p2pm, res)
lines(1) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(1) = plot1

delete(p3pm@long_name)
delete(p3pm@standard_name)
delete(p3pm@units)
p3pm@long_name = "5d avg(-2)"
res@gsnRightString = p3p_d(0)+"-"+p3p_d( dimsizes(p3p_d)-1 ) ; showing period
plot1 = gsn_csm_contour_map_ce(wks, p3pm, res)
lines(2) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(2) = plot1

delete(p4pm@long_name)
delete(p4pm@standard_name)
delete(p4pm@units)
p4pm@long_name = "Last 4 pentad"
res@gsnRightString = p4p_d(0)+"-"+p4p_d( dimsizes(p4p_d)-1 ) ; showing period
plot1 = gsn_csm_contour_map_ce(wks, p4pm, res)
lines(3) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(3) = plot1

delete(p5pm@long_name)
delete(p5pm@standard_name)
delete(p5pm@units)
p5pm@long_name = "Last 5 pentad"
res@gsnRightString = p5p_d(0)+"-"+p5p_d( dimsizes(p5p_d)-1 ) ; showing period
plot1 = gsn_csm_contour_map_ce(wks, p5pm, res)
lines(4) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(4) = plot1

delete(p6pm@long_name)
delete(p6pm@standard_name)
delete(p6pm@units)
p6pm@long_name = "Last 6 pentad"
res@gsnRightString = p6p_d(0)+"-"+p6p_d( dimsizes(p6p_d)-1 ) ; showing period
plot1 = gsn_csm_contour_map_ce(wks, p6pm, res)
lines(5) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(5) = plot1

;gsn_panel(wks,(/plot(0),plot(1),plot(2),plot(3),plot(4),plot(5)/),(/3,2/),resP)
gsn_panel(wks,(/plot(2),plot(1),plot(0)/),(/3,1/),resP)

print("Plot created-> "+pltn)
print("%%%% Leave 'plot_sst_anom_hist.ncl' %%%% ")

end
