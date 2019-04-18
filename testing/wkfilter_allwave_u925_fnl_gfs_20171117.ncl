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
lats = -30  ; lat span of output data
latn = 30    
;rt_start = 20160101 ; data period
;rt_end = 20161231  ; !!! rt_end - rt_start = 1 year
fcstModel = "GFSfcst"
;variab = "olr"
variab = "u925"
;variab = "v925"

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
;f = addfile("/data5/hsushipei/data/total_field/OLR/realtime/latest.nc","r")
f = addfile("/data5/hsushipei/data/fnl/sliced/latest/daily/fnl025_u_201601_latest_daily.nc","r")
;f = addfile("/data5/hsushipei/data/fnl/sliced/fnl025_v_20151101_201705_daily.nc","r")
olr_tc = f->time 
olrt_split = str_split_by_length( tostring(olr_tc) ,(/4,2,2/) )
olrt_noleap = olr_tc(ind( .not.((olrt_split(:,1).eq."02").and.(olrt_split(:,2).eq."29")) ))
rt_end = olrt_noleap(dimsizes(olrt_noleap)-1) ; End date of real time total field
rt_end@long_name = "End date of real time total field"
rt_start = olrt_noleap(dimsizes(olrt_noleap)-350) ; start date of read real time total field
rt_start@long_name = "Start date of real time total field"
;olrs = f->olr({olrt_noleap({rt_start:rt_end})},{lats:latn},:) ; [ntime]x[nlat]x[nlon]
olrs = f->UGRD({olrt_noleap({rt_start:rt_end})},{925},{lats:latn},:) ; [ntime]x[nlat]x[nlon]
;olrs = f->v({olrt_noleap({rt_start:rt_end})},{925},{lats:latn},:) ; [ntime]x[nlat]x[nlon]

; !!! When filtering FNL data (0.25 deg), real-time data regridding (to lower its spacial resolution) is neccessary.
;olr = olrs           ; filter OLR
;dim = dimsizes(olr)  ; filter OLR
olrs@_FillValue = -99999999 ; filter FNL
;printVarSummary(olr) ; filter OLR
printVarSummary(olrs) ; filter FNL

; GFS forecast (no leap day)
fils3 = systemfunc ("ls /data5/hsushipei/data/gfs/ncep/gfs.u.*.pgrb2.1p00.f000_f384.daily.nc")
f3 = addfiles (fils3, "r")   
ListSetType (f3, "cat")
varf = f3[:]->UGRD(1:dimsizes(f3[:]->time)-2,{925},{lats:latn},:) ; start from 1st
fcst_tc = decimalPlaces(varf&time,0, False) ; time coordinate of forecast data
fcst_start = fcst_tc(0)
fcst_start@long_name = "Start date of "+fcstModel
fcst_end = fcst_tc(dimsizes(fcst_tc)-1)
fcst_end@long_name = "End date of "+fcstModel
varf&time = fcst_tc
printVarSummary(varf)

; time mean and slow annaul cycle data
;f2 = addfile("/data5/hsushipei/data/wh04_data/mean_and_demean_slow_annual_cycle_data/mean_and_demean_slow_annual_cycle_olr.nc","r")
f2 = addfile("/data5/hsushipei/data/wh04_data/mean_and_demean_slow_annual_cycle_data/mean_and_demean_slow_annual_cycle_u925.nc","r")
;f2 = addfile("/data5/hsushipei/data/wh04_data/mean_and_demean_slow_annual_cycle_data/mean_and_demean_slow_annual_cycle_v925.nc","r")
;olrsac = f2->olr(:,{lats:latn},:) ; [365]x[nlat]x[nlon] 
;olrm = f2->olrm({lats:latn},:) ;[nlat]x[nlon]
olrsac = f2->u925(:,{lats:latn},:) ; [365]x[nlat]x[nlon] 
olrm = f2->u925m({lats:latn},:) ;[nlat]x[nlon]
;olrsac = f2->v925(:,{lats:latn},:) ; [365]x[nlat]x[nlon] 
;olrm = f2->v925m({lats:latn},:) ;[nlat]x[nlon]
printVarSummary(olrsac)
printVarSummary(olrm)

