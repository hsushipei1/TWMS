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
totolr = f->olr(tstart:tend,{lats:latn},{plon1:plon2}) ;[ntime]x[nlat]x[nlon]
printVarSummary(totolr)
perd = totolr&time ; plot period
dstart_s = str_split_by_length(perd(0),(/4,2,2/))

;; Kel olr 
f2 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_Kelvin_olr_latest.nc","r")
kelolr = f2->olr({perd},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(kelolr)

; MJO olr
f3 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_MJO_olr_latest.nc","r")
mjoolr = f3->olr({perd},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(mjoolr)

; er olr
f5 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_ER_olr_latest.nc","r")
erolr = f5->olr({perd},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
delete(erolr@missing_value)
printVarSummary(erolr)

; mrg olr 
f7 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_MRG_olr_latest.nc","r")
mrgolr = f7->olr({perd},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(mrgolr)

;; WH04 olr anomaly
;f10 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_olr_latest.nc","r")
;wh_olr = f10->olr({perd(0:58)},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
;printVarSummary(wh_olr)

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
;wh_olrm = dim_avg_n_Wrap(wh_olr,1)

printVarSummary(totolrm)
printVarSummary(kelolrm)
printVarSummary(mjoolrm)
printVarSummary(erolrm)
printVarSummary(mrgolrm)
;printVarSummary(wh_olrm)

;;; OLR standard deviation of each waves
kelolrm_sd = 10
mjoolrm_sd =10 
erolrm_sd = 10
mrgolrm_sd = 15

;;---- resource
res=True
;res@tiMainString  = tostring(des_t(n))
res@gsnDraw   = False
res@gsnFrame  = False
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
res@cnLevelSelectionMode = "manuallevels"
res@cnMinLevelValF = 170  ; tot OLR
res@cnMaxLevelValF = 330  ; tot OLR
res@cnLevelSpacingF =  20  ; tot OLR
;res@cnLevelSelectionMode = "explicitlevels" ; anomaly (WH04)
;res@cnLevels = (/ -80, -60, -40, -20, 20, 40, 60, 80 /)  ; anomaly (WH04)
;res@cnLevels = -ispan(-80,80,10)  ; anomaly (WH04)
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
mjtm_y_md = str_split_by_length(perd(tmPos),(/4,4/)) ; split date (yyyy, and mmdd) for major tickmark
datey1 = mjtm_y_md(:,1) ; yymm
datey = datey1
dunits = "days since "+dstart_s(0)+"-"+dstart_s(1)+"-"+dstart_s(2)+" 00:00:00"
nthd_y = new((/dimsizes(datey)/), "double")
res@tmYLMode   = "Explicit"
res@tmYLLabelFont = 0
res@tmYLValues = tmPos   ; OLR 
res@tmYLLabels = datey    ; OLR
;; Minor value
res@tmYLMinorOn = True ; turn on minor tick mark
mintkval = ispan(0, dimsizes(totolr&time)-1, 1) ; cliSST ; create a array for minor tick mark that is labelled each day.
res@tmYLMinorValues = mintkval ; value for minor tickmark
res@tmYLLabelFontHeightF = 0.01
res@lbLabelFont = 0  ; Font for labels on color bar
res@lbLabelFontHeightF = 0.01 ; font size for labels on color bar
res@pmLabelBarHeightF = 0.06 ; height of color bar
res@pmLabelBarOrthogonalPosF = 0.03

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
res2@cnLineColor = "blue"
res2@cnLineLabelsOn = False
res2@cnLineLabelFont = 0
res2@cnLineLabelBackgroundColor = "transparent"
res2@cnLineLabelFontHeightF = 0.005
res2@cnLineLabelPlacementMode = "Computed"
res2@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
res2@gsnContourZeroLineThicknessF = 0
res2@gsnContourNegLineDashPattern = 6
res2@cnLevelSelectionMode = "explicitlevels"
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
res3@cnLineColor = "black"
res3@cnLineLabelsOn = False
res3@cnLineLabelFont = 0
res3@cnLineLabelBackgroundColor = "transparent"
res3@cnLineLabelFontHeightF = 0.007
res3@gsnContourZeroLineThicknessF = 0
res3@gsnContourNegLineDashPattern = 6
res3@cnLevelSelectionMode = "explicitlevels"
res3@cnLevels = (/-4*mjoolrm_sd,-3*mjoolrm_sd, -2*mjoolrm_sd, -mjoolrm_sd, \
                     mjoolrm_sd, 2*mjoolrm_sd, 3*mjoolrm_sd, 4*mjoolrm_sd/) ; both positive and negative value

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

; Marker for TC's position
mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.0
;mkres@gsMarkerColor = pcol

; TC's track
trres = True

txres = True
txres@txFontHeightF = 0.008 ; font height
txres@txFont = 0 ; font 

;;---- plotting
delete(totolrm@long_name)
delete(totolrm@standard_name)
delete(totolrm@units)
delete(kelolrm@long_name)
delete(kelolrm@standard_name)
delete(kelolrm@units)
delete(mjoolrm@long_name)
delete(mjoolrm@standard_name)
delete(mjoolrm@units)
delete(erolrm@long_name)
delete(erolrm@standard_name)
delete(erolrm@units)
delete(mrgolrm@long_name)
delete(mrgolrm@standard_name)
delete(mrgolrm@units)
;delete(totu925m@long_name)
;delete(totu925m@standard_name)
;delete(totu925m@units)
;delete(wh_olrm@long_name)
;delete(wh_olrm@standard_name)
;delete(wh_olrm@units)

res@tiMainString = "Hovmoller for Filtered and Total OLR "+lats+" to "+latn
outdir = "/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/wkfiltered_waves/olr/"
outf = "hov_wkfilter_olr_latest_"+lats+"_"+latn 
res@tiMainFontHeightF = 0.015 ; height of title font
res@tiMainFont =  13
wks = gsn_open_wks("pdf", outdir+outf)
;gsn_define_colormap(wks,"sunshine_diff_12lev")   ; color map for olr
gsn_define_colormap(wks,"MPL_rainbow")   ; color map for olr
;gsn_define_colormap(wks,"precip2_17lev")   ; precipitation or sst
plot1 = gsn_csm_hov(wks, totolrm(:,{plon1:plon2}), res) ; total OLR
;plot1 = gsn_csm_hov(wks, wh_olrm({pdate1:pdate2},{plon1:plon2}), res) ; wh04 olr anomaly
plot2 = gsn_csm_hov(wks, kelolrm(:,{plon1:plon2}), res2) ; kel olr
plot3 = gsn_csm_hov(wks, mjoolrm(:,{plon1:plon2}), res3) ; mjo olr
plot5 = gsn_csm_hov(wks, erolrm(:,{plon1:plon2}), res5) ; er olr
plot6 = gsn_csm_hov(wks, mrgolrm(:,{plon1:plon2}), res6) ; mrg olr
;plot7 = gsn_csm_hov(wks, totu925m({pdate1:pdate2},{plon1:plon2}), res7) ; tot u925
;TC1 = gsn_add_polymarker(wks, plot1, lontc1,datetc1 , mkres) ; TC1 position
;TC2 = gsn_add_polymarker(wks, plot1, lontc2,datetc2 , mkres) ; TC2 position
;BV = gsn_add_polymarker(wks, plot1, lontc3,datetc3, mkres) ; Borneo vortex position
;TD = gsn_add_polymarker(wks, plot1, lontc4,datetc4, mkres) ; TD position
;TC1tr = gsn_add_polyline(wks, plot1, lontc1,datetc1, trres) ; TC track
;TC2tr = gsn_add_polyline(wks, plot1, lontc2,datetc2, trres) ; TC track
;BVtr = gsn_add_polyline(wks, plot1, lontc3,datetc3, trres) ; Borneo vortex track
;TDtr = gsn_add_polyline(wks, plot1, lontc4,datetc4, trres) ; TD track
overlay(plot1, plot2)
overlay(plot1, plot3)
;overlay(plot1, plot4)
overlay(plot1, plot5)
overlay(plot1, plot6)
;overlay(plot1, plot7)
;overlay(plot1, plot8)
;overlay(plot1, plot9)
;overlay(plot1, plot10)
;gsn_text_ndc(wks,"Contour lev: ER= "+erolrm_sd+" MRG= "+mrgolrm_sd ,0.65,0.14,txres)
gsn_text_ndc(wks,"Contour level: MRG/TD (navy)= "+mrgolrm_sd+", MJO, ER and Kelvin= "+kelolrm_sd ,0.5,0.14,txres)
;gsn_text_ndc(wks,"Anomaly: remove first 3 harmonics of annual cycle and apply 120d running average" ,0.5,0.01,txres) ; sst contour level 
draw(plot1)
frame(wks)
print("output-> "+outf)
print(systemfunc("pwd"))

end
