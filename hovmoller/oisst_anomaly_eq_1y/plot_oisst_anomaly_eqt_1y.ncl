begin

lon1 = 39   ; WNP
lon2 = 281
lats = -5
latn = 5

;; read data
; Real time data 
f = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_sst_latest.nc","r")
totntime = dimsizes( f->time )
ssta = f->sst( :, {lats:latn},{lon1:lon2} ) ; 365d x lat x lon

rel_t = ssta&time
ntime = dimsizes( rel_t )
abs_t = cd_calendar(rel_t, 2) ; convert relative to absolute time
ssta&time = abs_t 
printVarSummary(ssta)

;;---- latitudinal mean & 9d running average
sstam =  runave_n_Wrap( dim_avg_n_Wrap( ssta, 1 ), 9, 0, 0)
printVarSummary(sstam)

;;---- resource
res=True
;res@tiMainString  = tostring(des_t(n))
res@gsnDraw   = False
res@gsnFrame  = False
res@tiMainString = "OISST Anomaly between 5~S~~F34~0~N~~F22~S - 5~S~~F34~0~N~~F22~N"
res@tiMainFontHeightF = 0.015 ; height of title font
res@tiMainFont =  22
res@cnFillOn  = True ; turn on contour fill
;res@cnLinesOn = False ; turn off contour line
res@gsnContourNegLineDashPattern = 6
res@cnLevelSelectionMode = "manuallevels"
res@cnMinLevelValF = -3.5
res@cnMaxLevelValF = 3.5
res@cnLevelSpacingF =  0.5
res@tmXBTickSpacingF = 30
res@tmXBLabelFont = 21
res@tmXBLabelFontHeightF = 0.013
res@tmXBMinorOn = True ; turn on minor tick mark
;res@tmXBMinorValues = ispan(60, 180, 10) ; specify minor tick mark
res@tmXBMinorValues = ispan(0, 360, 10) ; specify minor tick mark
res@trYReverse = True ; reverse y-axis

;; Y axis: date
;; Major value
yyyymmdd = str_split_by_length( abs_t, (/4,2,2/) )
first_of_m_ind = ind( yyyymmdd(:,2).eq."01" ) ; index of the first day of month

res@tmYLMode   = "Explicit"
res@tmYLLabelFont = 21
res@tmYLValues = first_of_m_ind
res@tmYLLabels = tostring( tointeger( abs_t( first_of_m_ind ) ) )
;; Minor value
;res@tmYLMinorOn = True ; turn on minor tick mark
;mintkval = ispan(0, dimsizes(sst_abst)-1, 1) ; cliSST ; create a array for minor tick mark that is labelled each day.
;res@tmYLMinorValues = mintkval ; value for minor tickmark
res@tmYLLabelFontHeightF = 0.013
res@lbLabelFont = 21  ; Font for labels on color bar
res@lbLabelFontHeightF = 0.013 ; font size for labels on color bar
res@pmLabelBarHeightF = 0.06 ; height of color bar
res@pmLabelBarOrthogonalPosF = -0.007

res@gsnRightString = "9d running avg"
res@gsnStringFontHeightF = 0.013
res@gsnStringFont = 21

txres = True
txres@txFont = 21
txres@txFontHeightF = 0.012 ; font height

delete(sstam@long_name)
delete(sstam@units)
outdir = "/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/oisst_anomaly_eq_1y/"
outf = "hov_ssta_9dAvg_latest"

wks_type = "pdf"
wks_type@wkPaperWidthF  = 16.666666667  ; in inches
wks_type@wkPaperHeightF = 16.666666667  ; in inches

wks = gsn_open_wks(wks_type, outdir+outf)
gsn_define_colormap(wks,"NCV_blue_red")   ; color map for olr
plot1 = gsn_csm_hov(wks, sstam, res) ; total OLR
gsn_text_ndc(wks,"Climatology: 1981 to 2015",0.65,0.10,txres)
draw(plot1)
frame(wks)


end