;;---- extend slow annual cycle data if realtime data spans through 12/31
;;;; Here, input the end date only, and the 365-day slow annual cycle will be created. ;;;;;
; cut data spaning from 1/1 to given date -> the section to extend
rt_end_mmdd =str_split_by_length(fcst_end,(/4,4/)) ; in fnl+gfs, rt_end is replaced by fcst_end
;olrsac2 = f2->olr({:"2000"+rt_end_mmdd(1)},{lats:latn},:)  ; from 1/1 to given data
olrsac2 = f2->u925({:"2000"+rt_end_mmdd(1)},{lats:latn},:)  ; from 1/1 to given data
;olrsac2 = f2->v925({:"2000"+rt_end_mmdd(1)},{lats:latn},:)  ; from 1/1 to given data
;printVarSummary(olrsac2)

; extend slow annual cycle
olrsac_x = array_append_record(olrsac, olrsac2, 0)  ; [ntime_ext]x[nlat]x[nlon] , x=extended
olrsac_x@long_name = "Extended slow annual cycle"
printVarSummary(olrsac_x)
delete(olrsac)
delete(olrsac2)
ext_sac_time = olrsac_x&time
new_period_ind = ind(ext_sac_time.eq."2000"+rt_end_mmdd(1))
olrsac = olrsac_x(( new_period_ind(0)+1 ):new_period_ind(1),:,:) ; "olrsac" variable will be called later
printVarSummary(olrsac) ; having the same period to real time data
;print(olrsac&time)

;;---- REGRIDDING
; regrid real-time data (needed when filtering 0.25 deg FNL data)
loni = olrs&longitude 
lati = olrs&latitude
lono = olrsac&lon
lato = olrsac&lat
olr = linint2_Wrap(loni, lati, olrs, True, lono, lato, 0) ; realtime data
dim = dimsizes(olr)
printVarSummary(olr)
delete(loni)
delete(lati)

; & GFS forecast (1 deg originally)
loni = varf&longitude 
lati = varf&latitude
varf2 = linint2_Wrap(loni, lati, varf, True, lono, lato, 0) ; GFS data
delete(varf)
delete(loni)
delete(lati)
delete(lono)
delete(lato)

;;---- regrid slow annual cycle and time mean (2.5deg) to match realtime date (1deg)
;loni = olrsac&lon
;lati = olrsac&lat
;lono = olr&lon 
;lato = olr&lat 
;olrsac_rg = linint2_Wrap(loni, lati, olrsac, True, lono, lato, 0)
;olrm_rg = linint2_Wrap(loni, lati, olrm, True, lono, lato, 0)
olrsac_rg = olrsac ; FNL data 
olrm_rg = olrm     ; FNL data
printVarSummary(olrsac_rg)
printVarSummary(olrm_rg)
printVarSummary(olr)
printVarSummary(varf2)

;;----- Merge Realtime & GFS forecast data
olr2 = array_append_record(olr, varf2, 0)
delete(olr)
delete(varf2)
olr = olr2
delete(olr2)
printVarSummary(olr)
;exit

;;---- Remove long-term time mean and first 3 harmonics of annual cycle(slow annual cycle)
; Substract time mean
olr_nom = new(dimsizes(olr), typeof(olr)) ; [ntime]x[nlat]x[nlon] , nom = no mean
do t = 0, dimsizes(olr&time)-1 ; NetCDF
;do t = 0, dimsizes(olr&initial_time0_hours)-1 ; grib2
    olr_nom(t,:,:) = olr(t,:,:) - olrm_rg
end do
copy_VarCoords(olr, olr_nom)
olr_nom@long_name = "tot_minus_time_mean_"+variab
printVarSummary(olr_nom)
;print(olr_nom(:,{10},{120}))

