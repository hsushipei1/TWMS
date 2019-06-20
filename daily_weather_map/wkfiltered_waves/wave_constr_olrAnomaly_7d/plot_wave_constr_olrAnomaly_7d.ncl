load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/kf_filter.ncl"
begin

lats = -20
latn = 20
plon1 = 39
plon2 = 181

;;---- read data
; OLR anomaly
f = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_olr_latest.nc","r")
time = f->time
ntime = dimsizes(time)
tend = ntime-1 ; latest olr time step (end)
tstart = tend-6 ; time step of two months ago (start)
olra = f->olr(tstart:tend,{lats:latn},{plon1:plon2}) ;[ntime]x[nlat]x[nlon]
printVarSummary(olra)
perd = olra&time ; plot period
dstart_s = str_split_by_length(perd(0),(/4,2,2/))

; kelvin wave olr 
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

;; Sum of OLR from all filtered waves
solr = kelolr
solr = kelolr+mjoolr+erolr+mrgolr
delete(solr@wavenumber)
delete(solr@period)
delete(solr@depth)
delete(solr@waveName)
solr@long_name = "OLR summed from all filtered waves"
printVarSummary(solr)

;;---- resource
; olr anomaly
res=True
res@gsnDraw      = False                ; don't draw yet
res@gsnFrame     = False                ; don't advance frame yet
res@mpMinLatF    = lats       ; Set the domain of map (not the domain
res@mpMaxLatF    = latn       ; of data). If the data's domain is
res@mpMinLonF    = plon1       ; smaller than the map's, you'll see
res@mpMaxLonF    = plon2       ; blank(white) area on plot (missing).
res@mpCenterLonF = (plon1+plon2)/2 ; Center lon of this plot.
res@gsnAddCyclic = False ; if the map domain isn't global
;res@tiMainString = "test"
res@tiMainFont = 0
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
res@tmXBTickSpacingF = 20
res@tmXBLabelFont = 0
res@tmXBLabelFontHeightF = 0.015
res@tmYLTickSpacingF = 10
res@tmYLLabelFont = 0
res@tmYLLabelFontHeightF = 0.015
res@cnLevelSelectionMode = "explicitlevels"
res@cnLevels = (/-75,-60,-45,-30,-15,15,30,45,60,75/)  ; anomaly (WH04)
res@cnFillColors = (/2,3,4,5,6,8,10,11,12,13,14/) ; directly choose color from color bar by its index
;res@cnLevels = -ispan(-80,80,10)  ; anomaly (WH04)
;res@gsnMaximize = True ; maximize plot 
res@lbLabelBarOn  = False  ; turn off individual color bar
res@cnLineLabelFontHeightF = 1. ; seems to remove contour labels as individual color bars are removed

; resource for panel 
resP = True
resP@gsnMaximize = True ; maximize plot
resP@gsnPanelLabelBar = True ; adds a common label bar at the bottom of the plot
resP@lbLabelFont = 0 ; font type of labels of common color bar  
resP@lbLabelFontHeightF = 0.005 ; font height of labels of common color bar  
resP@pmLabelBarOrthogonalPosF = -0.007 ; y position of label bar
resP@txString = "OLR Summed from Waves/OLR Anomaly" ; add common title
resP@txFontHeightF = 0.012 ; font size for common title
resP@txFont = 13 ; font for common title

; resource for text
txres = True
txres@txFontHeightF = 0.006 ; font height
txres@txFont = 0 ; font
txres@txFontColor = "black" ; font

;;---- plotting
delete(olra@long_name)
delete(olra@units)
delete(solr@long_name)
delete(solr@units)

outdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/wave_constr_olrAnomaly_7d/"
outf = "wave_constrOLR_cf_olrAnomaly_7d"
;wks = gsn_open_wks("svg", outf)
wks = gsn_open_wks("pdf", outdir+outf)
gsn_define_colormap(wks,"sunshine_diff_12lev")   ; color map for olr
plot1 = new(dimsizes(perd),graphic) ; olr summed by waves
plot2 = new(dimsizes(perd),graphic) ; olr anomaly
lines1 = new(dimsizes(perd),graphic)
lines2 = new(dimsizes(perd),graphic)

do p = 0, dimsizes(perd)-1
	olra@long_name = tostring(tointeger(perd(p)))
	solr@long_name = tostring(tointeger(perd(p)))
	plot1(p) = gsn_csm_contour_map_ce(wks, solr(p,{lats:latn},{plon1:plon2}), res) 
	plot2(p) = gsn_csm_contour_map_ce(wks, olra(p,{lats:latn},{plon1:plon2}), res) 
	lines1(p) = gsn_add_polyline(wks, plot1(p), (/plon1, plon2/), (/0,0/), False)
	lines2(p) = gsn_add_polyline(wks, plot2(p), (/plon1, plon2/), (/0,0/), False)
end do
gsn_text_ndc(wks,"Waves included: MJO, Kelvin, ER, and MRG/TD" ,0.5,0.023,txres)
gsn_panel(wks,(/plot1(0),plot2(0),plot1(1),plot2(1),plot1(2),plot2(2),plot1(3),plot2(3),\
					plot1(4),plot2(4),plot1(5),plot2(5),plot1(6),plot2(6)/),(/7,2/),resP)

print("output-> "+outf)
print(systemfunc("pwd"))

end
