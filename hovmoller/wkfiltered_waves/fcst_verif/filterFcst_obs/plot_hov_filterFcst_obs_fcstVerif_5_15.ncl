load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/kf_filter.ncl"
begin

lats = 5
latn = 15
plon1 = 39
plon2 = 181

;;---- read data
; OLR
f = addfile("/data5/hsushipei/data/total_field/OLR/realtime/latest.nc","r")
time = f->time
ntime = dimsizes(time)
tend = ntime-1 ; latest olr time step (end)
tstart = tend-60 ; time step of two months ago (start)
tendfv = ntime-15 ; forecast verification (end)
tstartfv = tend-45 ; forecast verification (start)
olr = f->olr(tstart:tend,{lats:latn},{plon1:plon2}) ;[ntime]x[nlat]x[nlon] ; latest olra
olrfv = f->olr(tstart:tendfv,{lats:latn},{plon1:plon2}) ;[ntime]x[nlat]x[nlon] ; olra verification
printVarSummary(olr)
printVarSummary(olrfv)
perd = olr&time ; normal period
perdfv = olrfv&time ; for forecast verif
dstart_s = str_split_by_length(perd(0),(/4,2,2/))
;print(perd(dimsizes(perd)-1))

;; Extended Period for Wave Prediction
; extend end point of real time data to include period for wave prediction
function fcst_date( data_end_date:string ) 
local dsince, qq, tfcst
begin
	;dend = time(tend) ; end date of realtime data
	dend =  data_end_date ; end date of realtime data
	dend_s = tointeger(str_split_by_length(dend,(/4,2,2/))) ; separated end date, yyyymmdd 
	dsince = "days since "+dend_s(0)+"-"+dend_s(1)+"-"+dend_s(2)+" 00:00:00" ; days since end of current time
	tfcst = ispan(1, 14, 1)
	tfcst@units = dsince
	dfcst = new((/dimsizes(tfcst)/), typeof(perd)) ; date for forecast period
	do qq = 0, dimsizes(tfcst)-1
		dfcst(qq) = cd_calendar(tfcst(qq), 2)
	end do
	copy_VarAtts( perd, dfcst )
	return(dfcst)
end

; dates in forecast period
dfcst = fcst_date(perd(dimsizes(perd)-1))
dfcstfv = fcst_date(perdfv(dimsizes(perdfv)-1))

; "perd2" includes period for two-week forecast
perd2 = array_append_record(perd, dfcst, 0)
perd2fv = array_append_record(perdfv, dfcstfv, 0)
;print(perd2)
print(perd2fv)

