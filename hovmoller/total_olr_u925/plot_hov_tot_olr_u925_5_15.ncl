load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/kf_filter.ncl"
begin

lats = 5
latn = 15
plon1 = 39
plon2 = 181
variab = "olr_U925"

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

; total 925U
f11 = addfile("/data5/hsushipei/data/fnl/sliced/latest/daily/fnl025_u_201601_latest_daily.nc","r")
totu925 = f11->UGRD({perd},{925},{lats:latn},{plon1:plon2})
printVarSummary(totu925)

;; total 925V
;f12 = addfile("/data5/hsushipei/data/fnl/sliced/fnl025_v_20151101_201705_daily.nc","r")
;totv925 = f12->v({pdate1:pdate2},{92500},{lats:latn},{plon1:plon2})
;printVarSummary(totv925)

;;---- latitudinal mean
totolrm = dim_avg_n_Wrap(totolr,1)
totu925m = dim_avg_n_Wrap(totu925,1)
;totv925m = dim_avg_n_Wrap(totv925,1)
;printVarSummary(totolrm)
;printVarSummary(totu925m)
;printVarSummary(totv925m)

;;---- resource
res=True
;res@tiMainString  = tostring(des_t(n))
res@gsnDraw   = False
res@gsnFrame  = False
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
res@cnLevelSelectionMode = "manuallevels"
res@cnMinLevelValF = 170 ; 150  ; tot OLR
res@cnMaxLevelValF = 330  ; tot OLR
res@cnLevelSpacingF =  20  ; tot OLR
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
mjtm_y_m_d = tointeger(str_split_by_length(perd(tmPos),(/4,2,2/))) ; split date (yyyy, mm and dd) for major tickmark
mjtm_y_md = str_split_by_length(perd(tmPos),(/4,4/)) ; split date (yyyy, and mmdd) for major tickmark
datey1 = mjtm_y_md(:,1) ; yymm
datey = datey1
dunits = "days since "+dstart_s(0)+"-"+dstart_s(1)+"-"+dstart_s(2)+" 00:00:00"
res@tmYLMode   = "Explicit"
res@tmYLLabelFont = 0
res@tmYLLabelFontHeightF = 0.015
res@tmYLValues = tmPos   ; OLR 
res@tmYLLabels = datey    ; OLR
;; Minor value
res@tmYLMinorOn = True ; turn on minor tick mark
mintkval = ispan(0, dimsizes(totolr&time)-1, 1) ; cliSST ; create a array for minor tick mark that is labelled each day.
res@tmYLMinorValues = mintkval ; value for minor tickmark
res@tmYLLabelFontHeightF = 0.01

res@lbLabelFont = 0 ; Font for labels on color bar
res@lbLabelFontHeightF = 0.013 ; font size for labels on color bar
res@pmLabelBarHeightF = 0.06 ; height of color bar
res@pmLabelBarOrthogonalPosF = 0.04 ; y position of color bar

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
res7@cnLevels = ispan(-15,15,3)
res7@trYReverse = True ; reverse y-axis

txres = True
txres@txFontHeightF = 0.008 ; font height
txres@txFont = 0 ; font 

;;---- plotting
delete(totolrm@long_name)
delete(totolrm@standard_name)
delete(totolrm@units)
delete(totu925m@long_name)
delete(totu925m@standard_name)
delete(totu925m@units)

res@tiMainString = "Hovmoller for Latest OLR and U925 "+lats+" to "+latn
outdir = "/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/total_olr_u925/"
outf = "hov_tot_olr_u925_latest_"+lats+"_"+latn 
res@tiMainFontHeightF = 0.015 ; height of title font
res@tiMainFont =  13
wks = gsn_open_wks("pdf", outdir+outf)
gsn_define_colormap(wks,"MPL_rainbow")   ; color map for olr
plot1 = gsn_csm_hov(wks, totolrm(:,{plon1:plon2}), res) ; total OLR
plot7 = gsn_csm_hov(wks, totu925m(:,{plon1:plon2}), res7) ; tot u925
overlay(plot1, plot7)
draw(plot1)
frame(wks)
print("output-> "+outf)
print(systemfunc("pwd"))

end
