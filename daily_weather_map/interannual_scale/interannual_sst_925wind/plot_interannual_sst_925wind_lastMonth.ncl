begin

lon1 = 40
lon2 = 210
lats = -30
latn = 30

;;---- read data
f1 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_u925_latest.nc","r")
time = f1->time
obs_enddate = f1->obs_enddate ; end of obs data
eod_ind = ind(time.eq.obs_enddate) ; index of end of obs data
dstart = eod_ind - 30 ; begining of sst data
uinta = f1->u925_inta(dstart:eod_ind,{lats:latn},{lon1:lon2})  ; [ntime]x[nlat]x[nlon]
printVarSummary(uinta)

data_date = uinta&time

f2 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_v925_latest.nc","r")
vinta = f2->v925_inta(dstart:,{lats:latn},{lon1:lon2})  ; [ntime]x[nlat]x[nlon]

f3 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_sst_latest.nc","r")
sstinta = f3->sst_inta(dstart:,{lats:latn},{lon1:lon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(sstinta)

sstintam = dim_avg_n_Wrap(sstinta, 0)
uintam = dim_avg_n_Wrap(uinta, 0)
vintam = dim_avg_n_Wrap(vinta, 0)
printVarSummary(sstintam)
printVarSummary(uintam)
printVarSummary(vintam)

;;----resource
res=True
res@gsnDraw      = False                ; don't draw yet
res@gsnFrame     = False                ; don't advance frame yet
res@tiMainString = "SST and 925-hPa Wind Anomaly in Interannual scale Monthly Mean" ; title
res@tiMainFont =  22
res@tiMainFontHeightF = 0.015 ; height of title font
res@mpMinLatF    = lats       ; Set the domain of map (not the domain
res@mpMaxLatF    = latn       ; of data). If the data's domain is
res@mpMinLonF    = lon1       ; smaller than the map's, you'll see
res@mpMaxLonF    = lon2       ; blank(white) area on plot (missing).
res@mpCenterLonF = (lon1+lon2)/2 ; Center lon of this plot.
res@gsnAddCyclic = False ; if the map domain isn't global
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = (/-5, -4, -3, -2, -1, -0.5,0,  0.5, 1, 2, 3, 4, 5/)
;res@gsnMaximize = True
res@tmXBLabelFont = 21
res@tmXBLabelFontHeightF = 0.013
res@tmYLLabelFont = 21
res@tmYLLabelFontHeightF = 0.013
res@tmXBTickSpacingF = 30
res@tmYLTickSpacingF = 10
res@lbLabelFont = 21 ; font for label bar
res@lbLabelFontHeightF = 0.013 ; font size for labels on color bar
res@pmLabelBarHeightF = 0.06 ; height of color bar
res@pmLabelBarOrthogonalPosF = 0.13

res@gsnRightString = data_date(0)+"-"+data_date( dimsizes(data_date)-1 ) 
res@gsnRightStringFontHeightF = 0.014

res2=True
res2@gsnDraw      = False                ; don't draw yet
res2@gsnFrame     = False                ; don't advance frame yet
res2@gsnAddCyclic = False ; if the map domain isn't global
;res2@cnLinesOn =  ; turn off contour line
res2@cnLevelSelectionMode = "ExplicitLevels"
res2@cnLevels = (/0/)
res2@cnLabelMasking = True
res2@cnLineThicknessF = 1.5            ; Contour thickness
res2@cnLineLabelBackgroundColor = "transparent" ; background color of contour label
res2@cnLineLabelFontHeightF = 0.005       ; Font height of contour label
res2@cnInfoLabelOn = False  ; dont show contour info

res3 = True
res3@gsnDraw       = False                ; don't draw yet
res3@gsnFrame      = False                ; don't advance frame yet
res3@gsnAddCyclic  = False
;res@vcMinMagnitudeF      = 0.05    ;  arrow with magnitude under this value will not be drawn.
res3@vcRefLengthF         = 0.03    ;  length of unit reference vector
res3@vcRefMagnitudeF      =  5     ;  magnitude of the reference vector
res3@vcMinDistanceF       = 0.018    ;  Vector density: distance between arrows
res3@vcLineArrowHeadMinSizeF = 0.004
res3@vcLineArrowHeadMaxSizeF = 0.004
res3@vcLineArrowThicknessF = 2.5 ; arrow thickness
res3@vcRefAnnoFont = 21 ; font for vector reference annotation
res3@vcRefAnnoFontHeightF = 0.01 ; font height for vector reference annotation
res3@vcRefAnnoString2On = False ; turn off string "Reference vector" in vector ref annotation box
res3@vcRefAnnoOrthogonalPosF = -0.2 ; y coordinate of vector ref annotation box
res3@vcRefAnnoParallelPosF = 0.95 ; x coordinate of vector ref annotation box

txres = True
txres@txFontHeightF = 0.01 ; font height

mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.5

delete(sstintam@long_name)
delete(uintam@long_name)
delete(vintam@long_name)

;;---- create plot
outdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/interannual_scale/interannual_sst_925wind/"
plotfname = "interannual_sst_925wind_latestMonth" 

wks_type = "pdf"
wks_type@wkPaperWidthF  = 16.666666667  ; in inches
wks_type@wkPaperHeightF = 16.666666667  ; in inches

wks = gsn_open_wks(wks_type, outdir+plotfname)
gsn_define_colormap(wks,"NCV_blue_red")   ; define color map
plot1 = gsn_csm_contour_map_ce(wks, sstintam, res)
plot2 = gsn_csm_contour(wks, sstintam, res2) ; zero line for sst anomaly
plot3 = gsn_csm_vector(wks, uintam, vintam, res3) 
gsn_text_ndc(wks,"Apply previous 120 running avg to field whose slow annual cycle was already removed.(WH04)",0.5,0.25,txres)
line = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
;dsloc = gsn_add_polymarker(wks, plot1, 116.73, 20.70, mkres) ; point out Dongsha
;nsloc = gsn_add_polymarker(wks, plot1, 114.36, 10.37, mkres) ; point out Nansha
overlay(plot1, plot2)
overlay(plot1, plot3)
draw(plot1)
frame(wks)
print("Plot created-> "+plotfname)

end
