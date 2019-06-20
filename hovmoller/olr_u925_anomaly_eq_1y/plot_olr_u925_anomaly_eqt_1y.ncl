begin

lon1 = 39   ; WNP
lon2 = 281
lats = -5
latn = 5

;; read data
; Real time data 
f1 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_olr_latest.nc","r")
ntime = dimsizes( f1->time )
dstart = ntime-365
olra = f1->olr(dstart:ntime-16,{lats:latn},{lon1:lon2}) ; only RT part (exclude GFS)
printVarSummary(olra)

f2 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_u925_latest.nc","r")
ua = f2->u925(dstart:ntime-16,{lats:latn},{lon1:lon2})
printVarSummary(ua)

olram = runave_n_Wrap( dim_avg_n_Wrap( olra, 1 ), 9, 0, 0)  
uam = runave_n_Wrap( dim_avg_n_Wrap( ua, 1 ), 9, 0, 0)  
printVarSummary(olram)

abst = olra&time

;;---- resource
res=True
;res@tiMainString  = tostring(des_t(n))
res@gsnDraw   = False
res@gsnFrame  = False
res@tiMainString = "OLR and U925 Anomaly between 5~S~~F34~0~N~~F22~S - 5~S~~F34~0~N~~F22~N"
res@tiMainFontHeightF = 0.015 ; height of title font
res@tiMainFont =  22
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
res@cnLevelSelectionMode = "explicitlevels"
res@cnLevels = (/-75,-60,-45,-30,-15,-5,5,15,30,45,60,75/)
res@tmXBTickSpacingF = 30
res@tmXBLabelFont = 21
res@tmXBLabelFontHeightF = 0.013
res@tmXBMinorOn = True ; turn on minor tick mark
;res@tmXBMinorValues = ispan(60, 180, 10) ; specify minor tick mark
res@tmXBMinorValues = ispan(0, 360, 10) ; specify minor tick mark
res@trYReverse = True ; reverse y-axis

;; Y axis: date
;; Major value
yyyymmdd = str_split_by_length( abst, (/4,2,2/) )
first_of_m_ind = ind( yyyymmdd(:,2).eq."01" ) ; index of the first day of month

res@tmYLMode   = "Explicit"
res@tmYLLabelFont = 21
res@tmYLValues = first_of_m_ind
res@tmYLLabels = tostring( tointeger( abst( first_of_m_ind ) ) )
;; Minor value
;res@tmYLMinorOn = True ; turn on minor tick mark
;mintkval = ispan(0, dimsizes(abst)-1, 1) ; cliSST ; create a array for minor tick mark that is labelled each day.
;res@tmYLMinorValues = mintkval ; value for minor tickmark
res@tmYLLabelFontHeightF = 0.013
res@lbLabelFont = 21  ; Font for labels on color bar
res@lbLabelFontHeightF = 0.013 ; font size for labels on color bar
res@pmLabelBarHeightF = 0.06 ; height of color bar
res@pmLabelBarOrthogonalPosF = -0.003

res@gsnRightString = "9d running avg"
res@gsnStringFontHeightF = 0.013
res@gsnStringFont = 21

res2 = True
res2 = True
res2@gsnDraw   = False
res2@gsnFrame  = False
;res2@cnFillOn  = True ; turn on contour fill
;res2@cnLinesOn = False ; turn off contour line
res2@cnLineThicknessF = 2.3
;res2@cnLabelMasking = True
res2@cnInfoLabelOn = False
res2@cnLineLabelsOn = False
;res2@cnInfoLabelFont = 0
res2@cnLineColor = "black"
res2@gsnContourZeroLineThicknessF = 0
res2@gsnContourNegLineDashPattern = 11
res2@cnLevelSelectionMode = "explicitlevels"
res2@cnLevels = (/-6,-4,-2,2,4,6/)

txres = True
txres@txFont = 21
txres@txFontHeightF = 0.012 ; font height

delete(olram@long_name)
delete(olram@units)
delete(uam@long_name)
delete(uam@units)
outdir = "/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/olr_u925_anomaly_eq_1y/"
outf = "hov_olr_u925_anomaly_9dAvg_latest"

wks_type = "pdf"
wks_type@wkPaperWidthF  = 16.666666667  ; in inches
wks_type@wkPaperHeightF = 16.666666667  ; in inches

wks = gsn_open_wks(wks_type, outdir+outf)
gsn_define_colormap(wks,"sunshine_diff_12lev")   ; color map for olr
plot1 = gsn_csm_hov(wks, olram, res) ; total OLR
plot2 = gsn_csm_contour(wks, uam, res2) 
overlay(plot1, plot2)
gsn_text_ndc(wks,"Climatology: 1979 to 2013",0.65,0.09,txres)
gsn_text_ndc(wks,"U925 contour level: every 2 ms~S~-1~N~ up to 6 ms~S~-1~N~",0.5,0.07,txres)
draw(plot1)
frame(wks)


end
