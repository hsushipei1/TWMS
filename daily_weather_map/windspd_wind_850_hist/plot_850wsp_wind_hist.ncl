begin
print("%%%% Enter 'plot_850wsp_wind_hist.ncl' %%%% ")

;;----domain
lon1 = 39 
lon2 = 181
lats = -25
latn = 30
plev = 850 ; unit: hPa
fcstModel = "GFS"

;;----read data
; U
fs = systemfunc ("ls /data5/hsushipei/data/fnl/sliced/latest/daily/fnl025_u_*.nc4")
f1 = addfiles( fs( dimsizes( fs )-36:dimsizes( fs )-1 ) , "r" )
ListSetType(f1, "cat")
varrt = f1[:]->u(:,{plev},{lats:latn},{lon1:lon2})
printVarSummary(varrt)

RT_TIME = varrt&time
RT_END = RT_TIME( dimsizes(RT_TIME)-1 ) ; end of RT data
RT_END@time = RT_TIME( dimsizes(RT_TIME)-1 )
delete(RT_TIME) 

; GFS forecast (no leap day)
fils3 = systemfunc ("ls /data5/hsushipei/data/gfs/ncep/gfs.u.*.pgrb2.1p00.f000_f384.daily.nc")
f3 = addfiles (fils3, "r")
ListSetType (f3, "cat")
varf = f3[:]->UGRD(1:dimsizes(f3[:]->time)-3,{plev},{lats:latn},:) ; start from 2nd
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
delete(dimname)

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

; V
fs2 = systemfunc ("ls /data5/hsushipei/data/fnl/sliced/latest/daily/fnl025_v_*.nc4")
f2 = addfiles( fs2( dimsizes( fs2 )-36:dimsizes( fs2 )-1 ) , "r" )
ListSetType(f2, "cat")
varrt2 = f2[:]->v(:,{plev},{lats:latn},{lon1:lon2})
printVarSummary(varrt2) 

; GFS forecast (no leap day)
fils4 = systemfunc ("ls /data5/hsushipei/data/gfs/ncep/gfs.v.*.pgrb2.1p00.f000_f384.daily.nc")
f4 = addfiles (fils4, "r")
ListSetType (f4, "cat")
varf2 = f4[:]->VGRD(1:dimsizes(f4[:]->time)-3,{plev},{lats:latn},:) ; start from 2nd
varf2&time = fcst_tc
printVarSummary(varf2)

; regrid RT to 1 deg (GFS)
dimname2 = getvardims(varrt2) ; t, lat, lon
loni = varrt2&$dimname2(2)$
lati = varrt2&$dimname2(1)$
lono = varf2&longitude
lato = varf2&latitude
varrt2_rg = linint2_Wrap(loni, lati, varrt2, True, lono, lato, 0)
;printVarSummary(varrt2_rg)
delete(loni)
delete(lati)
delete(lono)
delete(lato)
delete(varrt2)
delete(dimname2)

; merge RT and fcst
varrt2 = array_append_record(varrt2_rg, varf2,0) ; RT + Fcst
delete(varrt2_rg)
delete(varf2)
printVarSummary(varrt2)

;;---- choose pentad
var2_p1wm = dim_avg_n_Wrap( varrt2({p1w_d},:,:), 0)
var2_p2wm = dim_avg_n_Wrap( varrt2({p2w_d},:,:), 0)
var2_p3wm = dim_avg_n_Wrap( varrt2({p3w_d},:,:), 0)
var2_f1wm = dim_avg_n_Wrap( varrt2({f1w_d},:,:), 0)
var2_f2wm = dim_avg_n_Wrap( varrt2({f2w_d},:,:), 0)
printVarSummary( var2_p1wm) 
delete(varrt2)

