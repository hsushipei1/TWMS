begin
;;====================================================================================
; Calculate the anomaly (A') and interannual scale in Wheeler and Hendon 2004
;20180417

;; PROCEDURE
; 1. Remove time mean 
; 2. Remove the first 3 harmonics 
; 3. Remove previous-120-day running average of 2.

; Resoluion: OLR: 1, Clim: 2.5, GFS: 1. Regrid to 2.5 deg
; Output (anomaly) data length: 365 days (RT 350d + GFS 15d)
;;=====================================================================================

;;---- domain
lon1 = 0
lon2 = 360
lats = -30
latn = 30
variab = "olr"
variabm = variab+"m"
d_avg = 120 ; 120d running avg 
fcstModel = "GFSfcst"

;;---- read data
; Procedure: read RT data, read GFS, read clim, regrid RT & GFS to clim
; real-time data
f1 = addfile("/data5/hsushipei/data/total_field/OLR/realtime/latest.nc","r")
ttt = f1->time ; whole period of data
tt = f1->time( dimsizes(ttt)-350 : dimsizes(ttt)-1 ) ; 350 days
split_date = ( str_split_by_length(tt,(/4,2,2/)) ) ; (year, month, day)
no_leap_t = tt(ind (.not.( (split_date(:,1).eq."02").and.(split_date(:,2).eq."29") ))) ; date without leap day 
varrt = f1->olr({time|no_leap_t},{lat|lats:latn},lon|:) ; [ntime]x[nlat]x[nlon]
printVarSummary(varrt)

RT_END = no_leap_t( dimsizes(no_leap_t)-1 ) ; end of RT 

; GFS forecast (no leap day)
fils3 = systemfunc ("ls /data5/hsushipei/data/gfs/ncep/gfs.olr.*.pgrb2.1p00.f000_f384.daily.nc")
f3 = addfiles (fils3, "r")
ListSetType (f3, "cat")
varf = f3[:]->ULWRF_topofatmosphere(0:dimsizes(f3[:]->time)-3,{lats:latn},:) ; start from 1st
;fcst_tc = decimalPlaces(varf&time,0, False) ; time coordinate of forecast data
fcst_tc = tointeger(varf&time) ; time coordinate of forecast data
fcst_start = fcst_tc(0)
fcst_start@time = fcst_tc(0)
fcst_start@long_name = "Start date of "+fcstModel
fcst_end = fcst_tc(dimsizes(fcst_tc)-1)
fcst_end@time = fcst_tc(dimsizes(fcst_tc)-1)
fcst_end@long_name = "End date of "+fcstModel
varf&time = fcst_tc
printVarSummary(varf)

; slow annual cycle
;f2 = addfile("./mean_slow_annual_cycle_data/mean_slow_annual_cycle_"+variab+".nc","r")
f2 = addfile("/data5/hsushipei/data/wh04_data/mean_and_demean_slow_annual_cycle_data/mean_and_demean_slow_annual_cycle_"+variab+".nc","r")
date = f2->time
varsac = f2->$variab$(:,{lats:latn},:) ; [365]x[nlat]x[nlon]
;varsac = f2->sst(:,{lats:latn},{lon1:lon2}) ; [365]x[nlat]x[nlon]
printVarSummary(varsac)

;;---- Regrid: regrid RT, GFS to 2.5 (clim)
; RT 
loni = varrt&lon
lati = varrt&lat
lono = varsac&lon
lato = varsac&lat
varrt_rg = linint2_Wrap(loni, lati, varrt, True, lono, lato, 0)
;printVarSummary(varrt_rg)
delete(loni)
delete(lati)
delete(varrt)

; GFS
loni = varf&longitude
lati = varf&latitude
varf_rg = linint2_Wrap(loni, lati, varf, True, lono, lato, 0)
;printVarSummary(varf_rg)
delete(loni)
delete(lati)
delete(lono)
delete(lato)
delete(varf)

;;---- Merge RT and GFS
varrt_rg2 = array_append_record(varrt_rg, varf_rg,0)
delete(varrt_rg)
delete(varf_rg)
varrt = varrt_rg2
delete(varrt_rg2)
printVarSummary(varrt)

ntime = varrt&time ; RT+GFS
dend = ntime( dimsizes(ntime)-1 ) ; end of RT+GFS
dstart = ntime(0) ; start of RT (+GFS)
dstart@time = ntime(0) 

;;---- Extend slow annual cycle data if realtime data spans through 12/31
; cut data spaning from 1/1 to given date -> the section to extend
rt_end_mmdd =str_split_by_length(dend,(/4,4/))
varsac2 = f2->$variab$({:"2000"+rt_end_mmdd(1)},{lats:latn},:)  ; from 1/1 to given data
;varsac2 = f2->u925({:"2000"+rt_end_mmdd(1)},{lats:latn},:)  ; from 1/1 to given data
;varsac2 = f2->v925({:"2000"+rt_end_mmdd(1)},{lats:latn},:)  ; from 1/1 to given data
;printVarSummary(varsac2)

; extend slow annual cycle
varsac_x = array_append_record(varsac, varsac2, 0)  ; [ntime_ext]x[nlat]x[nlon] , x=extended
varsac_x@long_name = "Extended slow annual cycle"
printVarSummary(varsac_x)
delete(varsac)
delete(varsac2)
ext_sac_time = varsac_x&time
new_period_ind = ind(ext_sac_time.eq."2000"+rt_end_mmdd(1))
varsac = varsac_x(( new_period_ind(0)+1 ):new_period_ind(1),:,:) ; "varsac" variable will be called later
printVarSummary(varsac) ; having the same period to real time data
;print(varsac&time)

; time mean
varm = f2->$variabm$({lats:latn},:) ; [nlat]x[nlon]
;printVarSummary(varm)

varsac_rg = varsac
varm_rg = varm

; check point
printVarSummary(varsac_rg)
printVarSummary(varm_rg)
printVarSummary(varrt)
;exit

;;---- calculate anomaly(WH04, June-Yi Lee 2013)
; Substract time mean
var_nom = new(dimsizes(varrt), typeof(varrt)) ; [ntime]x[nlat]x[nlon] , nom = no mean
do t = 0, dimsizes(varrt&time)-1
	var_nom(t,:,:) = varrt(t,:,:) - varm_rg
end do
copy_VarCoords(varrt, var_nom)
var_nom@long_name = "tot_minus_time_mean_"+variab
;var_nom@_FillValue = varrt@_FillValue
printVarSummary(var_nom)
;print(var_nom(:,{0},{120}))

; Substract slow annual cycle
var_nosac = new( dimsizes(varrt), typeof(varrt)) ; [ntime]x[nlat]x[nlon], nosac = no slow annual cycle
;var_nosac = var_nom - varsac_rg({20140101:20140531},:,:)  ; to 20161215
var_nosac = var_nom - varsac_rg
copy_VarCoords(varrt, var_nosac)
var_nosac@long_name = "tot_minus_time_mean_minus_first_3_harmonics_"+variab
;var_nosac@_FillValue = varrt@_FillValue
var_nosac!0 = "time" ; conventional coordinate name for NetCDF
printVarSummary(var_nosac)
;print(var_nosac)

; Dealing with previous-120-day running avg
;;---- [ntime]x[nlat]x[nlon] => [ntime]x[space]
dims = dimsizes(varrt) ; (ntime, nlat, nlon)
var2d = reshape(var_nosac, (/dims(0), dims(1)*dims(2) /)) ; [ntime]x[space]
var2d@_FillValue = var_nosac@_FillValue

;;---- calculate previous-120-day running avg
var2d_rnavg = new(dimsizes(var2d), typeof(varrt)) ; [ntime]x[space]
printVarSummary(var2d_rnavg)

do s = 0, (dims(0)-1)-(d_avg-1) ; points included in calculating running average
    out_ind = (dims(0)-1)-s
    print(out_ind+" "+(out_ind-119)) ; points between the two index are 120
    var2d_rnavg(out_ind,:) = dim_avg_n(var2d( (out_ind-119):out_ind, :), 0)
end do
printVarSummary(var2d_rnavg)

;;---- [ntime]x[space] => [ntime]x[nlat]x[nlon]
var3d_rnavg = reshape(var2d_rnavg, (/dims/) )  ; [ntime]x[nlat]x[nlon]
copy_VarCoords(varrt, var3d_rnavg)
var3d_rnavg@long_name = "Interannual variability and longer time scale"
var3d_rnavg@information = "Apply previous 120-day running average on time mean and seasonal cycle removed total "+variab
printVarSummary(var3d_rnavg)

; Substract previous-120-day running average to get anomaly
var_anom = new(dimsizes(varrt), typeof(varrt)) ; [ntime]x[nlat]x[nlon] , anom = anomaly
var_anom = var_nosac - var3d_rnavg
copy_VarCoords(varrt, var_anom)
var_anom@long_name = "anomalyWH04_"+variab
printVarSummary(var_anom)
print(var_anom(:,{0},{120})) ; day 1 to day 120 are missing values due to previous 120d running avg

;;---- output NetCDF
outfdir = "/data5/hsushipei/data/wh04_data/field_data/latest/"
outf = outfdir+"anomaly_"+variab+"_latest.nc"
system("/bin/rm -f "+outf)
ncdf1 = addfile(outf ,"c")
filedimdef(ncdf1,"time",-1,True)
;ncdf1->$variab$ = var_anom ; remove ENSO
ncdf1->$variab$ = var_nosac ; retain ENSO
ncdf1->$(variab+"_inta")$ = var3d_rnavg
ncdf1->obs_startdate = dstart
ncdf1->obs_enddate = RT_END
ncdf1->fcst_startdate = fcst_start
ncdf1->fcst_enddate = fcst_end
print("netcdf file done-> "+outf)

end
