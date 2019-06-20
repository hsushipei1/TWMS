load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/kf_filter.ncl"
begin

lats = 5
latn = 15
plon1 = 39
plon2 = 181
variab = "olr_U925"

;;---- read data
;; WH04 olr anomaly
f10 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_olr_latest.nc","r")
time = f10->time
ntime = dimsizes(time)
tend = ntime-1 ; latest olr time step (end)
tstart = tend-60 ; time step of two months ago (start)
wh_olr = f10->olr(tstart:tend,{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(wh_olr)
perd = wh_olr&time ; plot period
dstart_s = str_split_by_length(perd(0),(/4,2,2/))

;; WH04 U925 anomaly  
;f8 = addfile("/data5/hsushipei/data/wh04_data/field_data/wh04field_u925_20160628_20170627_mean.nc","r")
f8 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_u925_latest.nc","r")
wh_u = f8->u925({perd},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(wh_u)

;; WH04 V925 anomaly
;f9 = addfile("/data5/hsushipei/data/wh04_data/field_data/wh04field_v925_20170101_20170531_mean.nc","r")
;wh_v = f9->v925({pdate1:pdate2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
;printVarSummary(wh_v)

;;---- latitudinal mean
wh_olrm = dim_avg_n_Wrap(wh_olr,1)
wh_um = dim_avg_n_Wrap(wh_u,1)
;wh_vm = dim_avg_n_Wrap(wh_v,1)
;printVarSummary(wh_olrm)
;printVarSummary(wh_um)
;printVarSummary(wh_vm)

;;---- resource
; olr
res=True
;res@tiMainString  = tostring(des_t(n))
res@gsnDraw   = False
res@gsnFrame  = False
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
res@cnLevelSelectionMode = "explicitlevels" ; anomaly (WH04)
res@cnLevels = (/-75,-60,-45,-30,-15,15,30,45,60,75/)  ; anomaly (WH04)
res@cnFillColors = (/2,3,4,5,6,8,10,11,12,13,14/) ; directly choose color from color bar by its index
res@tmXBTickSpacingF = 20
res@tmXBLabelFont = 0
res@tmXBLabelFontHeightF = 0.013
res@tmXBMinorOn = True ; turn on minor tick mark
res@tmXBMinorValues = ispan(0, 360, 10) ; specify minor tick mark
res@trYReverse = True ; reverse y-axis

;; Y axis: date
;; Major value
; Rules: Show major tickmark every 5 days, and most importantly, tickmark of "tend" must be shown. For the rest of 
; the tickmarks, insert it every 5 days when counting down from "tend".
; Total period: 60 days (0 to 59)
tmPos = ispan(0,60,5) ; nth date (within two month) for major tickmark
mjtm_y_md = str_split_by_length(perd(tmPos),(/4,4/)) ; split date (yyyy, and mmdd) for major tickmark
datey1 = mjtm_y_md(:,1) ; yymm
datey = datey1
dunits = "days since "+dstart_s(0)+"-"+dstart_s(1)+"-"+dstart_s(2)+" 00:00:00"
res@tmYLMode   = "Explicit"
res@tmYLLabelFont = 0
res@tmYLValues = tmPos   ; OLR 
res@tmYLLabels = datey    ; OLR
;; Minor value
res@tmYLMinorOn = True ; turn on minor tick mark
mintkval = ispan(0, dimsizes(wh_olr&time)-1, 1) ; cliSST ; create a array for minor tick mark that is labelled each day.
res@tmYLMinorValues = mintkval ; value for minor tickmark
res@tmYLLabelFontHeightF = 0.01

res@lbLabelFont = 0 ; Font for labels on color bar
res@lbLabelFontHeightF = 0.009 ; font size for labels on color bar
res@pmLabelBarHeightF = 0.06 ; height of color bar
res@pmLabelBarOrthogonalPosF = 0.04 ; y position of color bar

; wh u925
res7 = True
res7@gsnDraw   = False
res7@gsnFrame  = False
;res7@cnFillOn  = True ; turn on contour fill
;res7@cnLinesOn = False ; turn off contour line
res7@cnLineThicknessF = 1.5
res7@cnLabelMasking = True
res7@cnInfoLabelFont = 0
res7@cnLineColor = "gray20" 
res7@cnLineLabelFont = 0
res7@cnLineLabelBackgroundColor = "transparent"
res7@cnLineLabelFontHeightF = 0.007
;res7@gsnContourZeroLineThicknessF = 0
res7@gsnContourZeroLineThicknessF = 2.5
res7@gsnContourNegLineDashPattern = 15
res7@cnLevelSelectionMode = "ExplicitLevels"
;res7@cnLevels = (/3,5,7,9,12,15/)
res7@cnLevels = ispan(-15,15,3)
;res7@cnMinLevelValF = 0
;res7@cnMaxLevelValF = 0
;res7@cnLevelSpacingF = 
res7@trYReverse = True ; reverse y-axis

txres = True
txres@txFontHeightF = 0.008 ; font height
txres@txFont = 0 ; font 

;;---- plotting
delete(wh_olrm@long_name)
delete(wh_olrm@standard_name)
;delete(wh_olrm@units)
delete(wh_um@long_name)
delete(wh_um@standard_name)
;delete(wh_um@units)

res@tiMainString = "Hovmoller for Latest Anomalous OLR and U925 "+lats+" to "+latn
outdir = "/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/anomaly_olr_u925/"
outf = "hov_anom_olr_u925_latest_"+lats+"_"+latn 
res@tiMainFontHeightF = 0.013 ; height of title font
res@tiMainFont =  13
wks = gsn_open_wks("pdf", outdir+outf)
gsn_define_colormap(wks,"sunshine_diff_12lev")   ; color map for olr
plot1 = gsn_csm_hov(wks, wh_olrm(:,{plon1:plon2}), res) ; wh04 olr anomaly
plot7 = gsn_csm_contour(wks, wh_um(:,{plon1:plon2}), res7) ; anomalous u925 (WH04)
overlay(plot1, plot7)
;gsn_text_ndc(wks,"Anomaly: remove first 3 harmonics of annual cycle and apply 120d running average" ,0.5,0.01,txres) ; sst contour level 
gsn_text_ndc(wks,"Anomaly: remove first 3 harmonics of annual cycle." ,0.5,0.01,txres) ; sst contour level 
draw(plot1)
frame(wks)
print("output-> "+outf)
print(systemfunc("pwd"))

end