;; Kel olr normal/fcst_verfi
f2 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_Kelvin_olr_latest.nc","r")
f2fv = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/fcst_verif/filt_fcst_verif_Kelvin_olr_latest.nc","r")
kelolr = f2->olr({perd2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
kelolrfv = f2fv->olr({perd2fv},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(kelolr)
printVarSummary(kelolrfv)

; MJO olr
f3 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_MJO_olr_latest.nc","r")
f3fv = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/fcst_verif/filt_fcst_verif_MJO_olr_latest.nc","r")
mjoolr = f3->olr({perd2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
mjoolrfv = f3fv->olr({perd2fv},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(mjoolr)
printVarSummary(mjoolrfv)

; er olr
f5 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_ER_olr_latest.nc","r")
f5fv = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/fcst_verif/filt_fcst_verif_ER_olr_latest.nc","r")
erolr = f5->olr({perd2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
erolrfv = f5fv->olr({perd2fv},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(erolr)
printVarSummary(erolrfv)

; mrg/td olr 
f7 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_MRG_olr_latest.nc","r")
f7fv = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/fcst_verif/filt_fcst_verif_MRG_olr_latest.nc","r")
mrgolr = f7->olr({perd2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
mrgolrfv = f7fv->olr({perd2fv},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(mrgolr)
printVarSummary(mrgolrfv)

;; WH04 olr anomaly
f10 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_olr_latest.nc","r")
wh_olr = f10->olr({perd},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
wh_olrfv = f10->olr({perdfv},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(wh_olr)
printVarSummary(wh_olrfv)

;;---- latitudinal mean
kelolrm = dim_avg_n_Wrap(kelolr,1)
kelolrmfv = dim_avg_n_Wrap(kelolrfv,1)
mjoolrm = dim_avg_n_Wrap(mjoolr,1)
mjoolrmfv = dim_avg_n_Wrap(mjoolrfv,1)
erolrm = dim_avg_n_Wrap(erolr,1)
erolrmfv = dim_avg_n_Wrap(erolrfv,1)
olrm = dim_avg_n_Wrap(olr,1)
mrgolrm = dim_avg_n_Wrap(mrgolr,1)
mrgolrmfv = dim_avg_n_Wrap(mrgolrfv,1)
wh_olrm = dim_avg_n_Wrap(wh_olr,1)
wh_olrmfv = dim_avg_n_Wrap(wh_olrfv,1)

; extend olr anomaly
olrm2 = new( (/dimsizes(dfcst), dimsizes(wh_olrm&lon) /), typeof(wh_olrm)) ; addtional period
olrmfv2 = new( (/dimsizes(dfcst), dimsizes(wh_olrm&lon) /), typeof(wh_olrm)) ; addtional period
;olrm2 = 0. 

;; Sum of OLR from each filtered waves (forecast period)
; normal
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

; forecast verification
kwfcstfv = kelolrmfv({dfcstfv},:)
mjofcstfv = mjoolrmfv({dfcstfv},:)
erfcstfv = erolrmfv({dfcstfv},:) 
mrgfcstfv = mrgolrmfv({dfcstfv},:) 
olrmfv2 = kwfcstfv ; assign coordinate and attributes
olrmfv2 = kwfcstfv+mjofcstfv+erfcstfv+mrgfcstfv
printVarSummary(olrmfv2)

olrm_extfv = array_append_record(wh_olrmfv, olrmfv2, 0)
olrm_extfv@long_name = "Extended OLR anomaly for forecast verification"
olrm_extfv&time = kelolrmfv&time
printVarSummary(olrm_extfv)

; observed and forecast 
mis = -999 ; missing value
mis@_FillValue = -999

delete(wh_olrm)
delete(wh_olrmfv)
wh_olrm = olrm_ext 
wh_olrmfv = olrm_extfv

wh_olrmnf = wh_olrm ; value in forecast period is 0
wh_olrmnf({dfcst},:) = mis
wh_olrmnffv = wh_olrmfv ; value in forecast period is 0
wh_olrmnffv({dfcstfv},:) = mis

mjoolrmnf = mjoolrm ; value in forecast period is 0
mjoolrmnf({dfcst},:) = mis
mjoolrmnffv = mjoolrmfv ; value in forecast period is 0
mjoolrmnffv({dfcstfv},:) = mis

kelolrmnf = kelolrm ; value in forecast period is 0
kelolrmnf({dfcst},:) = mis
kelolrmnffv = kelolrmfv ; value in forecast period is 0
kelolrmnffv({dfcstfv},:) = mis

erolrmnf = erolrm ; value in forecast period is 0
erolrmnf({dfcst},:) = mis
erolrmnffv = erolrmfv ; value in forecast period is 0
erolrmnffv({dfcstfv},:) = mis

mrgolrmnf = mrgolrm ; value in forecast period is 0
mrgolrmnf({dfcst},:) = mis
mrgolrmnffv = mrgolrmfv ; value in forecast period is 0
mrgolrmnffv({dfcstfv},:) = mis

printVarSummary(olrm)
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
res@cnLevelSelectionMode = "explicitlevels" ; anomaly (WH04)
;res@cnLevels = (/-75,-60,-45,-30,-15,15,30,45,60,75/)  ; anomaly (WH04)
;res@cnFillColors = (/2,3,4,5,6,8,10,11,12,13,14/) ; directly choose color from color bar by its index
res@cnLevels = (/-15,-5,5,15/)
res@cnFillColors = (/6,7,-1,9,10/)
;res@cnFillColors = (/2,3,-1,13,14/)
res@cnInfoLabelOn = False
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
res@tmYLValues = tmPosF ; for not showing forecast, use "tmPos"   
res@tmYLLabels = dateyF ; for not showing forecast, use "datey"   
;; Minor value
res@tmYLMinorOn = True ; turn on minor tick mark
mintkval = ispan(0, dimsizes(olr&time)-1, 1) ; cliSST ; create a array for minor tick mark that is labelled each day.
res@tmYLMinorValues = mintkval ; value for minor tickmark
res@tmYLLabelFontHeightF = 0.01

;res@lbLabelBarOn  = False  ; turn off individual color bar
res@lbLabelFont = 0  ; Font for labels on color bar
res@lbLabelFontHeightF = 0.01 ; font size for labels on color bar
res@pmLabelBarHeightF = 0.06 ; height of color bar
res@pmLabelBarWidthF = 0.25 ; height of color bar
res@pmLabelBarOrthogonalPosF = 0.095 ; y position of color bar
res@cnLineLabelFontHeightF = 1. ; seems to remove contour labels as individual color bars are removed

res@vpHeightF = 0.6
res@vpWidthF = 0.6

; no-forecast for olra
resf = True
resf@gsnDraw   = False
resf@gsnFrame  = False
resf@cnFillOn  = True ; turn on contour fill
resf@cnLinesOn = False ; turn off contour line
resf@cnLevelSelectionMode = "explicitlevels"
resf@cnLevels = (/-75,-60,-45,-30,-15,15,30,45,60,75/)  ; anomaly (WH04)
resf@cnFillColors = (/2,3,4,5,6,8,10,11,12,13,14/) ; directly choose color from color bar by its index
resf@cnInfoLabelOn = False
;resf@cnLevels = (/-15,-5,5,15/)
;resf@cnFillColors = (/6,7,-1,9,10/)
;resf@lbLabelBarOn  = False  ; turn off individual color bar
resf@lbLabelFont = 0  ; Font for labels on color bar
resf@lbLabelFontHeightF = 0.01 ; font size for labels on color bar
resf@pmLabelBarHeightF = 0.06 ; height of color bar
resf@pmLabelBarWidthF = 0.4 ; height of color bar
resf@pmLabelBarOrthogonalPosF = 0.03 ; y position of color bar
resf@cnLineLabelFontHeightF = 1. ; seems to remove contour labels as individual color bars are removed

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

; polyline for forecast
FcstL = True
FcstL@gsLineDashPattern = 5
FcstL@gsLineLabelFont = 0
FcstL@gsLineLabelConstantSpacingF = 1.
FcstL@gsLineLabelFontHeightF = 0.008
FcstL@gsLineLabelString = "Begin forecast" ; string on polyline

; "begin forecast" text
txres = True
txres@txFontHeightF = 0.01 ; font height
txres@txFont = 0 ; font 

; resource for panel 
resP = True
resP@gsnMaximize = True ; maximize plot
;resP@gsnPanelLabelBar = True ; adds a common label bar at the bottom of the plot
resP@lbLabelFont = 0 ; font type of labels of common color bar  
resP@lbLabelFontHeightF = 0.005 ; font height of labels of common color bar  
resP@pmLabelBarOrthogonalPosF = 0.04 ; y position of label bar
resP@txFuncCode = "~"
resP@txString = "~F0~Tropical Wave Forecast Verification: Forecast by Real-time Filtering: "+lats+"~F18~I ~F0~to "+latn+"~F18~I" ; add common title
resP@txFontHeightF = 0.011 ; font size for common title
resP@txFont = 13 ; font for common title

delete(olrm@long_name)
delete(olrm@standard_name)
delete(olrm@units)
delete(kelolrm@long_name)
delete(kelolrm@standard_name)
delete(kelolrm@units)
delete(kelolrmnf@long_name)
delete(kelolrmnf@standard_name)
delete(kelolrmnf@units)
delete(kelolrmfv@long_name)
delete(kelolrmfv@standard_name)
delete(kelolrmfv@units)
delete(kelolrmnffv@long_name)
delete(kelolrmnffv@standard_name)
delete(kelolrmnffv@units)
delete(mjoolrm@long_name)
delete(mjoolrm@standard_name)
delete(mjoolrm@units)
delete(mjoolrmnf@long_name)
delete(mjoolrmnf@standard_name)
delete(mjoolrmnf@units)
delete(mjoolrmfv@long_name)
delete(mjoolrmfv@standard_name)
delete(mjoolrmfv@units)
delete(mjoolrmnffv@long_name)
delete(mjoolrmnffv@standard_name)
delete(mjoolrmnffv@units)
delete(erolrm@long_name)
delete(erolrm@standard_name)
delete(erolrm@units)
delete(erolrmnf@long_name)
delete(erolrmnf@standard_name)
delete(erolrmnf@units)
delete(erolrmfv@long_name)
delete(erolrmfv@standard_name)
delete(erolrmfv@units)
delete(erolrmnffv@long_name)
delete(erolrmnffv@standard_name)
delete(erolrmnffv@units)
delete(mrgolrm@long_name)
delete(mrgolrm@standard_name)
delete(mrgolrm@units)
delete(mrgolrmnf@long_name)
delete(mrgolrmnf@standard_name)
delete(mrgolrmnf@units)
delete(mrgolrmfv@long_name)
delete(mrgolrmfv@standard_name)
delete(mrgolrmfv@units)
delete(mrgolrmnffv@long_name)
delete(mrgolrmnffv@standard_name)
delete(mrgolrmnffv@units)
delete(olrm_ext@long_name)
delete(olrm_ext@standard_name)
delete(olrm_ext@units)
delete(wh_olrm@long_name)
delete(wh_olrm@standard_name)
delete(wh_olrm@units)
delete(wh_olrmnf@long_name)
delete(wh_olrmnf@standard_name)
delete(wh_olrmnf@units)
delete(wh_olrmfv@long_name)
delete(wh_olrmfv@standard_name)
delete(wh_olrmfv@units)
delete(wh_olrmnffv@long_name)
delete(wh_olrmnffv@standard_name)
delete(wh_olrmnffv@units)

;;---- plotting
outdir = "/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/wkfiltered_waves/fcst_verif/filterFcst_obs/"
outf = "hov_filterFcst_obs_fcstVerif_"+lats+"_"+latn 
wks = gsn_open_wks("pdf", outdir+outf)
gsn_define_colormap(wks,"sunshine_diff_12lev")   ; color map for olr
plot = new(2,graphic)
fcstline = new(3,graphic)

;; plot normal one
; gsnLeftString
wh_olrm@long_name = "Near real-time"
res@gsnStringFont = 0 ; font for gsnLeftString
res@gsnLeftStringFontHeightF = 0.01

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
overlay(plot1, plotf2)
overlay(plot1, plotf3)
overlay(plot1, plotf5)
overlay(plot1, plotf6)
overlay(plot1, plotf1)
overlay(plot1, plot2)
overlay(plot1, plot3)
overlay(plot1, plot5)
overlay(plot1, plot6)

; polyline
FcstL@gsLineLabelString = "Fcst Verification" ; string on polyline
fcstline(0) = gsn_add_polyline(wks, plot1, (/plon1, plon2/), (/dimsizes(perdfv)-1,dimsizes(perdfv)-1/), FcstL)
FcstL@gsLineLabelString = "Begin Fcst" ; string on polyline
fcstline(1) = gsn_add_polyline(wks, plot1, (/plon1, plon2/), (/dimsizes(perd)-1,dimsizes(perd)-1/), FcstL)

plot(0) = plot1


;; plot forecast verification
; Resizing the fcst verif plot match the time coordinate of normal one
res@vpHeightF = 0.485 ; resizing the fcst verif plot to 
res@vpWidthF = 0.6

; Update res for y coordinate
delete(tmPos)
delete(fts)
delete(tmPosF)
delete(mjtm_y_md)
delete(datey1)
delete(datey)
delete(dateyF)
delete(dunits)
delete(nthd_y)
delete(res@tmYLValues)
delete(res@tmYLLabels)
delete(mintkval)
delete(res@tmYLMinorValues)
tmPos = ispan(0,45,5) ; nth date (within two month) for major tickmark
fts = (/53,60/) ; time step for 14d forecast
tmPosF = array_append_record(tmPos, fts, 0) ; extend two weeks for forecast
mjtm_y_md = str_split_by_length(perdfv(tmPos),(/4,4/)) ; split date (yyyy, and mmdd) for major tickmark
datey1 = mjtm_y_md(:,1) ; yymm
datey = datey1 ; only showing near real-time result
dateyF = array_append_record( datey1, (/ "7d Fcst", "14d Fcst" /), 0 ) ; showing forecast
dunits = "days since "+dstart_s(0)+"-"+dstart_s(1)+"-"+dstart_s(2)+" 00:00:00"
nthd_y = new((/dimsizes(datey)/), "double")
res@tmYLMode   = "Explicit"
res@tmYLLabelFont = 0
res@tmYLValues = tmPosF ; for not showing forecast, use "tmPos"   
res@tmYLLabels = dateyF ; for not showing forecast, use "datey"   
;; Minor value
res@tmYLMinorOn = True ; turn on minor tick mark
mintkval = ispan(0, dimsizes(olrfv&time)-1, 1) ; cliSST ; create a array for minor tick mark that is labelled each day.
res@tmYLMinorValues = mintkval ; value for minor tickmark

; gsnLeftString
wh_olrmfv@long_name = "Forecast done before 2 weeks"
res@gsnStringFont = 0
res@gsnLeftStringFontHeightF = 0.012

plot1fv = gsn_csm_hov(wks, wh_olrmfv(:,{plon1:plon2}), res) ; wh04 olr anomaly
plotf1fv = gsn_csm_hov(wks, wh_olrmnffv(:,{plon1:plon2}), resf) ; olr anomaly forecast
plot2fv = gsn_csm_hov(wks, mjoolrmnffv(:,{plon1:plon2}), res2) ; mjo olr no fcst
plotf2fv = gsn_csm_hov(wks, mjoolrmfv(:,{plon1:plon2}), resf2) ; mjo olr
plot3fv = gsn_csm_hov(wks, kelolrmnffv(:,{plon1:plon2}), res3) ; kel olr no fcst
plotf3fv = gsn_csm_hov(wks, kelolrmfv(:,{plon1:plon2}), resf3) ; kel olr
plot5fv = gsn_csm_hov(wks, erolrmnffv(:,{plon1:plon2}), res5) ; er olr no fcst
plotf5fv = gsn_csm_hov(wks, erolrmfv(:,{plon1:plon2}), resf5) ; er olr
plot6fv = gsn_csm_hov(wks, mrgolrmnffv(:,{plon1:plon2}), res6) ; mrg olr no fcst
plotf6fv = gsn_csm_hov(wks, mrgolrmfv(:,{plon1:plon2}), resf6) ; mrg olr
overlay(plot1fv, plotf2fv)
overlay(plot1fv, plotf3fv)
overlay(plot1fv, plotf5fv)
overlay(plot1fv, plotf6fv)
overlay(plot1fv, plotf1fv)
overlay(plot1fv, plot2fv)
overlay(plot1fv, plot3fv)
overlay(plot1fv, plot5fv)
overlay(plot1fv, plot6fv)

; polyline
FcstL@gsLineLabelString = "Begin Fcst" ; string on polyline
fcstline(2) = gsn_add_polyline(wks, plot1fv, (/plon1, plon2/), (/dimsizes(perdfv)-1,dimsizes(perdfv)-1/), FcstL)

plot(1) = plot1fv

;; Panel plot
gsn_text_ndc(wks,"Contour level= "+kelolrm_sd+" for obs, 5 for fcst. MJO (black), Kelvin (blue), ER (red), MRG-TD (navy) ",0.5,0.2,txres)
gsn_text_ndc(wks,"Upper color bar is for observed OLR anomaly, while the lower on is for forecast period.",0.5,0.17,txres)
gsn_panel(wks,(/plot(0),plot(1)/),(/1,2/),resP)

;; Some text
;gsn_text_ndc(wks,"Obs: ",0.28,0.115,txres)
;gsn_text_ndc(wks,"Fcst: ",0.35,0.075,txres)
;gsn_text_ndc(wks,"Shaded area for forecast period is the sum of filtered OLR of each waves." ,0.5,0.06,txres)  

;; notification
print("output-> "+outf)
print(systemfunc("pwd"))

end
