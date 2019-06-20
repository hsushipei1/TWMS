begin
print("%%%% Enter 'plot_500hgt_wind_hist.ncl' %%%% ")

;;----domain
lon1 = 79 
lon2 = 181
lats = 0
latn = 60
plev = 500 ; unit: hPa
fcstModel = "GFS"

;;----read data
fs = systemfunc ("ls /data5/hsushipei/data/fnl/sliced/latest/daily/fnl025_hgt_*.nc4")
f1 = addfiles( fs( dimsizes( fs )-36:dimsizes( fs )-1 ) , "r" )
ListSetType(f1, "cat")
varrt = f1[:]->HGT(:,{plev},{lats:latn},{lon1:lon2})
printVarSummary(varrt)

RT_TIME = varrt&time
RT_END = RT_TIME( dimsizes(RT_TIME)-1 ) ; end of RT data
RT_END@time = RT_TIME( dimsizes(RT_TIME)-1 )
delete(RT_TIME) 

; GFS forecast (no leap day)
fils3 = systemfunc ("ls /data5/hsushipei/data/gfs/ncep/gfs.hgt.*.pgrb2.1p00.f000_f384.daily.nc")
f3 = addfiles (fils3, "r")
ListSetType (f3, "cat")
varf = f3[:]->HGT(1:dimsizes(f3[:]->time)-3,{plev},{lats:latn},:) ; start from 2nd
;fcst_tc = decimalPlaces(varf&time,0, False) ; time coordinate of forecast data
fcst_tc = tointeger(varf&time) ; time coordinate of forecast data
fcst_start = fcst_tc(0)
fcst_start@time = fcst_tc(0)
fcst_start@long_name = "Start date of "+fcstModel
fcst_end = fcst_tc(dimsizes(fcst_tc)-1)
fcst_end@time = fcst_tc(dimsizes(fcst_tc)-1)
fcst_end@long_name = "End date of "+fcstModel
varf&time = fcst_tc
printVarSummary(varf)

; regrid RT to 1 deg (GFS)
dimname = getvardims(varrt) ; t, lat, lon
loni = varrt&$dimname(2)$
lati = varrt&$dimname(1)$
lono = varf&longitude
lato = varf&latitude
varrt_rg = linint2_Wrap(loni, lati, varrt, True, lono, lato, 0)
;printVarSummary(varrt_rg)
delete(loni)
delete(lati)
delete(lono)
delete(lato)
delete(varrt)

; merge RT and fcst
varrt = array_append_record(varrt_rg, varf,0) ; RT + Fcst
delete(varrt_rg)
delete(varf)
printVarSummary(varrt)

;;---- choose pentad
datee = varrt&time
RT_END_ind = ind(datee.eq.RT_END)

p1w_d = datee( RT_END_ind-6 : RT_END_ind ) 
p2w_d = datee( RT_END_ind-13 : RT_END_ind-7 ) 
p3w_d = datee( RT_END_ind-20 : RT_END_ind-14 ) 

f1w_d = datee( RT_END_ind+1 : RT_END_ind+7 ) ; 1w fcst
f2w_d = datee( RT_END_ind+8 : RT_END_ind+14 ) ; 2w fcst
;print(p1w_d)
;print(f1w_d)
;print(f2w_d)

var_p1wm = dim_avg_n_Wrap( varrt({p1w_d},:,:), 0)
var_p2wm = dim_avg_n_Wrap( varrt({p2w_d},:,:), 0)
var_p3wm = dim_avg_n_Wrap( varrt({p3w_d},:,:), 0)
var_f1wm = dim_avg_n_Wrap( varrt({f1w_d},:,:), 0)
var_f2wm = dim_avg_n_Wrap( varrt({f2w_d},:,:), 0)
printVarSummary( var_p1wm) 
delete(varrt)

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
res@tmXBLabelFontHeightF = 0.017
res@tmYLLabelFont = 21
res@tmYLLabelFontHeightF = 0.017
res@cnFillOn  = False 
res@cnLinesOn = True 
res@cnLabelMasking = True
res@cnInfoLabelOn = False
res@cnInfoLabelFont = 0
res@cnLineLabelsOn = True
res@cnLineLabelBackgroundColor = "transparent"
res@cnLineLabelFontHeightF = 0.015
;res@cnLineLabelPlacementMode = "Computed"
;res@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 5160
res@cnMaxLevelValF = 6480
res@cnLevelSpacingF = 60
;res@gsnMaximize = True
res@lbLabelBarOn  = False  ; turn off individual color bar
;res@gsnStringFont = 0 ; font for gsnright/center/leftstring
res@gsnRightStringFontHeightF = 0.019
res@gsnLeftStringFontHeightF = 0.019

