begin
;;====================================================================================
; Calculate the anomaly (A') and interannual scale in Wheeler and Hendon 2004

;; PROCEDURE
; 1. Remove time mean from daily total OLR
; 2. Remove the first 3 harmonics of annual cycle of 1.
; 3. Remove previous-120-day running average of 2. and you will get the anomaly (A')
;;=====================================================================================

;;---- domain
lon1 = 0
lon2 = 360
lats = -30
latn = 30
variab = "sst"
variabm = variab+"m"
d_avg = 120 ; 120d running avg 
tspan = 365 ; a year

;;---- read data
; real-time data
fils = systemfunc ("ls /data5/hsushipei/data/total_field/SST/noaa_oisst_v2/sst.day.mean.*.v2.nc")
f = addfiles (fils( dimsizes(fils)-2:dimsizes(fils)-1 ) , "r")
ListSetType (f, "cat")
rel_t = f[:]->time ; relative time coordinate from original data

; convert relative to absolute time coordinate and remove leap day
abs_t = cd_calendar(rel_t, 2) ; convert rel time to abs time, with leap day
split_date = str_split_by_length( tostring(abs_t),(/4,2,2/) ) ; (year, month, day) , with leap day
no_leap_abst = abs_t(ind (.not.( (split_date(:,1).eq."02").and.(split_date(:,2).eq."29") ))) ; abs date without leap day
spl_nolp_abst = str_split_by_length( tostring(no_leap_abst),(/4,2,2/) ) ; (year, month, day) , rel date without leap day 

ntime = dimsizes(no_leap_abst) ; without leap day
sst = f[:]->sst(  ntime-tspan : ntime-1 ,{lats:latn},{lon1:lon2}) ; 365 x lat x lon, without leap day
;sst = f[:]->sst(  ntime-tspan+1 : ntime ,{lats:latn},{lon1:lon2}) ; 365 x lat x lon, without leap day

sst_abst = tointeger( no_leap_abst( ntime-tspan : ntime-1 ) ) ; 365 days

dend = sst_abst(dimsizes(sst_abst)-1) ; latest data
dstart = sst_abst(0) ; start day (1 yr ago)

; slow annual cycle
f2 = addfile("/data5/hsushipei/data/wh04_data/mean_and_demean_slow_annual_cycle_data/mean_and_demean_slow_annual_cycle_oisst.nc","r")
date = f2->time
varsac = f2->$variab$(:,{lats:latn},:) ; [365]x[nlat]x[nlon]
;varsac = f2->sst(:,{lats:latn},{lon1:lon2}) ; [365]x[nlat]x[nlon]
printVarSummary(varsac)

;;---- Extend slow annual cycle data if realtime data spans through 12/31
; cut data spaning from 1/1 to given date -> the section to extend
rt_end_mmdd =str_split_by_length(dend,(/4,4/))
varsac2 = f2->$variab$({:"2016"+rt_end_mmdd(1)},{lats:latn},:)  ; from 1/1 to given data
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
new_period_ind = ind(ext_sac_time.eq."2016"+rt_end_mmdd(1))
varsac = varsac_x(( new_period_ind(0)+1 ):new_period_ind(1),:,:) ; "varsac" variable will be called later
printVarSummary(varsac) ; having the same period to real time data
;print(varsac&time)

; time mean
varm = f2->$variabm$({lats:latn},:) ; [nlat]x[nlon]
;printVarSummary(varm)

;;--- Regrdding
; Regrid sac data to rt data
;loni = varsac&lon
;lati = varsac&lat
;lono = varrt&lon
;lato = varrt&lat
;varsac_rg = linint2_Wrap(loni, lati, varsac, True, lono, lato, 0)
;varm_rg = linint2_Wrap(loni, lati, varm, True, lono, lato, 0)

; Regrid rt data to sac data
loni = sst&lon
lati = sst&lat
lono = varsac&lon
lato = varsac&lat
varrt_rg = linint2_Wrap(loni, lati, sst, True, lono, lato, 0)
delete(sst)
varrt = varrt_rg
delete(varrt_rg)
varsac_rg = varsac
varm_rg = varm

printVarSummary(varsac_rg)
printVarSummary(varm_rg)
printVarSummary(varrt)

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
print("netcdf file done-> "+outf)

end
