begin

;;----domain
lon1 = 39 
lon2 = 181
lats = -20
latn = 30
plev = 1000 ; unit: hPa
datee = getenv("DATE")
;datee = 2017063000

;;----read data
print("%%%% Enter 'plot_1000wind_6hr.ncl' at "+datee+" %%%% ")
f = addfile("/data5/hsushipei/data/fnl/sliced/latest/6hr/fnl025_u_"+datee+".nc","r")
u = f->u(:,{plev},{lats:latn},{lon1:lon2}) ; [ntime]x[nlat]x[nlon]
f2 = addfile("/data5/hsushipei/data/fnl/sliced/latest/6hr/fnl025_v_"+datee+".nc","r")
v = f2->v(:,{plev},{lats:latn},{lon1:lon2}) ; [ntime]x[nlat]x[nlon]
printVarSummary(u)
printVarSummary(v)

; surface pressure. Mask out the levels of pressure less than 1000mb
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
;printVarSummary(sfcprsm_rg) ; [nlat]x[nlon]

sfcprsm_rg_3d = new((/dimsizes(datee),dimsizes(sfcprsm_rg&lat_0),dimsizes(sfcprsm_rg&lon_0) /),typeof(sfcprsm_rg))
do ttt = 0, dimsizes(datee)-1
	sfcprsm_rg_3d(ttt,:,:) = sfcprsm_rg
end do
sfcprsm_rg_3d!0 = "time"
sfcprsm_rg_3d&time = u&time
;printVarSummary(sfcprsm_rg_3d)
;print(sfcprsm_rg_3d(30,{0},{120})+" "+sfcprsm_rg({0},{120}))

;;---- Masking
; Mask out the levels of pressure less than 1000mb
umask = u   ; [ntime]x[nlat]x[nlon]
umask = mask(u,(sfcprsm_rg_3d.ge.100000.),True)
vmask = v   ; [ntime]x[nlat]x[nlon]
vmask = mask(v,(sfcprsm_rg_3d.ge.100000.),True)
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
;res@gsnMaximize = True

;res@vcMinMagnitudeF      = 0.05    ;  arrow with magnitude under this value will not be drawn.
res@vcRefLengthF         = 0.02    ;  length of unit reference vector
res@vcRefMagnitudeF      =  15.    ;  magnitude of the reference vector
res@vcMinDistanceF       = 0.015    ;  Vector density: distance between arrows
res@vcLineArrowHeadMinSizeF = 0.003
res@vcLineArrowHeadMaxSizeF = 0.003
res@vcRefAnnoOrthogonalPosF = 0.2 ; y position of vector reference annotation
res@vcRefAnnoFont = 0 ; font for vector reference annotation
; colorize vector
res@vcMonoLineArrowColor = False ; colors the vector
res@vcLevelPalette = "ncview_default" ; color bar for vector
res@pmLabelBarOrthogonalPosF = 0.1 ; vector color bar position
res@lbLabelFont = 0 ; font for label bar
res@vcLevelSelectionMode = "ManualLevels"
res@vcMinLevelValF = 4
res@vcMaxLevelValF = 36
res@vcLevelSpacingF = 4

txres = True
txres@txFontHeightF = 0.02 ; font height

mkres = True
mkres@gsMarkerIndex = 16
mkres@gsMarkerThicknessF = 1.5

delete(umask@long_name)
delete(vmask@long_name)
delete(umask@units)
delete(vmask@units)

;;----plot
pltdir = "/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wind_6hr/1000/"
pltn = "fnl025_1000wind_latest"
res@tiMainString = "Latest NCEP FNL 1000-hPa Wind on "+datee+"Z"
res@tiMainFont = 0 ; font
res@tiMainFontHeightF = 0.018 ; height of title font
wks = gsn_open_wks("pdf", pltdir+pltn)

plot1 = gsn_csm_vector_map_ce(wks,umask(0,:,:), vmask(0,:,:), res) ; vector, for smaller plot domain 
;gsn_text_ndc(wks,"kgm**-2",0.88,0.15,txres)
;dsloc = gsn_add_polymarker(wks, plot1, 116.73, 20.70, mkres) ; point out Dongsha
;nsloc = gsn_add_polymarker(wks, plot1, 114.36, 10.37, mkres) ; point out Nansha
EQ_line = gsn_add_polyline(wks, plot1, (/lon1, lon2/), (/0,0/), False)
draw(plot1)
frame(wks)

print("Plot created-> "+pltn)
print("%%%% Leave 'plot_1000wind_6hr.ncl' at "+datee+" %%%% ")

end
