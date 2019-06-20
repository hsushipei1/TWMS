load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/kf_filter.ncl"
begin

lats = -5
latn = 5
plon1 = 39
plon2 = 181

;;---- read data
; OLR
f = addfile("/data5/hsushipei/data/total_field/OLR/realtime/latest.nc","r")
time = f->time
ntime = dimsizes(time)
tend = ntime-1 ; latest olr time step (end)
tstart = tend-60 ; time step of two months ago (start)
totolr = f->olr(tstart:tend,{lats:latn},{plon1:plon2}) ;[ntime]x[nlat]x[nlon]
printVarSummary(totolr)
perd = totolr&time ; plot period
dstart_s = str_split_by_length(perd(0),(/4,2,2/))

;; Extended Period for Wave Prediction
; extend end point of real time data to include period for wave prediction
dend = time(tend) ; end date of realtime data
dend_s = tointeger(str_split_by_length(dend,(/4,2,2/))) ; separated end date, yyyymmdd 
dsince = "days since "+dend_s(0)+"-"+dend_s(1)+"-"+dend_s(2)+" 00:00:00" ; days since end of current time
tfcst = ispan(1, 14, 1)
tfcst@units = dsince
dfcst = new((/dimsizes(tfcst)/), typeof(perd)) ; date for forecast period
do qq = 0, dimsizes(tfcst)-1
	dfcst(qq) = cd_calendar(tfcst(qq), 2)
end do
copy_VarAtts( perd, dfcst )

; "perd2" includes period for two-week forecast
perd2 = array_append_record(perd, dfcst, 0)

