load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/kf_filter.ncl"
begin

lats = -20
latn = 20
plon1 = 39
plon2 = 181
wave = "kelvin"

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

;; Extended Period for Wave Prediction
; extend end point of real time data to include period for wave prediction
dend = time(tend) ; end date of realtime data
dend_s = tointeger(str_split_by_length(dend,(/4,2,2/))) ; separated end date, yyyymmdd 
dsince = "days since "+dend_s(0)+"-"+dend_s(1)+"-"+dend_s(2)+" 00:00:00" ; days since end of current time
tfcst = ispan(1, 7, 1)
tfcst@units = dsince
dfcst = new((/dimsizes(tfcst)/), typeof(perd)) ; date for forecast period
do qq = 0, dimsizes(tfcst)-1
    dfcst(qq) = cd_calendar(tfcst(qq), 2)
end do
copy_VarAtts( perd, dfcst )

; "perd2" includes period for one-week forecast
perd2 = array_append_record(perd, dfcst, 0)

;; Kel olr 
f2 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_Kelvin_olr_latest.nc","r")
wolr = f2->olr({perd2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(wolr)

;; other waves (for summed olr in forecast period)
; MJO olr
f3 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_MJO_olr_latest.nc","r")
w1olr = f3->olr({dfcst},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(w1olr)

; er olr
f5 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_ER_olr_latest.nc","r")
w2olr = f5->olr({dfcst},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(w2olr)

; mrg olr 
f7 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_MRG_olr_latest.nc","r")
w3olr = f7->olr({dfcst},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(w3olr)

;; Summer OLR from all filtered waves for one-week forecast
solr = w2olr
solr = wolr({dfcst},:,:)+w1olr+w2olr+w3olr
delete(solr@wavenumber)
delete(solr@period)
delete(solr@depth)
delete(solr@waveName)
solr@long_name = "OLR summed from all filtered waves used for one-week forecast"
printVarSummary(solr)

;; merge real-time observed OLR anomaly with OLR summed from all filtered waves
olra2 = array_append_record( olra, solr, 0 )
delete(olra)
olra = olra2
delete(olra2)
printVarSummary(olra)

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
;res@cnLevels = -ispan(-80,80,10)  ; anomaly (WH04)
res@cnLevels = (/-75,-60,-45,-30,-15,15,30,45,60,75/)  ; anomaly (WH04)
res@cnFillColors = (/2,3,4,5,6,8,10,11,12,13,14/) ; directly choose color from color bar by its index
;res@gsnMaximize = True ; maximize plot 
res@lbLabelBarOn  = False  ; turn off individual color bar
res@cnLineLabelFontHeightF = 1. ; seems to remove contour labels as individual color bars are removed

; wave olr
res2 = True
res2@gsnDraw   = False
res2@gsnFrame  = False
;res2@cnFillOn  = True ; turn on contour fill
;res2@cnLinesOn = False ; turn off contour line
res2@cnLineThicknessF = 1.3
res2@cnLabelMasking = True
res2@cnInfoLabelOn = False
res2@cnInfoLabelFont = 0
res2@cnLineColor = "blue3"
res2@cnLineLabelsOn = False
res2@cnLineLabelFont = 0
res2@cnLineLabelBackgroundColor = "transparent"
res2@cnLineLabelFontHeightF = 0.005
res2@cnLineLabelPlacementMode = "Computed"
res2@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
res2@gsnContourZeroLineThicknessF = 0
res2@gsnContourNegLineDashPattern = 5
res2@cnLevelSelectionMode = "explicitlevels"
res2@cnLevels = ispan(-40,40,10) ; both positive and negative value

; resource for panel 
resP = True
resP@gsnMaximize = True ; maximize plot
resP@gsnPanelLabelBar = True ; adds a common label bar at the bottom of the plot
resP@lbLabelFont = 0 ; font type of labels of common color bar  
resP@lbLabelFontHeightF = 0.005 ; font height of labels of common color bar  
resP@pmLabelBarOrthogonalPosF = -0.007 ; y position of label bar
resP@txString = "Filtered Kelvin Wave OLR on OLR anomaly: Observed/Forecast" ; add common title
resP@txFontHeightF = 0.012 ; font size for common title
resP@txFont = 13 ; font for common title

; resource for text
txres = True
txres@txFontHeightF = 0.006 ; font height
txres@txFont = 0 ; font
txres@txFontColor = res2@cnLineColor ; font

;;---- plotting
delete(olra@long_name)
delete(olra@units)
delete(wolr@long_name)
delete(wolr@units)

outdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/on_OLRanoamly_7d/"
outf = wave+"_olr_onOLRanomaly_7d"
;wks = gsn_open_wks("svg", outf)
wks = gsn_open_wks("pdf", outdir+outf)
gsn_define_colormap(wks,"sunshine_diff_12lev")   ; color map for olr
plot = new(dimsizes(perd2),graphic) ; create plot array
lines = new(dimsizes(perd2),graphic)

do p = 0, dimsizes(perd2)-1 ; one-week observation + onw-week forecast (Wheeler and Weickmann 2001)
if (p.ge.7) then
	delete(res2@cnLevels)
    delete(res@cnLevels)
    delete(res@cnFillColors)
    res@cnLevels = (/-75,-60,-45,-30,-15,-5,5,15,30,45,60,75/)  ; anomaly (WH04)
    res@cnFillColors = (/2,3,4,5,6,7,8,9,10,11,12,13,14/) ; directly choose color from color bar by its index
	res2@cnLevels = ispan(-40,40,5) ; both positive and negative value
end if
	olra@long_name = tostring(tointeger(perd2(p)))
	plot1 = gsn_csm_contour_map_ce(wks, olra(p,{lats:latn},{plon1:plon2}), res) ; total OLR
	plot2 = gsn_csm_contour(wks, wolr(p,{lats:latn},{plon1:plon2}), res2) ; Kel U
	overlay(plot1, plot2)
	lines(p) = gsn_add_polyline(wks, plot1, (/plon1, plon2/), (/0,0/), False)
	plot(p) = plot1
end do
gsn_text_ndc(wks,"Contour level= 10 for obs, 5 for fcst. In forecast period, level 5 to 15 is added for shaded area and lighter color are used." ,0.5,0.023,txres)
;gsn_panel(wks,plot,(/dimsizes(perd),2/),resP)
;gsn_text_ndc(wks,"OLR anomaly for forecast is the sum of all waves",0.4,0.025,txres)
gsn_panel(wks,(/plot(0),plot(7),plot(1),plot(8),plot(2),plot(9),plot(3),plot(10),plot(4),\
					plot(11),plot(5),plot(12),plot(6),plot(13)/),(/7,2/),resP)

print("output-> "+outf)
print(systemfunc("pwd"))

end
