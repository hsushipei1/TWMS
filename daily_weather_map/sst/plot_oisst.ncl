begin
print("%%%% Enter 'plot_olr_925wind.ncl' %%%% ")

;;----domain
lon1 = 39 
lon2 = 181
lats = -20
latn = 40
avg_d = 7 ; n days average

;;----read data
fils = systemfunc ("ls /data5/hsushipei/data/total_field/SST/noaa_oisst_v2/sst.day.mean.*.v2.nc")
f = addfiles (fils( dimsizes(fils)-2:dimsizes(fils)-1 ) , "r")
ListSetType (f, "cat")
sst = f[:]->sst(:,{lats:latn},{lon1:lon2})
rel_t = sst&time
ntime = dimsizes(rel_t)
printVarSummary(sst)

; convert relative to absolute time coordinate
abs_t = cd_calendar(rel_t, 2)

;;---- 7 day mean SST
sstm = dim_avg_Wrap( sst(lat|:, lon|:, time| ntime-avg_d : ntime-1  ))
printVarSummary(sstm)
delete(sst)

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
res@cnLevelSelectionMode = "ExplicitLevels"
res@cnLevels = (/21, 23, 25, 27, 27.5, 28, 29, 29.5, 30/)
;res@cnMinLevelValF = 170
;res@cnMaxLevelValF = 330
;res@cnLevelSpacingF = 20
res@lbLabelFont = 0 ; font for label bar
res@pmLabelBarHeightF = 0.06 ; height of color bar
res@pmLabelBarOrthogonalPosF = 0.1 ;  color bar y position
;res@gsnMaximize = True

txres = True
txres@txFontHeightF = 0.02 ; font height

mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.5

delete(sstm@long_name)
delete(sstm@units)

;;----plot
pltdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/sst/"
pltn = "oisst_latest"
res@tiMainString = avg_d+" Days Averaged OISST Centered on "+abs_t(ntime-4)
res@tiMainFont = 0 ; font
res@tiMainFontHeightF = 0.018 ; height of title font
wks = gsn_open_wks("pdf", pltdir+pltn)
gsn_define_colormap(wks,"precip2_17lev")   ; define color map
plot1 = gsn_csm_contour_map_ce(wks, sstm, res)
;gsn_text_ndc(wks,"kgm**-2",0.88,0.15,txres)
;dsloc = gsn_add_polymarker(wks, plot1, 116.73, 20.70, mkres) ; point out Dongsha
;nsloc = gsn_add_polymarker(wks, plot1, 114.36, 10.37, mkres) ; point out Nansha
EQ_line = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
draw(plot1)
frame(wks)

print("Plot created-> "+pltn)
;print("%%%% Leave 'plot_olr_925wind.ncl' at "+datee+" %%%% ")

end
