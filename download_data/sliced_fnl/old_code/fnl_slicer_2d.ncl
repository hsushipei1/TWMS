begin

date = getenv("DATE") ; yyyymmddhh
varn = getenv("VAR")
prod = "fnl025"
lon1 = 0.
lon2 = 360.
lats = -90.
latn = 90.

;;---- var name
if (varn.eq."pw") then
	varname = "PWAT_P0_L200_GLL0"
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
var = f->$varname$({lats:latn},{lon1:lon2})
nlat = dimsizes(var&lat_0)
nlon = dimsizes(var&lon_0)
printVarSummary(var)
;printVarSummary(v925)

;;---- define time coordinate
; read time coordinate
ft = addfile("/data5/hsushipei/data/total_field/OLR/olr_1975_2013_abs_t.nc","r")
tt = ft->time(0:1)

; borrow attributes from predefined time coordinate
tt@units = "hours since "+yy+"-"+mm+"-"+dd+" "+hh+":00:00"

; generate dates from 2016120100 to 2016123121 with interval of 3 hours
d = 0 
copy_VarAtts(tt, d)
print("hr= "+d+" date="+cd_calendar(d,3))

outvar = new((/1,nlat,nlon/),typeof(var))
copy_VarAtts(var,outvar)

; define time coordinate 
outvar!0 = "time"
outvar&time = d
copy_VarCoords(var,outvar(0,:,:))
outvar(0,:,:) = var
printVarSummary(outvar)

;;---- produce netcdf output file
outn = prod+"_"+varn+"_"+date+".nc"
system("/bin/rm -f "+outn)
ncdf1 = addfile(outn ,"c")
filedimdef(ncdf1,"time",-1,True)
ncdf1->$varn$ = outvar
print("======> NetCDF "+outn+" generated! ==========")

end
