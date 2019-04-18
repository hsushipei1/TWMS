load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/kf_filter.ncl"
begin

;;---- NECESSARY INPUT data
; 1) Real-time data
; 2) Time mean and demean slow annual cycle
;    =>/data5/hsushipei/data/ymc_weathermap_data/penta_data/wh04_data

;;---- NOTE ON FILTERING PERIOD
; It's recommended that the filtering time span is shorter than one year and specify Jan 1 as the beginning.
; @ Example1: Filtering period: 20160101 to 20161231
; => Set rt_start = 20160101 and rt_end = 20161231
; @ Example2: Filtering period: 20170101 to 20170219
;=> Set rt_start = 20170101 and rt_end = 20170219
; @ Example3: Filtering period: 20160101 to 20170219
; Run this script twice and merge the data of 2016 and 2017.

; basic parameters
lats = -90  ; lat span of output data
latn = 90    
fcstModel = "GFSfcst"
variab = "v200"
plev = 200

; dont modify
zero_d = 659 ; !!! DO NOT CHANGE
obsPerDay = 1
mis = -999 ; missing value
mis@_FillValue = -999 ; missing value

; option for kf_filter
; MJO
mjo_tMin = 30
mjo_tMax = 96
mjo_kMin = 1
mjo_kMax = 5
mjo_hMin = mis
mjo_hMax = mis
mjo_waveName = "none"  ; Wheeler and Kiladis 1999
mjo_trueWaveName = "WK99_MJO"  

; Kelvin
k_tMin = 2.5
k_tMax = 30
k_kMin = 1
k_kMax = 14
k_hMin = 8
k_hMax = 90
k_waveName = "Kelvin"  ; Wheeler and Kiladis 1999
k_trueWaveName = "WK99_Kelvin"  

; ER
er_tMin = 9.7
er_tMax = 48
er_kMin = -10
er_kMax = -1
er_hMin = 8
er_hMax = 90
er_waveName = "ER"  ; Wheeler and Kiladis 1999
er_trueWaveName = "WK99_ER"  

; MRG/TD
mt_tMin = 2.5
mt_tMax = 10
mt_kMin = -14
mt_kMax = 0
mt_hMin = mis
mt_hMax = mis
mt_waveName = "none"  ; Frank and Roundy 2006
mt_trueWaveName = "FR06_MRG-TD"  

;;---- read data (350 days obs + 15 days GFS fcst)
; real-time data (no leap day)
fils = systemfunc ("ls /data5/hsushipei/data/fnl/sliced/latest/daily/fnl025_v_*.nc4")
f_li = fils( dimsizes( fils )-350:dimsizes( fils )-1 )
;f_li = fils ; read all pw files
date_li = str_split_by_length( f_li, (/56, 8, 3/) ) ; date list
date_li2 = date_li(:,1)
split_date = str_split_by_length( date_li2, (/4, 2, 2/) ) ; yyyy mm dd
no_leap_ind = ind (.not.( (split_date(:,1).eq."02").and.(split_date(:,2).eq."29") )) ; without leap day 
f = addfiles (f_li(no_leap_ind), "r")
ListSetType(f, "cat")
varrt = f[:]->v(:,{plev},{lats:latn},:) ; time x lat x lon
printVarSummary(varrt)

rt_time = varrt&time 
rt_start = rt_time(0) ; first day of RT data
rt_start@time = rt_time(0) 
rt_end = rt_time( dimsizes(rt_time)-1 ) ; end of RT data
rt_end@time = rt_time( dimsizes(rt_time)-1 ) 

; GFS forecast (no leap day)
fils3 = systemfunc ("ls /data5/hsushipei/data/gfs/ncep/gfs.v.*.pgrb2.1p00.f000_f384.daily.nc")
f3 = addfiles (fils3, "r")
ListSetType (f3, "cat")
varf = f3[:]->VGRD(1:dimsizes(f3[:]->time)-2,{plev},{lats:latn},:) ; start from 2nd
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
;exit

; time mean and slow annaul cycle data
f2 = addfile("/data5/hsushipei/data/wh04_data/mean_and_demean_slow_annual_cycle_data/mean_and_demean_slow_annual_cycle_v"+plev+".nc","r")
varsac = f2->$variab$(:,{lats:latn},:) ; [365]x[nlat]x[nlon] 
varm = f2->$(variab+"m")$({lats:latn},:) ;[nlat]x[nlon]
printVarSummary(varsac)
printVarSummary(varm)

;;---- Regrid: regrid RT, GFS to 0.75 (clim)
dimname = getvardims(varrt) ; t, lat, lon

; RT 
loni = varrt&$dimname(2)$
lati = varrt&$dimname(1)$
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

ntime = varrt&time
dim = dimsizes(varrt)
dend = ntime( dimsizes(ntime)-1 )
dstart = ntime(0)