;;---- wind speed
wspd_p1wm = sqrt( var_p1wm^2 + var2_p1wm^2 )
copy_VarCoords( var_p1wm, wspd_p1wm )
wspd_p2wm = sqrt( var_p2wm^2 + var2_p2wm^2 )
copy_VarCoords( var_p1wm, wspd_p2wm )
wspd_p3wm = sqrt( var_p3wm^2 + var2_p3wm^2 )
copy_VarCoords( var_p1wm, wspd_p3wm )
wspd_f1wm = sqrt( var_f1wm^2 + var2_f1wm^2 )
copy_VarCoords( var_p1wm, wspd_f1wm )
wspd_f2wm = sqrt( var_f2wm^2 + var2_f2wm^2 )
copy_VarCoords( var_p1wm, wspd_f2wm )

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
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 8  ; 10
res@cnMaxLevelValF = 40  ; 35
res@cnLevelSpacingF = 8  ; 5
res@lbLabelFont = 21 ; font for label bar
res@pmLabelBarOrthogonalPosF = 0.1 ;  color bar y position
;res@gsnMaximize = True
res@lbLabelBarOn  = False  ; turn off individual color bar
res@cnLineLabelFontHeightF = 1. ; seems to remove contour labels as individual color bars are removed
;res@gsnStringFont = 0 ; font for gsnright/center/leftstring
res@gsnRightStringFontHeightF = 0.019
res@gsnLeftStringFontHeightF = 0.019

res2 = True
res2@gsnDraw       = False                ; don't draw yet
res2@gsnFrame      = False                ; don't advance frame yet
res2@gsnAddCyclic  = False
;res2@vcMinMagnitudeF      = 0.05    ;  arrow with magnitude under this value will not be drawn.
res2@vcRefLengthF         = 0.025    ;  length of unit reference vector
res2@vcRefMagnitudeF      =  15.    ;  magnitude of the reference vector
res2@vcMinDistanceF       = 0.028    ;  Vector density: distance between arrows
res2@vcLineArrowHeadMinSizeF = 0.006
res2@vcLineArrowHeadMaxSizeF = 0.006
res2@vcLineArrowThicknessF = 2.5 ; arrow thickness
res2@vcRefAnnoOrthogonalPosF = 0.2 ; y position of vector reference annotation
res2@vcRefAnnoFont = 21 ; font for vector reference annotation
res2@vcRefAnnoFontHeightF = 0.015 ; font for vector reference annotation
res2@vcRefAnnoString2On = False ; turn off string "Reference vector" in vector ref annotation box
res2@vcRefAnnoOrthogonalPosF = 0.15 ; y coordinate of vector ref annotation box
res2@vcRefAnnoParallelPosF = 0.95 ; x coordinate of vector ref annotation box

res3 = True
res3@gsnDraw       = False                ; don't draw yet
res3@gsnFrame      = False                ; don't advance frame yet
res3@gsnAddCyclic  = False
res3@stMinDistanceF = 0.05   ; streamline density: distance between two streamline
res3@stArrowLengthF = 0.01  ; arrow size
res3@stArrowStride = 7 ; arrow density: arrows are placed every ? grid point

; resource for panel 
resP = True
resP@gsnMaximize = True ; maximize plot
resP@gsnPanelLabelBar = True ; adds a common label bar at the bottom of the plot
resP@lbLabelFont = 21 ; font type of labels of common color bar  
resP@lbLabelFontHeightF = 0.013 ; font height of labels of common color bar  
resP@pmLabelBarWidthF = 0.5
resP@pmLabelBarOrthogonalPosF = 0.005 ; y position of label bar
resP@txString = "Wind Speed and Streamline at 850 hPa: Observation / GFS Forecast" ; add common title
resP@txFontHeightF = 0.015 ; font size for common title
resP@txFont = 22 ; font for common title

txres = True
txres@txFontHeightF = 0.02 ; font height

mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.5

;;----plot
pltdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/windspd_wind_850_hist/"
pltn = "windspd_wind_850_hist"

wks_type = "pdf"
wks_type@wkPaperWidthF  = 16.666666667  ; in inches
wks_type@wkPaperHeightF = 16.666666667  ; in inches

wks = gsn_open_wks(wks_type, pltdir+pltn)
gsn_define_colormap(wks,"sunshine_9lev")   ; define color map
plot = new(6,graphic) ; create plot array
lines = new(6,graphic)
 