; Substract slow annual cycle
olr_nosac = new( dimsizes(olr), typeof(olr)) ; [ntime]x[nlat]x[nlon], nosac = no slow annual cycle
;olr_nosac = olr_nom - olrsac_rg({20000101:20001130+1},:,:)  ; to 20161215
olr_nosac = olr_nom - olrsac_rg  ; to 20161215
copy_VarCoords(olr, olr_nosac)
olr_nosac@long_name = "tot_minus_time_mean_minus_first_3_harmonics_"+variab
olr_nosac!0 = "time" ; conventional coordinate name for NetCDF
printVarSummary(olr_nosac)
;print(olr_nosac(:,{0},{120}))

;;---- extended data for filter: zero padding
zeros = new((/zero_d, dim(1), dim(2)/), typeof(olr))
zeros = 0.
zeros!0 = "time"
zeros!1 = "lat"
zeros!2 = "lon"
zeros&lat = olr&lat
zeros&lon = olr&lon

; deal with date of extended data
rt_end_split = tointeger(str_split_by_length( fcst_end,(/4,2,2/))) ; end date of fcst data
ddd = ispan(1,zero_d, 1 )
ddd@units = "days since "+rt_end_split(0)+"-"+rt_end_split(1)+"-"+rt_end_split(2)+" 00:00:00"
ex_d = cd_calendar(ddd,2) ; calculate YYYYMMDD
copy_VarAtts(olr&time, ex_d) ; copy time attribute from standard netcdf data to extended time coordinate
zeros&time = ex_d ; define time coordinate
printVarSummary(zeros)

;;---- extend the data
; anomaly for filtering
ex_data = array_append_record(olr_nosac, zeros, 0) ; [1024]x[nlat]x[nlon]
printVarSummary(ex_data)
;print(ex_data(:,{0},{120}))
;asciiwrite("ts.csv",ex_data(:,{10},{120}))

;;---- apply kf_filter to each latitude
lat_ary = olr&lat ; latitude array
dim_ex = dimsizes(ex_data) ; (1024, nlat, nlon)
;filt_var = new(dim_ex, typeof(olr)) ; [1024]x[nlat]x[nlon]
;copy_VarCoords(ex_data, filt_var)

filt_mjo = new(dim_ex, typeof(olr)) ; mjo [1024]x[nlat]x[nlon]
filt_kel = new(dim_ex, typeof(olr)) ; kelvin wave [1024]x[nlat]x[nlon]
filt_er = new(dim_ex, typeof(olr)) ; er [1024]x[nlat]x[nlon]
filt_mt = new(dim_ex, typeof(olr)) ; mt [1024]x[nlat]x[nlon]
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
;filt_var@units = olrs@units
;filt_var@data = "Observation: "+rt_start+" to "+rt_end+", "+fcstModel+": "+fcst_start+" to "+fcst_end
;printVarSummary(filt_var)

filt_mjo@wave = mjo_trueWaveName
filt_mjo@units = olrs@units
filt_mjo@data = "Observation: "+rt_start+" to "+rt_end+", "+fcstModel+": "+fcst_start+" to "+fcst_end
filt_kel@wave = k_trueWaveName
filt_kel@units = olrs@units
filt_kel@data = "Observation: "+rt_start+" to "+rt_end+", "+fcstModel+": "+fcst_start+" to "+fcst_end
filt_er@wave = er_trueWaveName
filt_er@units = olrs@units
filt_er@data = "Observation: "+rt_start+" to "+rt_end+", "+fcstModel+": "+fcst_start+" to "+fcst_end
filt_mt@wave = mt_trueWaveName
filt_mt@units = olrs@units
filt_mt@data = "Observation: "+rt_start+" to "+rt_end+", "+fcstModel+": "+fcst_start+" to "+fcst_end
printVarSummary(filt_mjo)

;print(filt_var(:,{0},{120}))
;print(any(ismissing(filt_var))) ; any missing value?

;;---- output NetCDF
;outf = "wk99_filt_"+waveName+"_"+variab+"_"+rt_start+"_"+rt_end+".nc"
outdir = "/data5/hsushipei/filters/wk99_filter_ncl/latest/"
;outf = "wk99_filt_"+waveName+"_"+variab+"_"+fcstModel+"_latest.nc"
outf = "wk99_filt_allwave_"+variab+"_"+fcstModel+"_latest.nc"
system("/bin/rm -f "+outdir+outf)
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