;;---- extend slow annual cycle data if realtime data spans through 12/31
;;;; Here, input the end date only, and the 365-day slow annual cycle will be created. ;;;;;
; cut data spaning from 1/1 to given date -> the section to extend
rt_end_mmdd =str_split_by_length(dend,(/4,4/)) ; in fnl+gfs, rt_end is replaced by fcst_end
varsac2 = f2->$variab$({:"2012"+rt_end_mmdd(1)},{lats:latn},:)  ; from 1/1 to given data
;printVarSummary(varsac2)

; extend slow annual cycle
varsac_x = array_append_record(varsac, varsac2, 0)  ; [ntime_ext]x[nlat]x[nlon] , x=extended
varsac_x@long_name = "Extended slow annual cycle"
printVarSummary(varsac_x)
delete(varsac)
delete(varsac2)
ext_sac_time = varsac_x&time
new_period_ind = ind(ext_sac_time.eq."2012"+rt_end_mmdd(1))
varsac = varsac_x(( new_period_ind(0)+1 ):new_period_ind(1),:,:) ; "varsac" variable will be called later
printVarSummary(varsac) ; having the same period to real time data
;print(varsac&time)

varsac_rg = varsac ; FNL data 
varm_rg = varm     ; FNL data

; check point
printVarSummary(varsac_rg)
printVarSummary(varm_rg)
printVarSummary(varrt)
;exit

;;---- Remove long-term time mean and first 3 harmonics of annual cycle(slow annual cycle)
; Substract time mean
var_nom = new(dimsizes(varrt), typeof(varrt)) ; [ntime]x[nlat]x[nlon] , nom = no mean
do t = 0, dimsizes(varrt&time)-1 ; NetCDF
;do t = 0, dimsizes(varrt&initial_time0_hours)-1 ; grib2
    var_nom(t,:,:) = varrt(t,:,:) - varm_rg
end do
copy_VarCoords(varrt, var_nom)
var_nom@long_name = "tot_minus_time_mean_"+variab
printVarSummary(var_nom)
;print(var_nom(:,{10},{120}))

; Substract slow annual cycle
var_nosac = new( dimsizes(varrt), typeof(varrt)) ; [ntime]x[nlat]x[nlon], nosac = no slow annual cycle
;var_nosac = var_nom - varsac_rg({20000101:20001130+1},:,:)  ; to 20161215
var_nosac = var_nom - varsac_rg  ; to 20161215
copy_VarCoords(varrt, var_nosac)
var_nosac@long_name = "tot_minus_time_mean_minus_first_3_harmonics_"+variab
var_nosac!0 = "time" ; conventional coordinate name for NetCDF
printVarSummary(var_nosac)
;print(var_nosac(:,{0},{120}))

;;---- extended data for filter: zero padding
zeros = new((/zero_d, dim(1), dim(2)/), typeof(varrt))
zeros = 0.
zeros!0 = "time"
zeros!1 = "lat"
zeros!2 = "lon"
zeros&lat = varrt&lat
zeros&lon = varrt&lon

; deal with date of extended data
rt_end_split = tointeger(str_split_by_length( fcst_end,(/4,2,2/))) ; end date of fcst data
ddd = ispan(1,zero_d, 1 )
ddd@units = "days since "+rt_end_split(0)+"-"+rt_end_split(1)+"-"+rt_end_split(2)+" 00:00:00"
ex_d = cd_calendar(ddd,2) ; calculate YYYYMMDD
copy_VarAtts(varrt&time, ex_d) ; copy time attribute from standard netcdf data to extended time coordinate
zeros&time = ex_d ; define time coordinate
printVarSummary(zeros)

;;---- extend the data
; anomaly for filtering
ex_data = array_append_record(var_nosac, zeros, 0) ; [1024]x[nlat]x[nlon]
printVarSummary(ex_data)
;print(ex_data(:,{0},{120}))
;asciiwrite("ts.csv",ex_data(:,{10},{120}))

;;---- apply kf_filter to each latitude
lat_ary = varrt&lat ; latitude array
dim_ex = dimsizes(ex_data) ; (1024, nlat, nlon)
;filt_var = new(dim_ex, typeof(var)) ; [1024]x[nlat]x[nlon]
;copy_VarCoords(ex_data, filt_var)

filt_mjo = new(dim_ex, typeof(varrt)) ; mjo [1024]x[nlat]x[nlon]
filt_kel = new(dim_ex, typeof(varrt)) ; kelvin wave [1024]x[nlat]x[nlon]
filt_er = new(dim_ex, typeof(varrt)) ; er [1024]x[nlat]x[nlon]
filt_mt = new(dim_ex, typeof(varrt)) ; mt [1024]x[nlat]x[nlon]
copy_VarCoords(ex_data, filt_mjo)
copy_VarCoords(ex_data, filt_kel)
copy_VarCoords(ex_data, filt_er)
copy_VarCoords(ex_data, filt_mt)

