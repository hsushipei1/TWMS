load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/kf_filter.ncl"
begin

lats = -5
latn = 5
plon1 = 39
plon2 = 181
variab = "olr_U925"
;variab = "olr"
;variab = "SST"
;variab = "TRMM_Pcp"
pdate1 = 20170401 ; plot domain
pdate2 = 20170630

; Modes 
;waveName = "Kelvin"
;waveName = "Kelvin_MJO"
;waveName = "MJO"
;waveName = "ER"
;waveName = "MRG"
;waveName = "ER_MRG"
waveName = "Total"
;waveName = "Climatology"
;waveName = "Anomaly" ; WH04 (annaul cycle and interannual scale are removed)

lcolor = "blue"
lcolor2 = "black"
lcolor3 = "red"
lcolor4 = "navy"
lcolor5 = "gray20"
pcol = "coral2" ; TC's position

;;---- read data
; real-time data (no leap day)
; TRMM precipitation
;f9 = addfile("/data5/hsushipei/data/total_field/Precip/trmm/2016/trmm_preci_025_20160701_20161231_3hr.nc","r")
;pcp = f9->pcp({20161201:20161231.875},{plon1:plon2},{lats:latn})  ; [ntime]x[nlon]x[nlat]
;printVarSummary(pcp)

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

; SST
f17 = addfile("/data5/hsushipei/data/total_field/SST/noaa_oisst_v2/latest.nc","r")
totsst = f17->sst({pdate1:pdate2},{lats:latn},{plon1:plon2}) ;[ntime]x[nlat]x[nlon]
printVarSummary(totsst)

