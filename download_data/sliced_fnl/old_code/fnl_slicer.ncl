begin

date = getenv("DATE") ; yyyymmddhh
varn = getenv("VAR")
prod = "fnl025"
lon1 = 0.
lon2 = 360.
lats = -90.
latn = 90.
plevs = (/10, 20, 30, 50, 70, 100, 150, 200, 250, 300, 350, 400, 450, 500,\ 
    550, 600, 650, 700, 750, 800, 850, 900, 925, 950, 975, 1000/)

;;---- var name
if (varn.eq."u") then
	varname = "UGRD_P0_L100_GLL0"
else if (varn.eq."v") then
	varname = "VGRD_P0_L100_GLL0"
end if
end if

;;---- split date
date_s = str_split_by_length(date, (/4,2,2,2/))
yy = date_s(0)
mm = date_s(1)
dd = date_s(2)
hh = date_s(3)

;;---- read data
;f = addfile("/data7/ECMWF/Interim_075/SFC/anl/EI075_SFC_"+date+"_anl_6hr.grib","r")
f = addfile("/data5/hsushipei/data/fnl/ncep/gdas1.fnl0p25."+date+".f00.grib2","r")
var = f->$varname$({plevs*100},{lats:latn},{lon1:lon2})
nlev = dimsizes(var&lv_ISBL0)
nlat = dimsizes(var&lat_0)
nlon = dimsizes(var&lon_0)
printVarSummary(var)
;printVarSummary(v925)

; read attribute of pressure coordinate
fp = addfile("/data5/hsushipei/data/fnl/sliced/latest/daily/fnl025_u_20180101.nc","r")
;pp = fp->plevel ; units: mb
pp = fp->lv_ISBL0 ; units: mb
copy_VarAtts(pp,plevs)
var&lv_ISBL0 = plevs
;printVarSummary(var)
;print(var({92500},{0},{120}))
;print(var&lv_ISBL0)

;;---- define time coordinate
; read time coordinate
;ft = addfile("/data5/hsushipei/data/total_field/OLR/olr_1975_2013_abs_t.nc","r")
tt = fp->time

; borrow attributes from predefined time coordinate
tt@units = "hours since "+yy+"-"+mm+"-"+dd+" "+hh+":00:00"

; generate dates from 2016120100 to 2016123121 with interval of 3 hours
d = 0 
copy_VarAtts(tt, d)
print("hr= "+d+" date="+cd_calendar(d,3))

outvar = new((/1,nlev,nlat,nlon/),typeof(var))
copy_VarAtts(var,outvar)

; define time coordinate 
outvar!0 = "time"
outvar&time = d
copy_VarCoords(var,outvar(0,:,:,:))
outvar(0,:,:,:) = var
printVarSummary(outvar)
print(outvar&time)
print(outvar&lv_ISBL0)

;;---- produce netcdf output file
outn = prod+"_"+varn+"_"+date+".nc"
system("/bin/rm -f "+outn)
ncdf1 = addfile(outn ,"c")
filedimdef(ncdf1,"time",-1,True)
ncdf1->$varn$ = outvar
print("======> NetCDF "+outn+" generated! ==========")

end
