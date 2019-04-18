load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/kf_filter.ncl"
begin

lats = -25
latn = 25
plon1 = 39
plon2 = 181
wave = "er"

;;---- read data
; OLR anomaly
f = addfile("/data5/hsushipei/data/wh04_data/field_data/latest/anomaly_olr_latest.nc","r")
time = f->time
ntime = dimsizes(time)
tend = ntime-4 ; latest olr time step (end)
tstart = tend-23
olra = f->olr(tstart:tend,{lats:latn},{plon1:plon2}) ;[ntime]x[nlat]x[nlon]
printVarSummary(olra)
perd = olra&time ; plot period
nperd = dimsizes( perd )
nlat = dimsizes( olra&lat )
nlon = dimsizes( olra&lon )
dstart_s = str_split_by_length(perd(0),(/4,2,2/))

;; wave olr 
;f2 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_MJO_olr_latest.nc","r")
f2 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_allwave_olr_GFSfcst_latest.nc","r")
wolr = f2->olrer({perd},{lats:latn},{plon1:plon2}) ; [ntime]x[nlat]x[nlon]
nlat2 = dimsizes( wolr&lat )
nlon2 = dimsizes( wolr&lon )
printVarSummary(wolr)

;;---- calculate mean for each period
grp = 8 ; n periods
daysPerP = 3 ; days per period
p_days = new((/grp, daysPerP/), typeof(perd)) ; storing days for each period, ngroups x ndays
olra_p = new( (/grp, nlat, nlon/), typeof(olra) ) ; olra in each period, ngroup x nlat x nlon
wolr_p = new( (/grp, nlat2, nlon2/), typeof(wolr) ) ; wolr in each period, ngroup x nlat x nlon

do n = 0, grp-1
	p_days(n,:) = perd( 3*n : 3*n+2 )
	olra_p(n,:,:) = dim_avg_n_Wrap( olra( { p_days(n,:) }, :, : ), 0 )
	wolr_p(n,:,:) = dim_avg_n_Wrap( wolr( { p_days(n,:) }, :, : ), 0 )
end do
;print(p_days(6,:))
;print(wolr_p(6,10,20))
;print(dim_avg_n_Wrap( wolr({20171121:20171123},10,20), 0) )
printVarSummary(olra_p)

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
res@tiMainFont = 22
res@cnFillOn  = True ; turn on contour fill
res@cnLinesOn = False ; turn off contour line
res@tmXBTickSpacingF = 20
res@tmXBLabelFont = 21
res@tmXBLabelFontHeightF = 0.017
res@tmYLTickSpacingF = 10
res@tmYLLabelFont = 21
res@tmYLLabelFontHeightF = 0.017
res@cnLevelSelectionMode = "explicitlevels"
;res@cnLevels = -ispan(-80,80,10)  ; anomaly (WH04)
res@cnLevels = (/-75,-60,-45,-30,-15,15,30,45,60,75/)  ; anomaly (WH04)
res@cnFillColors = (/2,3,4,5,6,8,10,11,12,13,14/) ; directly choose color from color bar by its index
;res@gsnMaximize = True ; maximize plot 
res@lbLabelBarOn  = False  ; turn off individual color bar
res@cnLineLabelFontHeightF = 1. ; seems to remove contour labels as individual color bars are removed

res@gsnStringFont = 21 ; font for gsnLeftString
;res@gsnLeftStringFontHeightF = 0.015

; wave olr
res2 = True
res2@gsnDraw   = False
res2@gsnFrame  = False
;res2@cnFillOn  = True ; turn on contour fill
;res2@cnLinesOn = False ; turn off contour line
res2@cnLineThicknessF = 3.5
res2@cnLabelMasking = True
res2@cnInfoLabelOn = False
res2@cnInfoLabelFont = 21
res2@cnLineColor = "red"
res2@cnLineLabelsOn = False
res2@cnLineLabelFont = 21
res2@cnLineLabelBackgroundColor = "transparent"
res2@cnLineLabelFontHeightF = 0.005
res2@cnLineLabelPlacementMode = "Computed"
res2@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
res2@gsnContourZeroLineThicknessF = 0
res2@gsnContourNegLineDashPattern = 11
res2@cnLevelSelectionMode = "explicitlevels"
res2@cnLevels = ispan(-40,40,8) ; both positive and negative value

; resource for panel 
resP = True
resP@gsnMaximize = True ; maximize plot
resP@gsnPanelLabelBar = True ; adds a common label bar at the bottom of the plot
resP@lbLabelFont = 21 ; font type of labels of common color bar  
resP@lbLabelFontHeightF = 0.012 ; font height of labels of common color bar  
resP@pmLabelBarOrthogonalPosF = -0.015 ; y position of label bar
resP@txString = "Filtered ER OLR on OLR anomaly: Observed/GFS Forecast" ; add common title
resP@txFontHeightF = 0.015 ; font size for common title
resP@txFont = 22 ; font for common title

; resource for text
txres = True
txres@txFontHeightF = 0.012 ; font height
txres@txFont = 21 ; font
txres@txFontColor = res2@cnLineColor ; font

;;---- plotting
outdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/on_OLRanoamly_gfs/"
outf = wave+"_olr_onOLRanomaly_gfs"

wks_type = "pdf"
wks_type@wkPaperWidthF  = 16.666666667  ; in inches
wks_type@wkPaperHeightF = 16.666666667  ; in inches

wks = gsn_open_wks(wks_type, outdir+outf)
gsn_define_colormap(wks,"sunshine_diff_12lev")   ; color map for olr

plot = new(grp,graphic) ; create plot array
lines = new(grp,graphic)

delete(olra_p@long_name)
delete(wolr_p@long_name)
delete(wolr_p@units)

do n = 0, grp-1
	res@gsnLeftString = "3d Avg("+(n-3)+")"
	res@gsnRightString = p_days(n, 0)+"-"+p_days( n, dimsizes( p_days(n,:) )-1 )
	plot1 = gsn_csm_contour_map_ce(wks, olra_p( n,:,: ), res)
	plot2 = gsn_csm_contour(wks,wolr_p( n,:,: ), res2) ; vector, for smaller plot domain 
	overlay(plot1, plot2)
	lines(n) = gsn_add_polyline(wks, plot1, (/plon1, plon2/), (/0,0/), False)
	plot(n) = plot1
end do

gsn_text_ndc(wks,"Right column: Obs, left column: Fcst; Shaded: OLR anomaly; Contour: "+wave+" OLR, level= 8." ,0.5,0.065,txres)
gsn_panel(wks,(/plot(0),plot(4),plot(1),plot(5), plot(2), plot(6), plot(3), plot(7)/),(/4,2/),resP)

print("output-> "+outf)
print(systemfunc("pwd"))

end
