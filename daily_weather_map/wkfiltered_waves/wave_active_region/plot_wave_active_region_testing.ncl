load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/kf_filter.ncl"
begin

lats = -20
latn = 20
lon1 = 39
lon2 = 181
date1 = 20171001
date2 = 20171013
cint = 10

;;---- read data
; MJO olr
f3 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_MJO_olr_latest.nc","r")
mjoolr = f3->olr({date1:date2},{lats:latn},{lon1:lon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(mjoolr)

; kelvin wave olr 
f2 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_Kelvin_olr_latest.nc","r")
kelolr = f2->olr({date1:date2},{lats:latn},{lon1:lon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(kelolr)

; er olr
f5 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_ER_olr_latest.nc","r")
erolr = f5->olr({date1:date2},{lats:latn},{lon1:lon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(erolr)

; mrg olr 
f7 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_MRG_olr_latest.nc","r")
mrgolr = f7->olr({date1:date2},{lats:latn},{lon1:lon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(mrgolr)

;;---- olr standard deviation
mjoolrint = sqrt( mjoolr*mjoolr)
copy_VarMeta( mjoolr, mjoolrint )
mjoolrintm = dim_avg_n_Wrap( mjoolrint, 0 )
printVarSummary(mjoolrintm)

kelolrint = sqrt( kelolr*kelolr )
copy_VarMeta( kelolr, kelolrint )
kelolrintm = dim_avg_n_Wrap(kelolrint, 0)

erolrint = sqrt(erolr*erolr)
copy_VarMeta(erolr, erolrint)
erolrintm = dim_avg_n_Wrap( erolrint, 0 )

mrgolrint =  sqrt(mrgolr*mrgolr)
copy_VarMeta( mrgolr, mrgolrint )
mrgolrintm = dim_avg_n_Wrap( mrgolrint, 0 )
printVarSummary(mrgolrintm)

;;---- resource
; olr anomaly
res=True
res@gsnDraw      = False                ; don't draw yet
res@gsnFrame     = False                ; don't advance frame yet
res@mpMinLatF    = lats       ; Set the domain of map (not the domain
res@mpMaxLatF    = latn       ; of data). If the data's domain is
res@mpMinLonF    = lon1       ; smaller than the map's, you'll see
res@mpMaxLonF    = lon2       ; blank(white) area on plot (missing).
res@mpCenterLonF = (lon1+lon2)/2 ; Center lon of this plot.
res@gsnAddCyclic = False ; if the map domain isn't global
res@tiMainFont = 0
res@cnFillOn  = True ; turn on contour fill
;res@cnLinesOn = False ; turn off contour line
res@tmXBTickSpacingF = 20
res@tmXBLabelFont = 0
res@tmXBLabelFontHeightF = 0.015
res@tmYLTickSpacingF = 10
res@tmYLLabelFont = 0
res@tmYLLabelFontHeightF = 0.015
res@cnLevelSelectionMode = "explicitlevels"
res@cnLevels = (/cint/)  ; anomaly (WH04)
res@cnFillColors = (/"white","navy"/) ; directly choose color from color bar by its index
res@cnFillOpacityF = 0.4 ; 0 to be completely transparent
;res@gsnMaximize = True ; maximize plot 
res@lbLabelBarOn  = False  ; turn off individual color bar
res@cnLineLabelFontHeightF = 1. ; seems to remove contour labels as individual color bars are removed

res@cnLineColor = "navy"
res@cnLineThicknessF = 2.
res@cnLineLabelsOn = False

; wave olr
; Kelvin
res2 = True
res2@gsnDraw   = False
res2@gsnFrame  = False
res2@cnFillOn  = True ; turn on contour fill
;res2@cnLinesOn = False ; turn off contour line
res2@cnLineThicknessF = 2.
res2@cnLabelMasking = True
res2@cnInfoLabelOn = False
;res2@cnInfoLabelFont = 0
res2@cnLineColor = "blue"
res2@cnLineLabelsOn = False
res2@cnLineLabelFont = 0
res2@cnLineLabelBackgroundColor = "transparent"
res2@cnLineLabelFontHeightF = 0.005
res2@cnLineLabelPlacementMode = "Computed"
res2@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
;res2@gsnContourZeroLineThicknessF = 0
;res2@gsnContourNegLineDashPattern = 6
res2@cnLevelSelectionMode = "explicitlevels"
res2@cnLevels = (/cint/) ; both positive and negative value
res2@cnFillColors = (/"white","blue"/)
res2@cnFillOpacityF = 0.4
res2@lbLabelBarOn  = False

; ER
res3 = True
res3@gsnDraw   = False
res3@gsnFrame  = False
res3@cnFillOn  = True ; turn on contour fill
;res2@cnLinesOn = False ; turn off contour line
res3@cnLineThicknessF = 2.
res3@cnLabelMasking = True
res3@cnInfoLabelOn = False
res3@cnInfoLabelFont = 0
res3@cnLineColor = "red"
res3@cnLineLabelsOn = False
;res3@cnLineLabelFont = 0
res3@cnLineLabelBackgroundColor = "transparent"
res3@cnLineLabelFontHeightF = 0.005
res3@cnLineLabelPlacementMode = "Computed"
res3@cnLineLabelDensityF = -5 ; does not work if cnLineLabelPlacementMode is set to "constant".
;res3@gsnContourZeroLineThicknessF = 0
;res3@gsnContourNegLineDashPattern = 6
res3@cnLevelSelectionMode = "explicitlevels"
res3@cnLevels = (/cint/) ; both positive and negative value
res3@cnFillColors = (/"white","red"/)
res3@cnFillOpacityF = 0.4
res3@lbLabelBarOn  = False

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

; resource for text
txres = True
txres@txFontHeightF = 0.01 ; font height
txres@txFont = 0 ; font
txres@txFontColor = "black" ; font

;;---- plotting
delete(kelolrintm@long_name)
delete(kelolrintm@units)
delete(mrgolrintm@long_name)
delete(mrgolrintm@units)
delete(erolrintm@long_name)
delete(erolrintm@units)

outdir = "./"
outf = "wave_active_region"
res@tiMainString = "Active Region (OLR Variance) of Tropical Waves"
res@tiMainFont = 0 ; font
res@tiMainFontHeightF = 0.015 ; height of title font
wks = gsn_open_wks("eps", outdir+outf)
gsn_define_colormap(wks,"sunshine_diff_12lev")   ; color map for olr

res@gsnStringFont = 0
res@gsnStringFontHeightF = 0.01
res@gsnRightString = date1+"-"+date2

plot1 = gsn_csm_contour_map_ce(wks, mrgolrintm, res) 
plot2 = gsn_csm_contour(wks,kelolrintm , res2) 
plot3 = gsn_csm_contour(wks, erolrintm, res3) 

;plot4 = gsn_csm_contour(wks, mrgolr(p,{lats:latn},{plon1:plon2}), res4) 
;plot5 = gsn_csm_contour(wks, mjoolr(p,{lats:latn},{plon1:plon2}), res5) 
overlay(plot1, plot2)
overlay(plot1, plot3)
;overlay(plot1, plot4)
;overlay(plot1, plot5)
lines = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
gsn_text_ndc(wks,"Contour level= "+cint+" for Kelvin(blue); ER(red); MRG/TD(navy)." ,0.5,0.33,txres)
draw(plot1)
frame(wks)

print("output-> "+outf)
print(systemfunc("pwd"))

end
