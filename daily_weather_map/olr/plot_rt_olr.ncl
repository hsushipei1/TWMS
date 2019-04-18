begin

;;----domain
lon1 = 39 
lon2 = 181
lats = -20
latn = 30
basevar = "olr"

;;----read data
print("%%%% Enter 'plot_rt_olr.ncl'. Plotting RT OLR... %%%% ")
f = addfile("/data5/hsushipei/data/total_field/OLR/realtime/latest.nc","r")
tt = f->time
ntime = dimsizes(tt)
olr = f->olr(ntime-1,{lats:latn},{lon1:lon2}) ;[nlat]x[nlon]
printVarSummary(olr)
;print(tt(ntime-1))

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
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
res@tmXBTickSpacingF = 20
res@tmYLTickSpacingF = 10
res@tmXBLabelFont = 0
res@tmXBLabelFontHeightF = 0.013
res@tmYLLabelFont = 0
res@tmYLLabelFontHeightF = 0.013
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 170
res@cnMaxLevelValF = 330
res@cnLevelSpacingF = 20
res@lbLabelFont = 0 ; font for label bar
res@pmLabelBarOrthogonalPosF = 0.1 ;  color bar y position
;res@gsnMaximize = True

delete(olr@long_name)
delete(olr@standard_name)
delete(olr@units)

;;----plot
res@tiMainFont = 0 ; height of title font
res@tiMainFontHeightF = 0.018 ; height of title font
res@tiMainString = "Real-time OLR on "+tt(ntime-1)
pltpath = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/olr/"
;pltn = "rt_olr_"+tt(ntime-1)
pltn = "rt_olr_latest"
plttyp = "pdf"
wks = gsn_open_wks(plttyp, pltpath+pltn)
gsn_define_colormap(wks,"MPL_rainbow")   ; define color map
plot1 = gsn_csm_contour_map_ce(wks, olr, res)
;gsn_text_ndc(wks,"kgm**-2",0.88,0.15,txres)
;dsloc = gsn_add_polymarker(wks, plot1, 116.73, 20.70, mkres) ; point out Dongsha
;nsloc = gsn_add_polymarker(wks, plot1, 114.36, 10.37, mkres) ; point out Nansha
line = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
draw(plot1)
frame(wks)

print("Plot created-> "+pltn+"."+plttyp)
;cp = systemfunc("cp "+pltpath+pltn+"."+plttyp+" "+pltpath+"rt_olr_latest."+plttyp) ; create a latest copy
print("%%%% Leave 'plot_rt_olr.ncl'. %%%% ")

end
