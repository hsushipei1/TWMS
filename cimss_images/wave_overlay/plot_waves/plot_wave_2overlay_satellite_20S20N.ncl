begin

;;----domain
lon1 = 39
lon2 = 181
;lats = -11 ; KW
;latn = 11 ; KW
lats = -21 ; MJO, ER, MRG/TD
latn = 21 ; MJO, ER, MRG/TD
dstart = getenv("DSTART")
dend = getenv("DEND")
wave = getenv("WAVE") ; "MJO", "Kelvin", "ER", "MRG-TD" (MRG/TD), "pMRG" (Pure asymmetric MRG)
;dstart = 20170528
;dend = 20170602
;wave = "MRG-TD" ; "MJO", "Kelvin", "ER", "MRG-TD" (MRG/TD), "pMRG" (Pure asymmetric MRG)

;;----read data
print("Plot "+wave+" OLR overlaid on satellite "+dstart+" "+dend)
if ( wave.eq."MRG-TD" ) then
	wave = "MRG"
	f3 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_"+wave+"_olr_latest.nc","r")
	wave = "MRG-TD"
else 
	f3 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_"+wave+"_olr_latest.nc","r")
end if
olr = f3->olr({dstart:dend},{lats:latn},{lon1:lon2}) ; [ntime]x[nlat]x[nlon]
rt_end =  f3->enddate; end of real-time data
datee = olr&time
printVarSummary(olr)

;;----resource
res=True
res@gsnDraw      = False                ; don't draw yet
res@gsnFrame     = False                ; don't advance frame yet
res@gsnAddCyclic = False ; if the map domain isn't global
;res@cnFillOn  = True ; turn on contour fill
;res@cnLinesOn = False ; turn off contour line
res@tmXBLabelFont = 26
res@tmXBLabelFontHeightF = 0.04  ; 0.1 for KW, 
res@tmXBLabelFontColor = "white"
res@tmXBTickSpacingF = 10
res@tmYLLabelFont = 26
res@tmYLLabelFontHeightF = 0.04  ; 0.1 for KW, 
res@tmYLLabelFontColor = "white"
res@tmYLTickSpacingF = 10

res@cnInfoLabelOn = False
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = -40
res@cnMaxLevelValF = 40
res@cnLevelSpacingF = 10
res@cnLineThicknessF = 4.5
res@cnLineColor = "white"
res@cnLineLabelFontHeightF = 0.0001 ; try to hide contour label
res@cnLabelMasking = True
res@cnLineLabelBackgroundColor = "transparent"
res@gsnContourZeroLineThicknessF = 0
res@gsnContourNegLineDashPattern = 6
res@gsnMaximize = True

; KW (10S to 10N)
;res@vpHeightF = 1  
;res@vpWidthF =  6.8875 
; MJO, ER, MRG/TD (20S to 20N)
res@vpHeightF = 1  
res@vpWidthF =  3.5

plres = True
plres@gsLineColor = "white"
plres@gsLineThicknessF = 2.0
;plres@gsLineLabelString= "Equator"  
plres@gsLineLabelFontColor = "white" 
plres@gsLineLabelFont =  26
plres@gsLineLabelFontHeightF = 0.015

txres = True
txres@txFont = 26 ; font 
txres@txFontHeightF = 0.01 ; font height
txres@txFontColor = "white" 

delete(olr@long_name)
delete(olr@standard_name)
delete(olr@units)

;;---- deal with contour color for wave forecast (if wave forecast is included in plotting period)
; HOW: consider the end of real-time data as reference date, if the current time pass ahead it, change color from 
; white to lighblue
rt_end_spt = tointeger( str_split_by_length( rt_end, (/4,2,2/) ) )
dref = "days since "+rt_end_spt(0)+"-"+rt_end_spt(1)+"-"+rt_end_spt(2)+" 00:00:0.0" ; rt_end as reference date 

;;----plot
outdir = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/wave_overlay/plot_waves/"
res@tiMainFont = 26
res@tiMainFontHeightF = 0.12 ; height of title font
res@tiMainFontColor = "white" 

do plt = 0, dimsizes(datee)-1
    dcurr_spt = tointeger( str_split_by_length( tostring( datee(plt) ), (/4,2,2/) ) ) ; current date
    dcurr_tind = cd_inv_calendar( dcurr_spt(0), dcurr_spt(1), dcurr_spt(2), 0, 0, 0, dref, 0 ) ; dstart reference to rt_end

    titl = wave+" wave OLR overlaid on Satellite Image at "+tointeger(datee(plt))+\
	                                    "    Contour level="+res@cnLevelSpacingF; title for plot
    ; if the current time goes beyond the end of real-time data
    if (dcurr_tind.gt.0) then
        res@cnLineColor = "lightblue2"
        res@cnLevelSpacingF = 5
        titl = wave+" wave (forecast) OLR overlaid on Satellite Image at "+tointeger(datee(plt))+\
		                                    "    Contour level="+res@cnLevelSpacingF; title for plot
    end if

	pltn = wave+"_olr_"+datee(plt)
	;res@tiMainString = wave+" OLR at "+datee(plt)

	wksr = "png"
	wksr@wkBackgroundOpacityF = 0. ; transparent background for plot
	wks = gsn_open_wks(wksr, outdir+pltn)
	;wks = gsn_open_wks("png", pltn)
	;gsn_define_colormap(wks,"sunshine_diff_12lev")   ; single day

    print("plot-> "+wave+" olr for overlaying on satellite at "+datee(plt)+" color=  "+res@cnLineColor) 
	plot1 = gsn_csm_contour(wks, olr(plt,:,:), res)
	EQ_line = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), plres)
	gsn_text_ndc(wks,titl,0.5,0.72,txres)
	draw(plot1)
	frame(wks)
end do


end
