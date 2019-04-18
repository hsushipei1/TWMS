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

; kelvin wave olr 
f2 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_Kelvin_olr_latest.nc","r")
kelolr = f2->olr({perd2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(kelolr)

; MJO olr
f3 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_MJO_olr_latest.nc","r")
mjoolr = f3->olr({perd2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(mjoolr)

; er olr
f5 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_ER_olr_latest.nc","r")
erolr = f5->olr({perd2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
delete(erolr@missing_value)
printVarSummary(erolr)

; mrg olr 
f7 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_MRG_olr_latest.nc","r")
mrgolr = f7->olr({perd2},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(mrgolr)

;; Sum of OLR from all filtered waves
solr = kelolr({dfcst},:,:)
solr = kelolr({dfcst},:,:)+mjoolr({dfcst},:,:)+erolr({dfcst},:,:)+mrgolr({dfcst},:,:)
delete(solr@wavenumber)
delete(solr@period)
delete(solr@depth)
delete(solr@waveName)
solr@long_name = "OLR summed from all filtered waves"
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
res@cnLevels = (/-75,-60,-45,-30,-15,15,30,45,60,75/)  ; anomaly (WH04)
res@cnFillColors = (/2,3,4,5,6,8,10,11,12,13,14/) ; directly choose color from color bar by its index
;res@cnLevels = -ispan(-80,80,10)  ; anomaly (WH04)
;res@gsnMaximize = True ; maximize plot 
res@lbLabelBarOn  = False  ; turn off individual color bar
res@cnLineLabelFontHeightF = 1. ; seems to remove contour labels as individual color bars are removed

; wave olr
; Kelvin
res2 = True
res2@gsnDraw   = False
res2@gsnFrame  = False
;res2@cnFillOn  = True ; turn on contour fill
;res2@cnLinesOn = False ; turn off contour line
res2@cnLineThicknessF = 1.
res2@cnLabelMasking = True
res2@cnInfoLabelOn = False
res2@cnInfoLabelFont = 0
res2@cnLineColor = "blue"
res2@cnLineLabelsOn = False
res2@cnLineLabelFont = 0
res2@cnLineLabelBackgroundColor = "transparent"
res2@cnLineLabelFontHeightF = 0.005
res2@cnLineLabelPlacementMode = "Computed"
res2@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
res2@gsnContourZeroLineThicknessF = 0
res2@gsnContourNegLineDashPattern = 6
res2@cnLevelSelectionMode = "explicitlevels"
res2@cnLevels = (/-40, -30, -20, -10, 10, 20, 30 ,40/) ; both positive and negative value

; ER
res3 = True
res3@gsnDraw   = False
res3@gsnFrame  = False
;res2@cnFillOn  = True ; turn on contour fill
;res2@cnLinesOn = False ; turn off contour line
res3@cnLineThicknessF = 1.
res3@cnLabelMasking = True
res3@cnInfoLabelOn = False
res3@cnInfoLabelFont = 0
res3@cnLineColor = "red"
res3@cnLineLabelsOn = False
res3@cnLineLabelFont = 0
res3@cnLineLabelBackgroundColor = "transparent"
res3@cnLineLabelFontHeightF = 0.005
res3@cnLineLabelPlacementMode = "Computed"
res3@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
res3@gsnContourZeroLineThicknessF = 0
res3@gsnContourNegLineDashPattern = 6
res3@cnLevelSelectionMode = "explicitlevels"
res3@cnLevels = (/-40, -30, -20, -10, 10, 20, 30 ,40/) ; both positive and negative value

; MRG/TD
res4 = True
res4@gsnDraw   = False
res4@gsnFrame  = False
;res2@cnFillOn  = True ; turn on contour fill
;res2@cnLinesOn = False ; turn off contour line
res4@cnLineThicknessF = 1.
res4@cnLabelMasking = True
res4@cnInfoLabelOn = False
res4@cnInfoLabelFont = 0
res4@cnLineColor = "navy"
res4@cnLineLabelsOn = False
res4@cnLineLabelFont = 0
res4@cnLineLabelBackgroundColor = "transparent"
res4@cnLineLabelFontHeightF = 0.005
res4@cnLineLabelPlacementMode = "Computed"
res4@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
res4@gsnContourZeroLineThicknessF = 0
res4@gsnContourNegLineDashPattern = 6
res4@cnLevelSelectionMode = "explicitlevels"
res4@cnLevels = (/-60, -45, -30, -15, 15, 30, 45 ,60/) ; both positive and negative value

; mjo
res5 = True
res5@gsnDraw   = False
res5@gsnFrame  = False
;res2@cnFillOn  = True ; turn on contour fill
;res2@cnLinesOn = False ; turn off contour line
res5@cnLineThicknessF = 1.
res5@cnLabelMasking = True
res5@cnInfoLabelOn = False
res5@cnInfoLabelFont = 0
res5@cnLineColor = "black"
res5@cnLineLabelsOn = False
res5@cnLineLabelFont = 0
res5@cnLineLabelBackgroundColor = "transparent"
res5@cnLineLabelFontHeightF = 0.005
res5@cnLineLabelPlacementMode = "Computed"
res5@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
res5@gsnContourZeroLineThicknessF = 0
res5@gsnContourNegLineDashPattern = 6
res5@cnLevelSelectionMode = "explicitlevels"
res5@cnLevels = (/-40, -30, -20, -10, 10, 20, 30 ,40/) ; both positive and negative value

; resource for panel 
resP = True
resP@gsnMaximize = True ; maximize plot
resP@gsnPanelLabelBar = True ; adds a common label bar at the bottom of the plot
resP@lbLabelFont = 0 ; font type of labels of common color bar  
resP@lbLabelFontHeightF = 0.005 ; font height of labels of common color bar  
resP@pmLabelBarOrthogonalPosF = -0.007 ; y position of label bar
resP@txString = "All Filtered Waves and OLR Anomaly: Observed/Forecast" ; add common title
resP@txFontHeightF = 0.012 ; font size for common title
resP@txFont = 13 ; font for common title

; resource for text
txres = True
txres@txFontHeightF = 0.005 ; font height
txres@txFont = 0 ; font
txres@txFontColor = "black" ; font

;;---- plotting
delete(olra@long_name)
delete(olra@units)
delete(kelolr@long_name)
delete(kelolr@units)
delete(erolr@long_name)
delete(erolr@units)
delete(mrgolr@long_name)
delete(mrgolr@units)
delete(mjoolr@long_name)
delete(mjoolr@units)

outdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/all_wave_on_olrAnomaly_7d/"
outf = "all_wave_on_olrAnomaly_7d"
;wks = gsn_open_wks("svg", outf)
wks = gsn_open_wks("pdf", outdir+outf)
gsn_define_colormap(wks,"sunshine_diff_12lev")   ; color map for olr
plot = new(dimsizes(perd2),graphic) ; create plot array
lines = new(dimsizes(perd2),graphic)

do p = 0, dimsizes(perd2)-1
if (p.ge.7) then
    ;delete(res2@cnLevels)
    delete(res@cnLevels)
    delete(res@cnFillColors)
    res@cnLevels = (/-75,-60,-45,-30,-15,-5,5,15,30,45,60,75/)  ; anomaly (WH04)
    res@cnFillColors = (/2,3,4,5,6,7,8,9,10,11,12,13,14/) ; directly choose color from color bar by its index
    ;res2@cnLevels = ispan(-40,40,5) ; both positive and negative value
end if
	olra@long_name = tostring(tointeger(perd2(p)))
	plot1 = gsn_csm_contour_map_ce(wks, olra(p,{lats:latn},{plon1:plon2}), res) 
	plot2 = gsn_csm_contour(wks, kelolr(p,{lats:latn},{plon1:plon2}), res2) 
	plot3 = gsn_csm_contour(wks, erolr(p,{lats:latn},{plon1:plon2}), res3) 
	plot4 = gsn_csm_contour(wks, mrgolr(p,{lats:latn},{plon1:plon2}), res4) 
	plot5 = gsn_csm_contour(wks, mjoolr(p,{lats:latn},{plon1:plon2}), res5) 
	overlay(plot1, plot2)
	overlay(plot1, plot3)
	overlay(plot1, plot4)
	overlay(plot1, plot5)
	lines(p) = gsn_add_polyline(wks, plot1, (/plon1, plon2/), (/0,0/), False)
	plot(p) = plot1
	gsn_text_ndc(wks,"Contour level for MJO(black), Kelvin(blue), ER(red)= 10; MRG/TD(navy)= 15. In forecast period, level 5 to 15 is added for shaded area and lighter color are used." ,0.5,0.023,txres)
end do
;gsn_panel(wks,plot,(/dimsizes(perd),1/),resP)
gsn_panel(wks,(/plot(0),plot(7),plot(1),plot(8),plot(2),plot(9),plot(3),plot(10),plot(4),\
                    plot(11),plot(5),plot(12),plot(6),plot(13)/),(/7,2/),resP)

print("output-> "+outf)
print(systemfunc("pwd"))

end
