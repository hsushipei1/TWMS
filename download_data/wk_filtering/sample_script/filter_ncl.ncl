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

lats = -30  ; lat span of output data
latn = 30    
;rt_start = 20160625 ; data period
;rt_end = 20170624  ; !!! rt_end - rt_start = 1 year
zero_d = 659 ; !!! DO NOT CHANGE
variab = "olr"
;variab = "u925"
;variab = "v925"
mis = -999 ; missing value
mis@_FillValue = -999 ; missing value

; option for kf_filter
;tMin = 9.7
;tMax = 48
;kMin = -10
;kMax = -1
;hMin = 8
;hMax = 90
;waveName = "ER"  
tMin = 2.5
tMax = 30
kMin = 1
kMax = 14
hMin = 8
hMax = 90
waveName = "Kelvin"  
;tMin = 2.5
;tMax = 10
;kMin = -14
;kMax = 0
;hMin = 8
;hMax = 90
;waveName = "MRG"
;tMin = 20
;tMax = 100
;kMin = 0
;kMax = 9
;hMin = mis
;hMax = mis
;waveName = "MJO"  
obsPerDay = 1

;;---- read data
; real-time data (no leap day)
f = addfile("/data5/hsushipei/data/total_field/OLR/realtime/latest.nc","r")
;f = addfile("/data5/hsushipei/data/fnl/sliced/fnl025_u_20151101_201705_daily.nc","r")
;f = addfile("/data5/hsushipei/data/fnl/sliced/fnl025_v_20151101_201705_daily.nc","r")

;; for NetCDF file
olr_tc = f->time ; for NetCDF file
olrt_split = str_split_by_length( tostring(olr_tc) ,(/4,2,2/) )
olrt_noleap = olr_tc(ind( .not.((olrt_split(:,1).eq."02").and.(olrt_split(:,2).eq."29")) ))
rt_end = olrt_noleap(dimsizes(olrt_noleap)-1)
rt_start = olrt_noleap(dimsizes(olrt_noleap)-365)
olrs = f->olr({olrt_noleap({rt_start:rt_end})},{lats:latn},:) ; [ntime]x[nlat]x[nlon]
;olrs = f->u({olrt_noleap({rt_start:rt_end+1})},{92500},{lats:latn},:) ; [ntime]x[nlat]x[nlon]
;olrs = f->v({olrt_noleap({rt_start:rt_end+1})},{92500},{lats:latn},:) ; [ntime]x[nlat]x[nlon]

; !!! When filtering FNL data (0.25 deg), real-time data regridding (to lower its spacial resolution) is neccessary.
olr = olrs           ; comment out when real-time data regridding is needed
dim = dimsizes(olr)  ; comment out when real-time data regridding is needed
;olrs@_FillValue = -99999999 
printVarSummary(olr) ; comment out when real-time data regridding is needed
;printVarSummary(olrs)

; time mean and slow annaul cycle data
f2 = addfile("/data5/hsushipei/data/wh04_data/mean_and_demean_slow_annual_cycle_data/mean_and_demean_slow_annual_cycle_olr.nc","r")
;f2 = addfile("/data5/hsushipei/data/wh04_data/mean_and_demean_slow_annual_cycle_data/mean_and_demean_slow_annual_cycle_u925.nc","r")
;f2 = addfile("/data5/hsushipei/data/wh04_data/mean_and_demean_slow_annual_cycle_data/mean_and_demean_slow_annual_cycle_v925.nc","r")
olrsac = f2->olr(:,{lats:latn},:) ; [365]x[nlat]x[nlon] 
olrm = f2->olrm({lats:latn},:) ;[nlat]x[nlon]
;olrsac = f2->u925(:,{lats:latn},:) ; [365]x[nlat]x[nlon] 
;olrm = f2->u925m({lats:latn},:) ;[nlat]x[nlon]
;olrsac = f2->v925(:,{lats:latn},:) ; [365]x[nlat]x[nlon] 
;olrm = f2->v925m({lats:latn},:) ;[nlat]x[nlon]
printVarSummary(olrsac)
printVarSummary(olrm)

;;---- extend slow annual cycle data if realtime data spans through 12/31
; cut data spaning from 1/1 to given date -> the section to extend
rt_end_mmdd =str_split_by_length(rt_end,(/4,4/)) 
olrsac2 = f2->olr({:"2000"+rt_end_mmdd(1)},{lats:latn},:)  ; from 1/1 to given data
;olrsac2 = f2->u925({:"2000"+rt_end_mmdd(1)},{lats:latn},:)  ; from 1/1 to given data
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
;loni = olrs&longitude 
;lati = olrs&latitude
;lono = olrsac&lon
;lato = olrsac&lat
;olr = linint2_Wrap(loni, lati, olrs, True, lono, lato, 0)
;dim = dimsizes(olr)
;printVarSummary(olr)
;delete(loni)
;delete(lati)
;delete(lono)
;delete(lato)

;;---- regrid slow annual cycle and time mean (2.5deg) to match realtime date (1deg)
loni = olrsac&lon
lati = olrsac&lat
lono = olr&lon 
lato = olr&lat 
olrsac_rg = linint2_Wrap(loni, lati, olrsac, True, lono, lato, 0)
olrm_rg = linint2_Wrap(loni, lati, olrm, True, lono, lato, 0)
;olrsac_rg = olrsac ; comment out when filtering OLR data 
;olrm_rg = olrm     ; comment out when filtering OLR data 
printVarSummary(olrsac_rg)
printVarSummary(olrm_rg)
printVarSummary(olr)

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
rt_end_split = tointeger(str_split_by_length( rt_end,(/4,2,2/))) ; end date of real-time data
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
filt_var = new(dim_ex, typeof(olr)) ; [1024]x[nlat]x[nlon]
copy_VarCoords(ex_data, filt_var)
do nn = 0, dim(1)-1
	print("Filtering lat= "+lat_ary(nn))
	filt_var(:,{lat_ary(nn)},:) = \
				kf_filter(ex_data(:,{lat_ary(nn)},:), obsPerDay, tMin, tMax, kMin, kMax, hMin, hMax, waveName)
end do
filt_var@units = olrs@units
filt_var@end_date = rt_end
printVarSummary(filt_var)
;print(filt_var(:,{0},{120}))
;print(any(ismissing(filt_var))) ; any missing value?

;;---- output NetCDF
;outf = "wk99_filt_"+waveName+"_"+variab+"_"+rt_start+"_"+rt_end+".nc"
outdir = "/data5/hsushipei/filters/wk99_filter_ncl/latest/"
outf = "wk99_filt_"+waveName+"_"+variab+"_latest.nc"
system("/bin/rm -f "+outdir+outf)
ncdf1 = addfile(outdir+outf ,"c")
filedimdef(ncdf1,"time",-1,True)
ncdf1->$(variab)$ = filt_var
print("output-> "+outdir+outf)

end