;; Kel olr 
f2 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_Kelvin_olr_latest.nc","r")
kelolr = f2->olr({perd2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(kelolr)

; MJO olr
f3 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_MJO_olr_latest.nc","r")
mjoolr = f3->olr({perd2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(mjoolr)

; er olr
f5 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_ER_olr_latest.nc","r")
erolr = f5->olr({perd2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
delete(erolr@missing_value)
printVarSummary(erolr)

; mrg olr 
f7 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_MRG_olr_latest.nc","r")
mrgolr = f7->olr({perd2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(mrgolr)

;; WH04 olr anomaly
f10 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_olr_latest.nc","r")
wh_olr = f10->olr({perd},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(wh_olr)

; total 925U
;f11 = addfile("/data5/hsushipei/data/fnl/sliced/latest/daily/fnl025_u_201601_latest_daily.nc","r")
;totu925 = f11->UGRD({perd},{925},{lats:latn},{plon1:plon2})
;printVarSummary(totu925)

;;---- latitudinal mean
kelolrm = dim_avg_n_Wrap(kelolr,1)
mjoolrm = dim_avg_n_Wrap(mjoolr,1)
erolrm = dim_avg_n_Wrap(erolr,1)
totolrm = dim_avg_n_Wrap(totolr,1)
mrgolrm = dim_avg_n_Wrap(mrgolr,1)
;totu925m = dim_avg_n_Wrap(totu925,1)
wh_olrm = dim_avg_n_Wrap(wh_olr,1)

; extend olr anomaly
olrm2 = new( (/dimsizes(tfcst), dimsizes(wh_olrm&lon) /), typeof(wh_olrm)) ; addtional period
;olrm2 = 0. 

; Sum of OLR from each filtered waves (forecast period)
kwfcst = kelolrm({dfcst},:)
mjofcst = mjoolrm({dfcst},:)
erfcst = erolrm({dfcst},:) 
mrgfcst = mrgolrm({dfcst},:) 
olrm2 = kwfcst ; assign coordinate and attributes
olrm2 = kwfcst+mjofcst+erfcst+mrgfcst
printVarSummary(olrm2)

olrm_ext = array_append_record(wh_olrm, olrm2, 0)
olrm_ext@long_name = "Extended OLR anomaly"
olrm_ext&time = kelolrm&time
printVarSummary(olrm_ext)

; observed and forecast 
mis = -999 ; missing value
mis@_FillValue = -999

delete(wh_olrm)
wh_olrm = olrm_ext 
wh_olrmnf = wh_olrm ; value in forecast period is 0
wh_olrmnf({dfcst},:) = mis

mjoolrmnf = mjoolrm ; value in forecast period is 0
mjoolrmnf({dfcst},:) = mis

kelolrmnf = kelolrm ; value in forecast period is 0
kelolrmnf({dfcst},:) = mis

erolrmnf = erolrm ; value in forecast period is 0
erolrmnf({dfcst},:) = mis

mrgolrmnf = mrgolrm ; value in forecast period is 0
mrgolrmnf({dfcst},:) = mis

printVarSummary(totolrm)
printVarSummary(kelolrm)
printVarSummary(mjoolrm)
printVarSummary(erolrm)
printVarSummary(mrgolrm)
;printVarSummary(wh_olrm)

;;; OLR standard deviation of each waves
kelolrm_sd = 10
mjoolrm_sd = 10
erolrm_sd = 10
mrgolrm_sd = 10

;;---- resource
res=True
;res@tiMainString  = tostring(des_t(n))
res@gsnDraw   = False
res@gsnFrame  = False
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
;res@cnLevelSelectionMode = "manuallevels"
;res@cnMinLevelValF = 170  ; tot OLR
;res@cnMaxLevelValF = 330  ; tot OLR
;res@cnLevelSpacingF =  20  ; tot OLR
res@cnLevelSelectionMode = "explicitlevels" ; anomaly (WH04)
;res@cnLevels = (/-75,-60,-45,-30,-15,15,30,45,60,75/)  ; anomaly (WH04)
;res@cnFillColors = (/2,3,4,5,6,8,10,11,12,13,14/) ; directly choose color from color bar by its index
res@cnLevels = (/-15,-5,5,15/)
res@cnFillColors = (/6,7,-1,9,10/)
;res@cnFillColors = (/2,3,-1,13,14/)
res@tmXBTickSpacingF = 20
res@tmXBLabelFont = 0
res@tmXBLabelFontHeightF = 0.013
res@tmXBMinorOn = True ; turn on minor tick mark
;res@tmXBMinorValues = ispan(60, 180, 10) ; specify minor tick mark
res@tmXBMinorValues = ispan(0, 360, 10) ; specify minor tick mark
res@trYReverse = True ; reverse y-axis

;; Y axis: date
;; Major value
; Rules: Show major tickmark every 5 days, and most importantly, tickmark of "tend" must be shown. For the rest of 
; the tickmarks, insert it every 5 days when counting down from "tend".
; Total period: 60 days (0 to 59)
tmPos = ispan(0,60,5) ; nth date (within two month) for major tickmark
fts = (/67,74/) ; time step for 14d forecast
tmPosF = array_append_record(tmPos, fts, 0) ; extend two weeks for forecast
mjtm_y_md = str_split_by_length(perd(tmPos),(/4,4/)) ; split date (yyyy, and mmdd) for major tickmark
datey1 = mjtm_y_md(:,1) ; yymm
datey = datey1 ; only showing near real-time result
dateyF = array_append_record( datey1, (/ "7d Fcst", "14d Fcst" /), 0 ) ; showing forecast
dunits = "days since "+dstart_s(0)+"-"+dstart_s(1)+"-"+dstart_s(2)+" 00:00:00"
nthd_y = new((/dimsizes(datey)/), "double")
res@tmYLMode   = "Explicit"
res@tmYLLabelFont = 0
res@tmYLValues = tmPosF ; for not showing forecast period, use "tmPos"   
res@tmYLLabels = dateyF ; for not showing forecast period, use "datey"   
;; Minor value
res@tmYLMinorOn = True ; turn on minor tick mark
mintkval = ispan(0, dimsizes(totolr&time)-1, 1) ; cliSST ; create a array for minor tick mark that is labelled each day.
res@tmYLMinorValues = mintkval ; value for minor tickmark
res@tmYLLabelFontHeightF = 0.01
res@lbLabelFont = 0  ; Font for labels on color bar
res@lbLabelFontHeightF = 0.01 ; font size for labels on color bar
res@pmLabelBarHeightF = 0.06 ; height of color bar
res@pmLabelBarWidthF = 0.25 ; height of color bar
res@pmLabelBarOrthogonalPosF = 0.095 ; y position of color bar

; no-forecast for olra
resf = True
resf@gsnDraw   = False
resf@gsnFrame  = False
resf@cnFillOn  = True ; turn on contour fill
resf@cnLinesOn = False ; turn off contour line
resf@cnLevelSelectionMode = "explicitlevels"
resf@cnLevels = (/-75,-60,-45,-30,-15,15,30,45,60,75/)  ; anomaly (WH04)
resf@cnFillColors = (/2,3,4,5,6,8,10,11,12,13,14/) ; directly choose color from color bar by its index
;resf@cnLevels = (/-15,-5,5,15/)
;resf@cnFillColors = (/6,7,-1,9,10/)
resf@lbLabelFont = 0  ; Font for labels on color bar
resf@lbLabelFontHeightF = 0.01 ; font size for labels on color bar
resf@pmLabelBarHeightF = 0.06 ; height of color bar
resf@pmLabelBarWidthF = 0.4 ; height of color bar
resf@pmLabelBarOrthogonalPosF = 0.03 ; y position of color bar

; no fcst mjo olr
res2 = True
res2@gsnDraw   = False
res2@gsnFrame  = False
;res2@cnFillOn  = True ; turn on contour fill
;res2@cnLinesOn = False ; turn off contour line
res2@cnLineThicknessF = 1.5
res2@cnLabelMasking = True
res2@cnInfoLabelOn = False
res2@cnInfoLabelFont = 0
res2@cnLineColor = "black"   ;"blue"
res2@cnLineLabelsOn = False
res2@cnLineLabelFont = 0
res2@cnLineLabelBackgroundColor = "transparent"
res2@cnLineLabelFontHeightF = 0.005
res2@cnLineLabelPlacementMode = "Computed"
res2@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
res2@gsnContourZeroLineThicknessF = 0
res2@gsnContourNegLineDashPattern = 6
res2@cnLevelSelectionMode = "explicitlevels"
res2@cnLevels = (/-4*mjoolrm_sd,-3*mjoolrm_sd, -2*mjoolrm_sd, -mjoolrm_sd, \
                     mjoolrm_sd, 2*mjoolrm_sd, 3*mjoolrm_sd, 4*mjoolrm_sd/) ; both positive and negative value

; forecasted mjo olr
resf2 = True
resf2@gsnDraw   = False
resf2@gsnFrame  = False
;res2@cnFillOn  = True ; turn on contour fill
;res2@cnLinesOn = False ; turn off contour line
resf2@cnLineThicknessF = 1.5
resf2@cnLabelMasking = True
resf2@cnInfoLabelOn = False
resf2@cnInfoLabelFont = 0
resf2@cnLineColor = "black"  ;"blue"
resf2@cnLineLabelsOn = False
resf2@cnLineLabelFont = 0
resf2@cnLineLabelBackgroundColor = "transparent"
resf2@cnLineLabelFontHeightF = 0.005
resf2@cnLineLabelPlacementMode = "Computed"
resf2@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
resf2@gsnContourZeroLineThicknessF = 0
resf2@gsnContourNegLineDashPattern = 6
resf2@cnLevelSelectionMode = "explicitlevels"
resf2@cnLevels = (/-10,-5,5,10/)

; no fcst kel olr
res3 = True
res3@gsnDraw   = False
res3@gsnFrame  = False
;res3@cnFillOn  = True ; turn on contour fill
;res3@cnLinesOn = False ; turn off contour line
res3@cnLineThicknessF = 1.5
res3@cnLabelMasking = True
res3@cnInfoLabelOn = False
res3@cnInfoLabelFont = 0
res3@cnLineColor = "blue"
res3@cnLineLabelsOn = False
res3@cnLineLabelFont = 0
res3@cnLineLabelBackgroundColor = "transparent"
res3@cnLineLabelFontHeightF = 0.007
res3@gsnContourZeroLineThicknessF = 0
res3@gsnContourNegLineDashPattern = 6
res3@cnLevelSelectionMode = "explicitlevels"
res3@cnLevels = (/-4*kelolrm_sd,-3*kelolrm_sd, -2*kelolrm_sd, -kelolrm_sd, \
                     kelolrm_sd, 2*kelolrm_sd, 3*kelolrm_sd, 4*kelolrm_sd/) ; both positive and negative value

; fcst kel olr
resf3 = True
resf3@gsnDraw   = False
resf3@gsnFrame  = False
;resf3@cnFillOn  = True ; turn on contour fill
;resf3@cnLinesOn = False ; turn off contour line
resf3@cnLineThicknessF = 1.5
resf3@cnLabelMasking = True
resf3@cnInfoLabelOn = False
resf3@cnInfoLabelFont = 0
resf3@cnLineColor = "blue"
resf3@cnLineLabelsOn = False
resf3@cnLineLabelFont = 0
resf3@cnLineLabelBackgroundColor = "transparent"
resf3@cnLineLabelFontHeightF = 0.007
resf3@gsnContourZeroLineThicknessF = 0
resf3@gsnContourNegLineDashPattern = 6
resf3@cnLevelSelectionMode = "explicitlevels"
resf3@cnLevels = (/-10,-5,5,10/)

; er olr
res5 = True
res5@gsnDraw   = False
res5@gsnFrame  = False
;res5@cnFillOn  = True ; turn on contour fill
;res5@cnLinesOn = False ; turn off contour line
res5@cnLineThicknessF = 1.5
res5@cnLabelMasking = True
res5@cnInfoLabelOn = False
res5@cnInfoLabelFont = 0
res5@cnLineColor = "red"
res5@cnLineLabelsOn = False
res5@cnLineLabelFont = 0
res5@cnLineLabelBackgroundColor = "transparent"
res5@cnLineLabelFontHeightF = 0.007
res5@gsnContourZeroLineThicknessF = 0
res5@gsnContourNegLineDashPattern = 6
res5@cnLevelSelectionMode = "explicitlevels"
res5@cnLevels = (/-4*erolrm_sd,-3*erolrm_sd, -2*erolrm_sd, -erolrm_sd, \
                     erolrm_sd, 2*erolrm_sd, 3*erolrm_sd, 4*erolrm_sd/) ; both positive and negative value

; fcst er olr
resf5 = True
resf5@gsnDraw   = False
resf5@gsnFrame  = False
;resf5@cnFillOn  = True ; turn on contour fill
;resf5@cnLinesOn = False ; turn off contour line
resf5@cnLineThicknessF = 1.5
resf5@cnLabelMasking = True
resf5@cnInfoLabelOn = False
resf5@cnInfoLabelFont = 0
resf5@cnLineColor = "red"
resf5@cnLineLabelsOn = False
resf5@cnLineLabelFont = 0
resf5@cnLineLabelBackgroundColor = "transparent"
resf5@cnLineLabelFontHeightF = 0.007
resf5@gsnContourZeroLineThicknessF = 0
resf5@gsnContourNegLineDashPattern = 6
resf5@cnLevelSelectionMode = "explicitlevels"
resf5@cnLevels = (/-10,-5,5,10/)

; mrg olr
res6 = True
res6@gsnDraw   = False
res6@gsnFrame  = False
;res6@cnFillOn  = True ; turn on contour fill
;res6@cnLinesOn = False ; turn off contour line
res6@cnLineThicknessF = .8
res6@cnLabelMasking = True
res6@cnInfoLabelOn = False
res6@cnInfoLabelFont = 0
res6@cnLineColor = "navy"
res6@cnLineLabelsOn = False
res6@cnLineLabelFont = 0
res6@cnLineLabelBackgroundColor = "transparent"
res6@cnLineLabelFontHeightF = 0.007
res6@gsnContourZeroLineThicknessF = 0
res6@gsnContourNegLineDashPattern = 6
res6@cnLevelSelectionMode = "ExplicitLevels"
res6@cnLevels = (/-4*mrgolrm_sd,-3*mrgolrm_sd, -2*mrgolrm_sd, -mrgolrm_sd, \
                     mrgolrm_sd, 2*mrgolrm_sd, 3*mrgolrm_sd, 4*mrgolrm_sd/) ; both positive and negative value

; fcst mrg olr
resf6 = True
resf6@gsnDraw   = False
resf6@gsnFrame  = False
;res6@cnFillOn  = True ; turn on contour fill
;res6@cnLinesOn = False ; turn off contour line
resf6@cnLineThicknessF = .8
resf6@cnLabelMasking = True
resf6@cnInfoLabelOn = False
resf6@cnInfoLabelFont = 0
resf6@cnLineColor = "navy"
resf6@cnLineLabelsOn = False
resf6@cnLineLabelFont = 0
resf6@cnLineLabelBackgroundColor = "transparent"
resf6@cnLineLabelFontHeightF = 0.007
resf6@gsnContourZeroLineThicknessF = 0
resf6@gsnContourNegLineDashPattern = 6
resf6@cnLevelSelectionMode = "ExplicitLevels"
resf6@cnLevels = (/-10,-5,5,10/)

; total u925
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
res7@trYReverse = True ; reverse y-axis

; polyline for forecast
FcstL = True
FcstL@gsLineDashPattern = 5
FcstL@gsLineLabelFont = 0
FcstL@gsLineLabelConstantSpacingF = 1.
FcstL@gsLineLabelFontHeightF = 0.01
FcstL@gsLineLabelString = "Begin forecast" ; string on polyline

; Marker for TC's position
mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.0
;mkres@gsMarkerColor = pcol

; TC's track
trres = True

txres = True
txres@txFontHeightF = 0.007 ; font height
txres@txFont = 0 ; font 

;;---- plotting
delete(totolrm@long_name)
delete(totolrm@standard_name)
delete(totolrm@units)
delete(kelolrm@long_name)
delete(kelolrm@standard_name)
delete(kelolrm@units)
delete(kelolrmnf@long_name)
delete(kelolrmnf@standard_name)
delete(kelolrmnf@units)
delete(mjoolrm@long_name)
delete(mjoolrm@standard_name)
delete(mjoolrm@units)
delete(mjoolrmnf@long_name)
delete(mjoolrmnf@standard_name)
delete(mjoolrmnf@units)
delete(erolrm@long_name)
delete(erolrm@standard_name)
delete(erolrm@units)
delete(erolrmnf@long_name)
delete(erolrmnf@standard_name)
delete(erolrmnf@units)
delete(mrgolrm@long_name)
delete(mrgolrm@standard_name)
delete(mrgolrm@units)
delete(mrgolrmnf@long_name)
delete(mrgolrmnf@standard_name)
delete(mrgolrmnf@units)
delete(olrm_ext@long_name)
delete(olrm_ext@standard_name)
delete(olrm_ext@units)
delete(wh_olrm@long_name)
delete(wh_olrm@standard_name)
delete(wh_olrm@units)
delete(wh_olrmnf@long_name)
delete(wh_olrmnf@standard_name)
delete(wh_olrmnf@units)

res@tiMainString = "Hovmoller for Filtered OLR and OLR Anomaly "+lats+" to "+latn
outdir = "/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/wkfiltered_waves/olr_onOLRanomaly_fcst/"
outf = "hov_wkfilter_olr_onOLRanomaly_fcst_latest_"+lats+"_"+latn 
res@tiMainFontHeightF = 0.013 ; height of title font
res@tiMainFont =  13
wks = gsn_open_wks("pdf", outdir+outf)
gsn_define_colormap(wks,"sunshine_diff_12lev")   ; color map for olr
;gsn_define_colormap(wks,"MPL_rainbow")   ; color map for olr
;gsn_define_colormap(wks,"precip2_17lev")   ; precipitation or sst
;plot1 = gsn_csm_hov(wks, totolrm(:,{plon1:plon2}), res) ; total OLR
plot1 = gsn_csm_hov(wks, wh_olrm(:,{plon1:plon2}), res) ; wh04 olr anomaly
plotf1 = gsn_csm_hov(wks, wh_olrmnf(:,{plon1:plon2}), resf) ; olr anomaly forecast
plot2 = gsn_csm_hov(wks, mjoolrmnf(:,{plon1:plon2}), res2) ; mjo olr no fcst
plotf2 = gsn_csm_hov(wks, mjoolrm(:,{plon1:plon2}), resf2) ; mjo olr
plot3 = gsn_csm_hov(wks, kelolrmnf(:,{plon1:plon2}), res3) ; kel olr no fcst
plotf3 = gsn_csm_hov(wks, kelolrm(:,{plon1:plon2}), resf3) ; kel olr
plot5 = gsn_csm_hov(wks, erolrmnf(:,{plon1:plon2}), res5) ; er olr no fcst
plotf5 = gsn_csm_hov(wks, erolrm(:,{plon1:plon2}), resf5) ; er olr
plot6 = gsn_csm_hov(wks, mrgolrmnf(:,{plon1:plon2}), res6) ; mrg olr no fcst
plotf6 = gsn_csm_hov(wks, mrgolrm(:,{plon1:plon2}), resf6) ; mrg olr
;plot7 = gsn_csm_hov(wks, totu925m({pdate1:pdate2},{plon1:plon2}), res7) ; tot u925
;TC1 = gsn_add_polymarker(wks, plot1, lontc1,datetc1 , mkres) ; TC1 position
;TC2 = gsn_add_polymarker(wks, plot1, lontc2,datetc2 , mkres) ; TC2 position
;BV = gsn_add_polymarker(wks, plot1, lontc3,datetc3, mkres) ; Borneo vortex position
;TD = gsn_add_polymarker(wks, plot1, lontc4,datetc4, mkres) ; TD position
;TC1tr = gsn_add_polyline(wks, plot1, lontc1,datetc1, trres) ; TC track
;TC2tr = gsn_add_polyline(wks, plot1, lontc2,datetc2, trres) ; TC track
;BVtr = gsn_add_polyline(wks, plot1, lontc3,datetc3, trres) ; Borneo vortex track
;TDtr = gsn_add_polyline(wks, plot1, lontc4,datetc4, trres) ; TD track
overlay(plot1, plotf2)
overlay(plot1, plotf3)
overlay(plot1, plotf5)
overlay(plot1, plotf6)
overlay(plot1, plotf1)
overlay(plot1, plot2)
overlay(plot1, plot3)
overlay(plot1, plot5)
overlay(plot1, plot6)
;overlay(plot1, plot7)
;overlay(plot1, plot8)
;overlay(plot1, plot9)
;overlay(plot1, plot10)
fcstline = gsn_add_polyline(wks, plot1, (/plon1, plon2/), (/dimsizes(perd)-1,dimsizes(perd)-1/), FcstL)
;gsn_text_ndc(wks,"Contour lev: ER= "+erolrm_sd+" MRG= "+mrgolrm_sd ,0.65,0.14,txres)
gsn_text_ndc(wks,"Contour level= "+kelolrm_sd+" for obs, 5 for fcst. MJO (black), Kelvin (blue), ER (red), MRG-TD (navy) ",0.5,0.14,txres)
gsn_text_ndc(wks,"Obs: ",0.28,0.115,txres)
gsn_text_ndc(wks,"Fcst: ",0.35,0.075,txres)
;gsn_text_ndc(wks,"Shaded area for forecast period is the sum of filtered OLR of each waves." ,0.5,0.06,txres)  
draw(plot1)
frame(wks)
print("output-> "+outf)
print(systemfunc("pwd"))

end