;; Kel olr 
f2 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/wk99_filt_Kelvin_olr_20160605_20170604.nc","r")
kelolr = f2->olr({pdate1:pdate2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(kelolr)

; MJO olr
f3 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/wk99_filt_MJO_olr_20160605_20170604.nc","r")
mjoolr = f3->olr({pdate1:pdate2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
delete(mjoolr@missing_value)
printVarSummary(mjoolr)

; er olr
;f5 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/wk99_filt_ER_olr_20160101_20161231.nc","r")
f5 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/wk99_filt_ER_olr_20160625_20170624.nc","r")
erolr = f5->olr({pdate1:pdate2},{5:15},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
delete(erolr@missing_value)
printVarSummary(erolr)

;; Kel U
;f4 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/wk99_filt_Kelvin_u925_20160101_latest.nc","r")
;kelu = f4->u925({pdate1:pdate2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
;kelu@_FillValue = -9999999999
;delete(kelu@missing_value)
;printVarSummary(kelu)

;; Kel V
;v925 = new(dimsizes(kelu),typeof(kelu))
;v925 = 0.0
;copy_VarCoords(kelu, v925)
;printVarSummary(v925)

;f6 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/wk99_filt_Kelvin_v925_20160101_latest.nc","r")
;v925 = f6->v925({pdate1:pdate2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
;v925@_FillValue = -9999999999
;delete(v925@missing_value)
;printVarSummary(v925)

; mrg olr 
f7 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/wk99_filt_MRG_olr_20160605_20170604.nc","r")
mrgolr = f7->olr({pdate1:pdate2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(mrgolr)

;; WH04 U925 anomaly  
f8 = addfile("/data5/hsushipei/data/wh04_data/field_data/wh04field_u925_20160628_20170627_mean.nc","r")
;f8 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_olr_latest.nc","r")
wh_u = f8->u925({pdate1:pdate2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(wh_u)
;
;; WH04 V925 anomaly
;f9 = addfile("/data5/hsushipei/data/wh04_data/field_data/wh04field_v925_20170101_20170531_mean.nc","r")
;wh_v = f9->v925({pdate1:pdate2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
;printVarSummary(wh_v)
;
;; WH04 olr anomaly
f10 = addfile("/data5/hsushipei/data/wh04_data/field_data/wh04field_olr_20160626_20170625_mean.nc","r")
wh_olr = f10->olr({pdate1:pdate2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(wh_olr)

; total 925U
f11 = addfile("/data5/hsushipei/data/fnl/sliced/latest/daily/fnl025_u_201601_latest_daily.nc","r")
totu925 = f11->UGRD({perd},{925},{lats:latn},{plon1:plon2})
printVarSummary(totu925)

;; total 925V
;f12 = addfile("/data5/hsushipei/data/fnl/sliced/fnl025_v_20151101_201705_daily.nc","r")
;totv925 = f12->v({pdate1:pdate2},{92500},{lats:latn},{plon1:plon2})
;printVarSummary(totv925)

;; Climatology olr
f13 = addfile("/data5/hsushipei/data/daily_climatology/olr/olr_1979_2013_daily_climatology.nc","r")
cliolr = f13->olr({20000401:20000630},{lats:latn},{plon1:plon2})
printVarSummary(cliolr)

;; Climatology sst
f16 = addfile("/data5/hsushipei/data/daily_climatology/sst/sst_1982_2016_daily_climatology.nc","r")
clisst = f16->sst({20000401:20000630},{lats:latn},{plon1:plon2})
;clisst = f16->sst(:,{lats:latn},{plon1:plon2})
printVarSummary(clisst)

;; Climatology total 925U
f14 = addfile("/data5/hsushipei/data/daily_climatology/u/u_925_1979_2015_daily_climatology.nc","r")
cliu925 = f14->u({20000401:20000630},{lats:latn},{plon1:plon2})
printVarSummary(cliu925)

; Climatology total 925V
f15 = addfile("/data5/hsushipei/data/daily_climatology/v/v_925_1979_2015_daily_climatology.nc","r")
cliv925 = f15->v({20000401:20000630},{lats:latn},{plon1:plon2})
printVarSummary(cliv925)

;;---- latitudinal mean
;pcpm = dim_avg_n_Wrap(pcp,2)
kelolrm = dim_avg_n_Wrap(kelolr,1)
mjoolrm = dim_avg_n_Wrap(mjoolr,1)
;kelum = dim_avg_n_Wrap(kelu,1)
;v925m = dim_avg_n_Wrap(v925,1)
erolrm = dim_avg_n_Wrap(erolr,1)
totolrm = dim_avg_n_Wrap(totolr,1)
totsstm = dim_avg_n_Wrap(totsst,1)
mrgolrm = dim_avg_n_Wrap(mrgolr,1)
totu925m = dim_avg_n_Wrap(totu925,1)
;totv925m = dim_avg_n_Wrap(totv925,1)
cliolrm = dim_avg_n_Wrap(cliolr,1)
clisstm = dim_avg_n_Wrap(clisst,1)
cliu925m = dim_avg_n_Wrap(cliu925,1)
cliv925m = dim_avg_n_Wrap(cliv925,1)
wh_um = dim_avg_n_Wrap(wh_u,1)
;wh_vm = dim_avg_n_Wrap(wh_v,1)
wh_olrm = dim_avg_n_Wrap(wh_olr,1)

;printVarSummary(pcpm)
printVarSummary(totolrm)
;printVarSummary(kelolrm)
printVarSummary(mjoolrm)
;printVarSummary(kelum)
printVarSummary(erolrm)
;printVarSummary(mrgolrm)
;printVarSummary(totu925m)
;printVarSummary(totv925m)
;printVarSummary(wh_um)
;printVarSummary(wh_vm)
;printVarSummary(wh_olrm)

;;; OLR standard deviation of each waves
;kelolrm_sd = stddev(kelolrm({rt_t},:))
;kelolrm_sd = 11.15
kelolrm_sd = 10
;mjoolrm_sd = stddev(mjoolrm({rt_t},:))
mjoolrm_sd = kelolrm_sd
;erolrm_sd = stddev(erolrm({rt_t},:))
erolrm_sd = 10
;mrgolrm_sd = stddev(mrgolrm({rt_t},:))
mrgolrm_sd = 10
;print("==========================================")
print("kelolrm SD= "+kelolrm_sd)
;print("mjoolrm SD= "+mjoolrm_sd)
print("erolrm SD= "+erolrm_sd)
;print("mrgolrm SD= "+mrgolrm_sd)
;print("==========================================")

;;---- resource
res=True
;res@tiMainString  = tostring(des_t(n))
res@gsnDraw   = False
res@gsnFrame  = False
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
res@cnLevelSelectionMode = "manuallevels"
;res@cnMinLevelValF = 0.5 ; trmm pcp
;res@cnMaxLevelValF = 4.5  ; trmm pcp
;res@cnLevelSpacingF =  0.5  ; trmm pcp
res@cnMinLevelValF = 170 ; 150  ; tot OLR
res@cnMaxLevelValF = 330  ; tot OLR
res@cnLevelSpacingF =  20  ; tot OLR
;res@cnLevelSelectionMode = "explicitlevels" ; anomaly (WH04)
;res@cnLevels = (/ -80, -60, -40, -20, 20, 40, 60, 80 /)  ; anomaly (WH04)
;res@cnLevels = -ispan(-90,90,15)  ; anomaly (WH04)
;res@cnLevelSelectionMode = "explicitlevels" ; total/Climatology sst
;res@cnLevels = (/25,27,27.5,28,28.5,29,29.5,30,30.5,31 /)  ; total/Climatology sst
res@tmXBTickSpacingF = 20
res@tmXBLabelFont = 0
res@tmXBLabelFontHeightF = 0.013
res@tmXBMinorOn = True ; turn on minor tick mark
;res@tmXBMinorValues = ispan(60, 180, 10) ; specify minor tick mark
res@tmXBMinorValues = ispan(0, 360, 10) ; specify minor tick mark
res@trYReverse = True ; reverse y-axis
res@lbLabelFont = 0 ; Font for labels on color bar
res@lbLabelFontHeightF = 0.013 ; font size for labels on color bar

;; Y axis: date
;; Major value
; Rules: Show major tickmark every 5 days, and most importantly, tickmark of "tend" must be shown. For the rest of 
; the tickmarks, insert it every 5 days when counting down from "tend".
; Total period: 60 days (0 to 59)
tmPos = ispan(0,60,5) ; nth date (within two month) for major tickmark
mjtm_y_m_d = tointeger(str_split_by_length(perd(tmPos),(/4,2,2/))) ; split date (yyyy, mm and dd) for major tickmark
mjtm_y_md = str_split_by_length(perd(tmPos),(/4,4/)) ; split date (yyyy, and mmdd) for major tickmark
datey1 = mjtm_y_md(:,1) ; yymm
datey = datey1
dunits = "days since "+dstart_s(0)+"-"+dstart_s(1)+"-"+dstart_s(2)+" 00:00:00"
datey_split = tointeger(str_split_by_length(datey, (/4,2,2/))) ; (year, month, day)
nthd_y = new((/dimsizes(datey)/), "double")
do d = 0, dimsizes(datey)-1
    nthd_y(d) = cd_inv_calendar(mjtm_y_m_d(d,0),mjtm_y_m_d(d,1), mjtm_y_m_d(d,2),0,0,0, dunits, 0) 
	; nth day since "dunits", used for major 
end do
res@tmYLMode   = "Explicit"
res@tmYLLabelFont = 0
res@tmYLLabelFontHeightF = 0.015
;res@tmYLValues = nthd_y*8  ; precipitation ; value for major tickmark
;res@tmYLLabels = datey     ; precipitation ; label for major tickmark
;res@tmYLValues = nthd_y   ; OLR 
res@tmYLValues = tmPos   ; OLR 
res@tmYLLabels = datey    ; OLR
;; Minor value
res@tmYLMinorOn = True ; turn on minor tick mark
;mintkval = ispan(0, dimsizes(totolrm&time)-1, 1) ; OLR ; create a array for minor tick mark that is labelled each day.
mintkval = ispan(0, dimsizes(totolr&time)-1, 1) ; cliSST ; create a array for minor tick mark that is labelled each day.
;mintkval = ispan(0, dimsizes(pcpm&time)-1, 8) ; pcp ;  create a array for minor tick mark that is labelled each day.
res@tmYLMinorValues = mintkval ; value for minor tickmark
res@tmYLLabelFontHeightF = 0.01

res@pmLegendDisplayMode    = "Always"  ; turn on legend
res@pmLegendSide           = "Bottom"  ; Change location of

; kel olr
res2 = True
res2@gsnDraw   = False
res2@gsnFrame  = False
;res2@cnFillOn  = True ; turn on contour fill
;res2@cnLinesOn = False ; turn off contour line
res2@cnLineThicknessF = 1.5
res2@cnLabelMasking = True
res2@cnInfoLabelOn = False
res2@cnInfoLabelFont = 0
res2@cnLineColor = lcolor
res2@cnLineLabelsOn = False
res2@cnLineLabelFont = 0
res2@cnLineLabelBackgroundColor = "transparent"
res2@cnLineLabelFontHeightF = 0.005
res2@cnLineLabelPlacementMode = "Computed"
res2@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
res2@gsnContourZeroLineThicknessF = 0
res2@gsnContourNegLineDashPattern = 6
;res2@cnLevelSelectionMode = "manuallevels"
;res2@cnMinLevelValF = ceil(-stddev(kelolrm({rt_t},:)))
;res2@cnMaxLevelValF = 0
;res2@cnLevelSpacingF = (-res2@cnMinLevelValF)/2.
res2@cnLevelSelectionMode = "explicitlevels"
;res2@cnLevels = -1*(/4*kelolrm_sd,3*kelolrm_sd, 2*kelolrm_sd, kelolrm_sd/)
res2@cnLevels = (/-4*kelolrm_sd,-3*kelolrm_sd, -2*kelolrm_sd, -kelolrm_sd, \
                     kelolrm_sd, 2*kelolrm_sd, 3*kelolrm_sd, 4*kelolrm_sd/) ; both positive and negative value

; MJO olr
res3 = True
res3@gsnDraw   = False
res3@gsnFrame  = False
;res3@cnFillOn  = True ; turn on contour fill
;res3@cnLinesOn = False ; turn off contour line
res3@cnLineThicknessF = 1.5
res3@cnLabelMasking = True
res3@cnInfoLabelOn = False
res3@cnInfoLabelFont = 0
res3@cnLineColor = lcolor2
res3@cnLineLabelsOn = False
res3@cnLineLabelFont = 0
res3@cnLineLabelBackgroundColor = "transparent"
res3@cnLineLabelFontHeightF = 0.007
res3@gsnContourZeroLineThicknessF = 0
res3@gsnContourNegLineDashPattern = 6
;res3@cnLevelSelectionMode = "manuallevels"
;res3@cnMinLevelValF = -30
;res3@cnMaxLevelValF = 30
;res3@cnLevelSpacingF =  6
res3@cnLevelSelectionMode = "explicitlevels"
;res3@cnLevels = -1*(/4*mjoolrm_sd,3*mjoolrm_sd, 2*mjoolrm_sd, mjoolrm_sd/)
res3@cnLevels = (/-4*mjoolrm_sd,-3*mjoolrm_sd, -2*mjoolrm_sd, -mjoolrm_sd, \
                     mjoolrm_sd, 2*mjoolrm_sd, 3*mjoolrm_sd, 4*mjoolrm_sd/) ; both positive and negative value
;res3@cnLevels = (/-20, -15, -10, -5/)

; Kel 925 wind
res4 = True
;res4@gsnDraw   = False
;res4@gsnFrame  = False
res4@vcRefLengthF    = 0.005    ;  length of unit reference vector
res4@vcRefMagnitudeF =  0.61   ;  magnitude of the reference vector
res4@vcMinDistanceF  = 0.01    ;  Vector density: distance between arrows
res4@vcMinMagnitudeF = 0.61
res4@vcLineArrowHeadMinSizeF = 0.003
res4@vcLineArrowHeadMaxSizeF = 0.003

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
res5@cnLineColor = lcolor3
res5@cnLineLabelsOn = False
res5@cnLineLabelFont = 0
res5@cnLineLabelBackgroundColor = "transparent"
res5@cnLineLabelFontHeightF = 0.007
res5@gsnContourZeroLineThicknessF = 0
res5@gsnContourNegLineDashPattern = 6
res5@cnLevelSelectionMode = "explicitlevels"
;res5@cnLevels = -1*(/4*erolrm_sd,3*erolrm_sd, 2*erolrm_sd, erolrm_sd/) ; only negative value
res5@cnLevels = (/-4*erolrm_sd,-3*erolrm_sd, -2*erolrm_sd, -erolrm_sd, \
                     erolrm_sd, 2*erolrm_sd, 3*erolrm_sd, 4*erolrm_sd/) ; both positive and negative value
;res5@cnLevelSelectionMode = "manuallevels"
;res5@cnMinLevelValF = -stddev(erolrm({rt_t},:)) 
;res5@cnMaxLevelValF = 0
;res5@cnLevelSpacingF =  -res5@cnMinLevelValF

; mrg olr
res6 = True
res6@gsnDraw   = False
res6@gsnFrame  = False
;res6@cnFillOn  = True ; turn on contour fill
;res6@cnLinesOn = False ; turn off contour line
res6@cnLineThicknessF = 1.5
res6@cnLabelMasking = True
res6@cnInfoLabelOn = False
res6@cnInfoLabelFont = 0
res6@cnLineColor = lcolor4
res6@cnLineLabelsOn = False
res6@cnLineLabelFont = 0
res6@cnLineLabelBackgroundColor = "transparent"
res6@cnLineLabelFontHeightF = 0.007
res6@gsnContourZeroLineThicknessF = 0
res6@gsnContourNegLineDashPattern = 6
res6@cnLevelSelectionMode = "ExplicitLevels"
;res6@cnLevels = -1*(/4*mrgolrm_sd,3*mrgolrm_sd, 2*mrgolrm_sd, mrgolrm_sd/)
res6@cnLevels = (/-4*mrgolrm_sd,-3*mrgolrm_sd, -2*mrgolrm_sd, -mrgolrm_sd, \
                     mrgolrm_sd, 2*mrgolrm_sd, 3*mrgolrm_sd, 4*mrgolrm_sd/) ; both positive and negative value
;res6@cnLevelSelectionMode = "manuallevels"
;res6@cnMinLevelValF = -stddev(mrgolrm({rt_t},:)) 
;res6@cnMaxLevelValF = 0
;res6@cnLevelSpacingF =  -res6@cnMinLevelValF

; total u925
res7 = True
res7@gsnDraw   = False
res7@gsnFrame  = False
;res7@cnFillOn  = True ; turn on contour fill
;res7@cnLinesOn = False ; turn off contour line
res7@cnLineThicknessF = 1.5
res7@cnLabelMasking = True
res7@cnInfoLabelFont = 0
res7@cnLineColor = lcolor5 
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

; total 925 wind field
res9 = True
;res9@gsnDraw   = False
;res9@gsnFrame  = False
res9@vcRefLengthF    = 0.02    ;  length of unit reference vector
res9@vcRefMagnitudeF =  10   ;  magnitude of the reference vector
res9@vcMinDistanceF  = 0.01    ;  Vector density: distance between arrows
res9@vcMinMagnitudeF = 2
res9@vcLineArrowHeadMinSizeF = 0.003
res9@vcLineArrowHeadMaxSizeF = 0.003
res9@trYReverse = True

; WH04 wind anomaly
res8 = True
;res8@gsnDraw   = False
;res8@gsnFrame  = False
res8@vcRefLengthF    = 0.02    ;  length of unit reference vector
res8@vcRefMagnitudeF =  5   ;  magnitude of the reference vector
res8@vcMinDistanceF  = 0.01    ;  Vector density: distance between arrows
res8@vcMinMagnitudeF = 2
res8@vcLineArrowHeadMinSizeF = 0.003
res8@vcLineArrowHeadMaxSizeF = 0.003

; Marker for TC's position
mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.0
mkres@gsMarkerColor = pcol

; TC's track
trres = True

txres = True
txres@txFontHeightF = 0.008 ; font height
txres@txFont = 0 ; font 

;;---- plotting
;delete(pcpm@long_name)
;delete(pcpm@standard_name)
;delete(pcpm@units)
;delete(pcpm@hdf_name)
delete(totolrm@long_name)
delete(totolrm@standard_name)
delete(totolrm@units)
delete(totsstm@long_name)
delete(totsstm@standard_name)
delete(totsstm@units)
delete(kelolrm@long_name)
delete(kelolrm@standard_name)
delete(kelolrm@units)
delete(mjoolrm@long_name)
delete(mjoolrm@standard_name)
delete(mjoolrm@units)
;;delete(kelum@long_name)
;;delete(kelum@standard_name)
;;delete(kelum@units)
delete(erolrm@long_name)
delete(erolrm@standard_name)
delete(erolrm@units)
delete(mrgolrm@long_name)
delete(mrgolrm@standard_name)
delete(mrgolrm@units)
delete(totu925m@long_name)
delete(totu925m@standard_name)
delete(totu925m@units)
delete(cliu925m@long_name)
delete(cliu925m@standard_name)
delete(cliu925m@units)
delete(cliolrm@long_name)
delete(cliolrm@standard_name)
delete(cliolrm@units)
delete(clisstm@long_name)
delete(clisstm@standard_name)
delete(clisstm@units)
delete(wh_olrm@long_name)
delete(wh_olrm@standard_name)
;delete(wh_olrm@units)
delete(wh_um@long_name)
delete(wh_um@standard_name)
;delete(wh_um@units)

;res@tiMainString = waveName+"_"+variab+"_"+lats+"_"+latn
res@tiMainString = "Hovmoller for Latest OLR and U925"
;res@tiMainString = "Total_OLR_U925_"+lats+"_"+latn
;res@tiMainString = waveName+"Total_OLR_U925_"+lats+"_"+latn
;res@tiMainString = "Total_"+lats+"_"+latn+"_"+variab+"_RT_spacetime_filtered_"+waveName
;outf = pdate1+"_"+pdate2+"_"+res@tiMainString
outf = "hov_tot_olr_u925_latest" 
res@tiMainFontHeightF = 0.018 ; height of title font
res@tiMainFont =  13
;wks = gsn_open_wks("pdf", outf)
wks = gsn_open_wks("svg", outf)
;gsn_define_colormap(wks,"sunshine_diff_12lev")   ; color map for olr
gsn_define_colormap(wks,"MPL_rainbow")   ; color map for olr
;gsn_define_colormap(wks,"MPL_jet")   ; color map for olr
;gsn_define_colormap(wks,"precip2_17lev")   ; precipitation or sst
plot1 = gsn_csm_hov(wks, totolrm({pdate1:pdate2},{plon1:plon2}), res) ; total OLR
;plot1 = gsn_csm_hov(wks, cliolrm(:,{plon1:plon2}), res) ; Climatology total OLR
;plot1 = gsn_csm_hov(wks, pcpm({:},{plon1:plon2}), res) ; precipitation
;plot1 = gsn_csm_hov(wks, wh_olrm({pdate1:pdate2},{plon1:plon2}), res) ; wh04 olr anomaly
;plot1 = gsn_csm_hov(wks, totsstm({pdate1:pdate2},{plon1:plon2}), res) ; total SST
;plot1 = gsn_csm_hov(wks, clisstm({20000401:20000630},{plon1:plon2}), res) ; Climatology SST
;plot2 = gsn_csm_hov(wks, kelolrm({pdate1:pdate2},{plon1:plon2}), res2) ; kel olr
;plot3 = gsn_csm_hov(wks, mjoolrm({pdate1:pdate2},{plon1:plon2}), res3) ; mjo olr
;plot4 = gsn_csm_vector(wks, kelum({pdate1:pdate2},{plon1:plon2}), v925m({pdate1:pdate2},{plon1:plon2}), res4) ; Kel U
;plot5 = gsn_csm_hov(wks, erolrm({pdate1:pdate2},{plon1:plon2}), res5) ; er olr
;plot6 = gsn_csm_hov(wks, mrgolrm({pdate1:pdate2},{plon1:plon2}), res6) ; mrg olr
plot7 = gsn_csm_hov(wks, totu925m({pdate1:pdate2},{plon1:plon2}), res7) ; tot u925
;plot7 = gsn_csm_contour(wks, totu925m({pdate1:pdate2},{plon1:plon2}), res7) ; tot u925
;plot7 = gsn_csm_contour(wks, wh_um({pdate1:pdate2},{plon1:plon2}), res7) ; anomalous u925 (WH04)
;plot8 = gsn_csm_vector(wks, wh_um({pdate1:pdate2},{plon1:plon2}),-wh_vm({pdate1:pdate2},{plon1:plon2}), res8) ; WH04
;plot9 = gsn_csm_vector(wks, totu925m({pdate1:pdate2},{plon1:plon2}),-totv925m({pdate1:pdate2},{plon1:plon2}), res9) ; 925wind
;plot10 = gsn_csm_hov(wks, cliu925m(:,{plon1:plon2}), res7) ; Climatology tot u925
;TC1 = gsn_add_polymarker(wks, plot1, lontc1,datetc1 , mkres) ; TC1 position
;TC2 = gsn_add_polymarker(wks, plot1, lontc2,datetc2 , mkres) ; TC2 position
;BV = gsn_add_polymarker(wks, plot1, lontc3,datetc3, mkres) ; Borneo vortex position
;TD = gsn_add_polymarker(wks, plot1, lontc4,datetc4, mkres) ; TD position
;TC1tr = gsn_add_polyline(wks, plot1, lontc1,datetc1, trres) ; TC track
;TC2tr = gsn_add_polyline(wks, plot1, lontc2,datetc2, trres) ; TC track
;BVtr = gsn_add_polyline(wks, plot1, lontc3,datetc3, trres) ; Borneo vortex track
;TDtr = gsn_add_polyline(wks, plot1, lontc4,datetc4, trres) ; TD track
;overlay(plot1, plot2)
;overlay(plot1, plot3)
;overlay(plot1, plot4)
;overlay(plot1, plot5)
;overlay(plot1, plot6)
overlay(plot1, plot7)
;overlay(plot1, plot8)
;overlay(plot1, plot9)
;overlay(plot1, plot10)
;line1 = gsn_add_polyline(wks, plot1, (/plon1, plon2/), (/30,30/), False)
;line2 = gsn_add_polyline(wks, plot1, (/plon1, plon2/), (/61,61/), False)
;gsn_text_ndc(wks,"Contour lev: ER= "+erolrm_sd+" MRG= "+mrgolrm_sd ,0.65,0.14,txres)
;gsn_text_ndc(wks,"Contour lev: MJO= "+mjoolrm_sd+" KW= "+kelolrm_sd ,0.65,0.14,txres)
;gsn_text_ndc(wks,"Contour lev: 25,27,27.5,28,28.5,29,29.5,30,30.5,31" ,0.5,0.14,txres) ; sst contour level 
;gsn_text_ndc(wks,"Anomaly: remove first 3 harmonics of annual cycle and apply 120d running average" ,0.5,0.01,txres) ; sst contour level 
draw(plot1)
frame(wks)
print("output-> "+outf)
print(systemfunc("pwd"))

end
