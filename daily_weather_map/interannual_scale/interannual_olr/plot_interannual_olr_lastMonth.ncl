begin

lon1 = 40
lon2 = 210
lats = -30
latn = 30

;;---- read data
f1 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_olr_latest.nc","r")
time = f1->time
obs_enddate = f1->obs_enddate ; end of obs data
eod_ind = ind(time.eq.obs_enddate) ; index of end of obs data
dstart = eod_ind - 30 ; begining of sst data
olrinta = f1->olr_inta(dstart:eod_ind,{lats:latn},{lon1:lon2})  ; [ntime]x[nlat]x[nlon]
printVarSummary(olrinta)

data_date = olrinta&time

olrintam = dim_avg_n_Wrap(olrinta, 0)
printVarSummary(olrintam)

;;----resource
res=True
res@gsnDraw      = False                ; don't draw yet
res@gsnFrame     = False                ; don't advance frame yet
res@tiMainString = "Monthly Mean Interannual OLR Anomaly" ; title
res@tiMainFont = 22
res@tiMainFontHeightF = 0.015 ; height of title font
res@mpMinLatF    = lats       ; Set the domain of map (not the domain
res@mpMaxLatF    = latn       ; of data). If the data's domain is
res@mpMinLonF    = lon1       ; smaller than the map's, you'll see
res@mpMaxLonF    = lon2       ; blank(white) area on plot (missing).
res@mpCenterLonF = (lon1+lon2)/2 ; Center lon of this plot.
res@gsnAddCyclic = False ; false if the map domain isn't global
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
;res@cnLevelSelectionMode = "ManualLevels"
;res@cnMinLevelValF = -80
;res@cnMaxLevelValF = 80
;res@cnLevelSpacingF = 20
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = (/-75,-60,-45,-30,-15,-5,5,15,30,45,60,75/)
;res@cnFillColors = (/2,3,4,5,6,7,9,10,11,12,13,14/) ; directly choose color from color bar by its index

;res@gsnMaximize = True
res@tmXBTickSpacingF = 30
res@tmYLTickSpacingF = 10
res@tmXBLabelFont = 21
res@tmXBLabelFontHeightF = 0.015
res@tmYLLabelFont = 21
res@tmYLLabelFontHeightF = 0.015
res@lbLabelFont = 21 ; font for label bar
res@lbLabelFontHeightF = 0.013 ; font size for labels on color bar
res@pmLabelBarHeightF = 0.06 ; height of color bar
res@pmLabelBarOrthogonalPosF = 0.15

res@gsnRightString = data_date(0)+"-"+data_date( dimsizes(data_date)-1 )
res@gsnRightStringFontHeightF = 0.014

txres = True
txres@txFontHeightF = 0.01 ; font height

mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.5

delete(olrintam@long_name)
;delete(olrsacm@units)

;;---- create plot
outdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/interannual_scale/interannual_olr/"
plotfname = "interannual_olr_latestMonth"

wks_type = "pdf"
wks_type@wkPaperWidthF  = 16.666666667  ; in inches
wks_type@wkPaperHeightF = 16.666666667  ; in inches

wks = gsn_open_wks(wks_type, outdir+plotfname)
gsn_define_colormap(wks,"sunshine_diff_12lev")   ; define color map
plot1 = gsn_csm_contour_map_ce(wks, olrintam, res)
gsn_text_ndc(wks,"Apply previous 120 running avg to field whose slow annual cycle was already removed.(WH04)",0.5,0.24,txres)
line = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
;dsloc = gsn_add_polymarker(wks, plot1, 116.73, 20.70, mkres) ; point out Dongsha
;nsloc = gsn_add_polymarker(wks, plot1, 114.36, 10.37, mkres) ; point out Nansha
draw(plot1)
frame(wks)
print("Plot created-> "+plotfname)

end