delete(wspd_p1wm@long_name)
delete(wspd_p1wm@standard_name)
delete(wspd_p1wm@units)
delete(var_p1wm@long_name)
delete(var_p1wm@units)
delete(var2_p1wm@long_name)
delete(var2_p1wm@units)
wspd_p1wm@long_name = "7d avg(0)"
res@gsnRightString = p1w_d(0)+"-"+p1w_d( dimsizes(p1w_d)-1 ) ; showing period
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, wspd_p1wm, res)
;plot2 = gsn_csm_vector(wks,var_p1wm, var2_p1wm, res2) ; vector, for smaller plot domain 
plot2 = gsn_csm_streamline(wks,var_p1wm, var2_p1wm, res3) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(0) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(0) = plot1

delete(wspd_p2wm@long_name)
delete(wspd_p2wm@standard_name)
delete(wspd_p2wm@units)
delete(var_p2wm@long_name)
delete(var_p2wm@units)
delete(var2_p2wm@long_name)
delete(var2_p2wm@units)
wspd_p2wm@long_name = "7d avg(-1)"
res@gsnRightString = p2w_d(0)+"-"+p2w_d( dimsizes(p2w_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, wspd_p2wm, res)
;plot2 = gsn_csm_vector(wks,var_p2wm, var2_p2wm, res2) ; vector, for smaller plot domain 
plot2 = gsn_csm_streamline(wks,var_p2wm, var2_p2wm, res3) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(1) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(1) = plot1

delete(wspd_p3wm@long_name)
delete(wspd_p3wm@standard_name)
delete(wspd_p3wm@units)
delete(var_p3wm@long_name)
delete(var_p3wm@units)
delete(var2_p3wm@long_name)
delete(var2_p3wm@units)
wspd_p3wm@long_name = "7d avg(-2)"
res@gsnRightString = p3w_d(0)+"-"+p3w_d( dimsizes(p3w_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, wspd_p3wm, res)
;plot2 = gsn_csm_vector(wks,var_p3wm, var2_p3wm, res2) ; vector, for smaller plot domain 
plot2 = gsn_csm_streamline(wks,var_p3wm, var2_p3wm, res3) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(2) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(2) = plot1

delete(wspd_f1wm@long_name)
delete(wspd_f1wm@standard_name)
delete(wspd_f1wm@units)
delete(var_f1wm@long_name)
delete(var_f1wm@units)
delete(var2_f1wm@long_name)
delete(var2_f1wm@units)
wspd_f1wm@long_name = "7d avg(1)"
res@gsnRightString = f1w_d(0)+"-"+f1w_d( dimsizes(f1w_d)-1 ) ; showing period 
res2@vcRefAnnoOn = False ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, wspd_f1wm, res)
;plot2 = gsn_csm_vector(wks,var_f1wm, var2_f1wm, res2) ; vector, for smaller plot domain 
plot2 = gsn_csm_streamline(wks,var_f1wm, var2_f1wm, res3) ; vector, for smaller plot domain 
overlay(plot1, plot2)
lines(3) = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
plot(3) = plot1
;
delete(wspd_f2wm@long_name)
delete(wspd_f2wm@standard_name)
delete(wspd_f2wm@units)
delete(var_f2wm@long_name)
delete(var_f2wm@units)
delete(var2_f2wm@long_name)
delete(var2_f2wm@units)
wspd_f2wm@long_name = "7d avg(2)"
res@gsnRightString = f2w_d(0)+"-"+f2w_d( dimsizes(f2w_d)-1 ) ; showing period 
res2@vcRefAnnoOn = True ; turn off individual vector ref annotation box, only turn on for the last plot
plot1 = gsn_csm_contour_map_ce(wks, wspd_f2wm, res)
;plot2 = gsn_csm_vector(wks,var_f2wm, var2_f2wm, res2) ; vector, for smaller plot domain 
plot2 = gsn_csm_streamline(wks,var_f2wm, var2_f2wm, res3) ; vector, for smaller plot domain 
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
print("%%%% Leave 'plot_850wsp_wind_hist.ncl' %%%% ")

end