do nn = 0, dim(1)-1
	print("Filtering lat= "+lat_ary(nn))
	;filt_var(:,{lat_ary(nn)},:) = \
	;			kf_filter(ex_data(:,{lat_ary(nn)},:), obsPerDay, tMin, tMax, kMin, kMax, hMin, hMax, waveName)
	filt_mjo(:,{lat_ary(nn)},:) = \
				kf_filter(ex_data(:,{lat_ary(nn)},:), obsPerDay, mjo_tMin, mjo_tMax,\
							mjo_kMin, mjo_kMax, mjo_hMin, mjo_hMax, mjo_waveName)
	filt_kel(:,{lat_ary(nn)},:) = \
				kf_filter(ex_data(:,{lat_ary(nn)},:), obsPerDay, k_tMin, k_tMax,\
							k_kMin, k_kMax, k_hMin, k_hMax, k_waveName)
	filt_er(:,{lat_ary(nn)},:) = \
				kf_filter(ex_data(:,{lat_ary(nn)},:), obsPerDay, er_tMin, er_tMax,\
							er_kMin, er_kMax, er_hMin, er_hMax, er_waveName)
	filt_mt(:,{lat_ary(nn)},:) = \
				kf_filter(ex_data(:,{lat_ary(nn)},:), obsPerDay, mt_tMin, mt_tMax,\
							mt_kMin, mt_kMax, mt_hMin, mt_hMax, mt_waveName)
end do
;filt_var@units = vars@units
;filt_var@data = "Observation: "+rt_start+" to "+rt_end+", "+fcstModel+": "+fcst_start+" to "+fcst_end
;printVarSummary(filt_var)

filt_mjo@wave = mjo_trueWaveName
filt_mjo@units = varrt@units
filt_mjo@data = "Observation: "+rt_start+" to "+rt_end+", "+fcstModel+": "+fcst_start+" to "+fcst_end
filt_kel@wave = k_trueWaveName
filt_kel@units = varrt@units
filt_kel@data = "Observation: "+rt_start+" to "+rt_end+", "+fcstModel+": "+fcst_start+" to "+fcst_end
filt_er@wave = er_trueWaveName
filt_er@units = varrt@units
filt_er@data = "Observation: "+rt_start+" to "+rt_end+", "+fcstModel+": "+fcst_start+" to "+fcst_end
filt_mt@wave = mt_trueWaveName
filt_mt@units = varrt@units
filt_mt@data = "Observation: "+rt_start+" to "+rt_end+", "+fcstModel+": "+fcst_start+" to "+fcst_end
printVarSummary(filt_mjo)

print(filt_mjo(:,{0},{120}))
;print(any(ismissing(filt_var))) ; any missing value?
;exit

;;---- output NetCDF
;outf = "wk99_filt_"+waveName+"_"+variab+"_"+rt_start+"_"+rt_end+".nc"
outdir = "/data5/hsushipei/filters/wk99_filter_ncl/latest/"
;outf = "wk99_filt_"+waveName+"_"+variab+"_"+fcstModel+"_latest.nc"
outf = "wk99_filt_allwave_"+variab+"_"+fcstModel+"_latest.nc"
system("/bin/rm -f "+outdir+outf)

setfileoption("nc","Format","NetCDF4Classic") ; compress NetCDF
setfileoption("nc","CompressionLevel",4) ; compress NetCDF

ncdf1 = addfile(outdir+outf ,"c")
filedimdef(ncdf1,"time",-1,True)
;ncdf1->$(variab)$ = filt_var ; remain forecast by zero padding (following the GFS data)
;ncdf1->$(variab)$ = filt_var({rt_start:fcst_end},:,:) ; abandon the part of zero padding

mjo_out = variab+"mjo"
kel_out = variab+"kel"
er_out = variab+"er"
mt_out = variab+"mt"
ncdf1->$(mjo_out)$ = filt_mjo({rt_start:fcst_end},:,:) ; abandon the part of zero padding
ncdf1->$(kel_out)$ = filt_kel({rt_start:fcst_end},:,:) ; abandon the part of zero padding
ncdf1->$(er_out)$ = filt_er({rt_start:fcst_end},:,:) ; abandon the part of zero padding
ncdf1->$(mt_out)$ = filt_mt({rt_start:fcst_end},:,:) ; abandon the part of zero padding
ncdf1->rt_startdate = rt_start
ncdf1->rt_enddate = rt_end
ncdf1->fcst_startdate = fcst_start
ncdf1->fcst_enddate = fcst_end
print("output-> "+outdir+outf)

end
