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
fils = systemfunc ("ls /data5/hsushipei/data/fnl/sliced/latest/6hr/fnl025_pw_*.nc")
fil_latest = fils(dimsizes(fils)-1)
fil_spt = str_split_by_length(fil_latest, (/54,10,3/))
datee = fil_spt(1)

print("%%%% Enter 'plot_pw_925wind.ncl' at "+datee+" %%%% ")
f3 = addfile("/data5/hsushipei/data/fnl/sliced/latest/6hr/fnl025_pw_"+datee+".nc","r") 
pw = f3->pw(0,{lats:latn},{lon1:lon2}) ;[nlat]x[nlon]
printVarSummary(pw)

f = addfile("/data5/hsushipei/data/fnl/sliced/latest/6hr/fnl025_u_"+datee+".nc","r")
u = f->u(0,{plev},{lats:latn},{lon1:lon2}) ; [ntime]x[nlat]x[nlon]
f2 = addfile("/data5/hsushipei/data/fnl/sliced/latest/6hr/fnl025_v_"+datee+".nc","r")
v = f2->v(0,{plev},{lats:latn},{lon1:lon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(u)
printVarSummary(v)

; surface pressure. Mask out the levels of pressure less than 925mb
f = addfile("/data5/hsushipei/data/total_field/SFC_PRS/intrim075_sfcprs_1981_2010_dec_daily.nc","r")
sfcprs = f->sfcprs(:,{lats:latn},{lon1:lon2})
sfcprsm = dim_avg_Wrap(sfcprs(lat|:,lon|:,time|:)) ; [nlat]x[nlon]  avg in dec
;printVarSummary(sfcprsm)

; regrid sfcprsm 0.75 deg to fnl data 0.25 deg
loni = sfcprsm&lon
lati = sfcprsm&lat
lono = u&lon_0
lato = u&lat_0
sfcprsm_rg = linint2_Wrap(loni, lati, sfcprsm, False, lono, lato, 0)
printVarSummary(sfcprsm_rg) ; [nlat]x[nlon]

;;---- Masking
; Mask out the levels of pressure less than 925mb
umask = u   ; [nlat]x[nlon]
umask = mask(u,(sfcprsm_rg.ge.92500.),True)
vmask = v   ; [nlat]x[nlon]
vmask = mask(v,(sfcprsm_rg.ge.92500.),True)
;printVarSummary(umask)
;printVarSummary(vmask)

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
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 40
res@cnMaxLevelValF = 70
res@cnLevelSpacingF = 5
res@lbLabelFont = 0 ; font for label bar
res@pmLabelBarOrthogonalPosF = 0.1 ;  color bar y position
;res@gsnMaximize = True

res2 = True
res2@gsnDraw       = False                ; don't draw yet
res2@gsnFrame      = False                ; don't advance frame yet
res2@gsnAddCyclic  = False
;res2@vcMinMagnitudeF      = 0.05    ;  arrow with magnitude under this value will not be drawn.
res2@vcRefLengthF         = 0.02    ;  length of unit reference vector
res2@vcRefMagnitudeF      =  15.    ;  magnitude of the reference vector
res2@vcMinDistanceF       = 0.015    ;  Vector density: distance between arrows
res2@vcLineArrowHeadMinSizeF = 0.003
res2@vcLineArrowHeadMaxSizeF = 0.003
res2@vcRefAnnoOrthogonalPosF = 0.2 ; y position of vector reference annotation
res2@vcRefAnnoFont = 0 ; font for vector reference annotation
res2@vcRefAnnoString2On = False ; turn off string "Reference vector" in vector ref annotation box
res2@vcRefAnnoOrthogonalPosF = -0.25 ; y coordinate of vector ref annotation box
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
delete(umask@long_name)
delete(vmask@long_name)
delete(umask@units)
delete(vmask@units)

;;----plot
pltdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/pw_wind/"
pltn = "pw_fnl025_925wind_latest"
res@tiMainString = "Latest FNL PW 925-hPa Wind on "+datee
res@tiMainFont = 0 ; font
res@tiMainFontHeightF = 0.018 ; height of title font
wks = gsn_open_wks("pdf", pltdir+pltn)
gsn_define_colormap(wks,"WhiteBlue")   ; define color map
plot1 = gsn_csm_contour_map_ce(wks, pw, res)
plot2 = gsn_csm_vector(wks,umask, vmask, res2) ; vector, for smaller plot domain 
overlay(plot1, plot2)
gsn_text_ndc(wks,"kg:F18:V"+":F0:m"+":S:-2",0.78,0.275,txres)
;dsloc = gsn_add_polymarker(wks, plot1, 116.73, 20.70, mkres) ; point out Dongsha
;nsloc = gsn_add_polymarker(wks, plot1, 114.36, 10.37, mkres) ; point out Nansha
EQ_line = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
draw(plot1)
frame(wks)

print("Plot created-> "+pltn)
print("%%%% Leave 'plot_pw_925wind.ncl' at "+datee+" %%%% ")

end
