begin

;;----domain
lon1 = 39 
lon2 = 181
lats = -20
latn = 30
plev = 925 ; unit: hPa
;datee = getenv("DATE")
;datee = 2017063000

;;----read data
f3 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_pw_latest.nc","r")
tt = f3->time
ntime = dimsizes(tt)
pw = f3->pw(ntime-1,{lats:latn},{lon1:lon2}) ;[nlat]x[nlon]
datee = pw@time ; latest
printVarSummary(pw)

print("%%%% Enter 'plot_pw_925wind_anomaly.ncl' at "+datee+" %%%% ")
f = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_u"+plev+"_latest.nc","r")
f2 = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_v"+plev+"_latest.nc","r")
u = f->u925({datee},{lats:latn},{lon1:lon2})
v = f2->v925({datee},{lats:latn},{lon1:lon2})
printVarSummary(u)
printVarSummary(v)

;;----resource
res=True
res@gsnDraw      = False                ; don't draw yet
res@gsnFrame     = False                ; don't advance frame yet
res@mpMinLatF    = lats       ; Set the domain of map (not the domain
res@mpMaxLatF    = latn       ; of data). If the data's domain is
res@mpMinLonF    = lon1       ; smaller than the map's, you'll see
res@mpMaxLonF    = lon2       ; blank(white) area on plot (missing).
res@mpCenterLonF = (lon1+lon2)/2 ; Center lon of this plot.
res@gsnAddCyclic = False ; if the map domain isn't global
res@tmXBTickSpacingF = 20
res@tmYLTickSpacingF = 10
res@tmXBLabelFont = 0
res@tmXBLabelFontHeightF = 0.013
res@tmYLLabelFont = 0
res@tmYLLabelFontHeightF = 0.013
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
res@cnLevelSelectionMode = "explicitlevels" ; anomaly (WH04)
res@cnLevels = (/-20, -17, -14, -11, -8,-5, -2,2,5,8,11,14,17,20/)  ; anomaly (WH04)
;resf@cnFillColors = (/2,3,4,5,6,8,10,11,12,13,14/) ; directly choose color from color bar by its index
;res@gsnMaximize = True
res@lbLabelFont = 0 ; font for label bar
res@lbLabelFontHeightF = 0.01 ; font size for labels on color bar
res@pmLabelBarHeightF = 0.06 ; height of color bar
res@pmLabelBarWidthF = 0.55 ; height of color bar
res@pmLabelBarOrthogonalPosF = 0.1

; reverse color map
cmap = read_colormap_file("GMT_polar")
res@cnFillPalette =   cmap(::-1,:)

res2 = True
res2@gsnDraw       = False                ; don't draw yet
res2@gsnFrame      = False                ; don't advance frame yet
res2@gsnAddCyclic  = False
;res2@vcMinMagnitudeF      = 0.05    ;  arrow with magnitude under this value will not be drawn.
res2@vcRefLengthF         = 0.02    ;  length of unit reference vector
res2@vcRefMagnitudeF      =  10.    ;  magnitude of the reference vector
res2@vcMinDistanceF       = 0.015    ;  Vector density: distance between arrows
res2@vcLineArrowHeadMinSizeF = 0.003
res2@vcLineArrowHeadMaxSizeF = 0.003
res2@vcRefAnnoOrthogonalPosF = 0.2 ; y position of vector reference annotation
res2@vcRefAnnoFont = 0 ; font for vector reference annotation
res2@vcRefAnnoFontHeightF = 0.008 ; font height for vector reference annotation
res2@vcRefAnnoString2On = False ; turn off string "Reference vector" in vector ref annotation box
res2@vcRefAnnoOrthogonalPosF = -0.2 ; y coordinate of vector ref annotation box
res2@vcRefAnnoParallelPosF = 0.95 ; x coordinate of vector ref annotation box

txres = True
txres@txFont = 0
txres@txFontHeightF = 0.008 ; font height
txres@txFuncCode    = ":"

mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.5

delete(pw@long_name)
delete(pw@standard_name)
delete(pw@units)
delete(u@long_name)
delete(v@long_name)
delete(u@units)
delete(v@units)

;;----plot
pltdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/pw_wind_anomaly/"
pltn = "pw_fnl025_925wind_anomaly_latest"
res@tiMainString = "Latest NCEP FNL PW 925-hPa Wind Anomaly on "+datee
res@tiMainFont = 0 ; font
res@tiMainFontHeightF = 0.015 ; height of title font
wks = gsn_open_wks("pdf", pltdir+pltn)
;gsn_define_colormap(wks,"sunshine_diff_12lev")   ; define color map
plot1 = gsn_csm_contour_map_ce(wks, pw, res)
plot2 = gsn_csm_vector(wks,u, v, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
gsn_text_ndc(wks,"kg:F18:V"+":F0:m"+":S:-2",0.78,0.29,txres)
;gsn_text_ndc(wks,"kgm**-2",0.88,0.15,txres)
;dsloc = gsn_add_polymarker(wks, plot1, 116.73, 20.70, mkres) ; point out Dongsha
;nsloc = gsn_add_polymarker(wks, plot1, 114.36, 10.37, mkres) ; point out Nansha
EQ_line = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
draw(plot1)
frame(wks)

print("Plot created-> "+pltn)
print("%%%% Leave 'plot_pw_925wind_anomaly.ncl' at "+datee+" %%%% ")

end