; 5880m
res2 = True
res2@gsnDraw   = False
res2@gsnFrame  = False
res2@cnFillOn  = False 
res2@cnLinesOn = True 
res2@cnLineThicknessF = 4.5
res2@cnLabelMasking = True
res2@cnInfoLabelOn = False
res2@cnInfoLabelFont = 0
res2@cnLineColor = "red"
res2@cnLineLabelsOn = False
;res2@cnLineLabelBackgroundColor = "transparent"
;res2@cnLineLabelFontHeightF = 0.015
;res2@cnLineLabelPlacementMode = "Computed"
;res2@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
res2@gsnContourZeroLineThicknessF = 0
res2@gsnContourNegLineDashPattern = 6
res2@cnLevelSelectionMode = "explicitlevels"
res2@cnLevels = (/5880./)

; resource for panel 
resP = True
resP@gsnMaximize = True ; maximize plot
resP@gsnPanelLabelBar = True ; adds a common label bar at the bottom of the plot
resP@lbLabelFont = 21 ; font type of labels of common color bar  
resP@lbLabelFontHeightF = 0.013 ; font height of labels of common color bar  
resP@pmLabelBarWidthF = 0.5
resP@pmLabelBarOrthogonalPosF = 0.005 ; y position of label bar
resP@txString = "Geopotential Height at 500 hPa: Observation / GFS Forecast" ; add common title
resP@txFontHeightF = 0.015 ; font size for common title
resP@txFont = 22 ; font for common title

txres = True
txres@txFontHeightF = 0.02 ; font height

mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.5

;;----plot
pltdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/hgt_500_hist/"
pltn = "hgt_500_hist"

wks_type = "pdf"
wks_type@wkPaperWidthF  = 16.666666667  ; in inches
wks_type@wkPaperHeightF = 16.666666667  ; in inches

wks = gsn_open_wks(wks_type, pltdir+pltn)
gsn_define_colormap(wks,"WhiteGreen")   ; define color map
plot = new(6,graphic) ; create plot array
lines = new(6,graphic)
 
delete(var_p1wm@long_name)
delete(var_p1wm@units)
var_p1wm@long_name = "7d avg(0)"
res@gsnRightString = p1w_d(0)+"-"+p1w_d( dimsizes(p1w_d)-1 ) ; showing period
;res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, var_p1wm, res)
delete(var_p1wm@long_name)
plot2 = gsn_csm_contour(wks,var_p1wm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(0) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(0) = plot1

delete(var_p2wm@long_name)
delete(var_p2wm@units)
var_p2wm@long_name = "7d avg(-1)"
res@gsnRightString = p2w_d(0)+"-"+p2w_d( dimsizes(p2w_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, var_p2wm, res)
delete(var_p2wm@long_name)
plot2 = gsn_csm_contour(wks,var_p2wm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(1) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(1) = plot1

delete(var_p3wm@long_name)
delete(var_p3wm@units)
var_p3wm@long_name = "7d avg(-2)"
res@gsnRightString = p3w_d(0)+"-"+p3w_d( dimsizes(p3w_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, var_p3wm, res)
delete(var_p3wm@long_name)
plot2 = gsn_csm_contour(wks,var_p3wm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(2) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(2) = plot1

delete(var_f1wm@long_name)
delete(var_f1wm@units)
var_f1wm@long_name = "7d avg(1)"
res@gsnRightString = f1w_d(0)+"-"+f1w_d( dimsizes(f1w_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, var_f1wm, res)
delete(var_f1wm@long_name)
plot2 = gsn_csm_contour(wks,var_f1wm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(3) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(3) = plot1
;
delete(var_f2wm@long_name)
delete(var_f2wm@units)
var_f2wm@long_name = "7d avg(2)"
res@gsnRightString = f2w_d(0)+"-"+f2w_d( dimsizes(f2w_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, var_f2wm, res)
delete(var_f2wm@long_name)
plot2 = gsn_csm_contour(wks,var_f2wm, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(4) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(4) = plot1
;
;delete(pw_p6mm@long_name)
;delete(pw_p6mm@standard_name)
;delete(pw_p6mm@units)
;delete(u_p6mm@long_name)
;delete(u_p6mm@units)
;delete(v_p6mm@long_name)
;delete(v_p6mm@units)
;pw_p6mm@long_name = "Last 6 month"
;res@gsnRightString = p6m_d(0)+"-"+p6m_d( dimsizes(p6m_d)-1 ) ; showing period 
;res2@vcRefAnnoOn = True ; turn off individual vector ref annotation box, only turn on for the last plot
;plot1 = gsn_csm_contour_map_ce(wks, pw_p6mm, res)
;plot2 = gsn_csm_vector(wks,u_p6mm, v_p6mm, res2) ; vector, for smaller plot domain 
;overlay(plot1, plot2)
;lines(5) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
;plot(5) = plot1

;gsn_panel(wks,(/plot(0),plot(1),plot(2),plot(3),plot(4),plot(5)/),(/3,2/),resP)
gsn_panel(wks,(/plot(2), plot(3), plot(1),plot(4), plot(0), plot(5)/),(/3,2/),resP)

print("Plot created-> "+pltn)
print("%%%% Leave 'plot_500hgt_wind_hist.ncl' %%%% ")

end
