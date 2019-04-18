import os, datetime, sys
"""
Slice 6 hr variable from FNL using wgrib2
(Hope this program can replace NCL slicer.)

Arguments:
	date: yyyymmddhh
"""
fnl_dir = "/data5/hsushipei/data/fnl/ncep"
output_dir = "/data5/hsushipei/data/fnl/sliced/latest/6hr"
WGRIB2 = "/home/hsushipei/software/bundle/grib2/wgrib2/wgrib2 "

## Slicing
datee = sys.argv[1] # slice fnl at datee, yyyymmddhh

# HGT: Geopotential at pressure level (netcdf4 zip) 
os.system(WGRIB2+fnl_dir+"/gdas1.fnl0p25."+datee+".f00.grib2 "+\
		"-match ':HGT:....*mb:' -nc4 -nc_nlev 26 -netcdf "+output_dir+"/fnl025_hgt_"+datee+".nc4")

# PWAT: precipitable water (netcdf4 zip) 
os.system(WGRIB2+fnl_dir+"/gdas1.fnl0p25."+datee+".f00.grib2 "+\
		"-match ':PWAT:' -nc4 -netcdf "+output_dir+"/fnl025_pw_"+datee+".nc4")

# UGRD: U at pressure level (netcdf4 zip) 
os.system(WGRIB2+fnl_dir+"/gdas1.fnl0p25."+datee+".f00.grib2 "+\
		"-match ':UGRD:....*mb:' -nc4 -nc_nlev 26 -netcdf "+output_dir+"/fnl025_u_"+datee+".nc4")

# VGRD: V at pressure level (netcdf4 zip) 
os.system(WGRIB2+fnl_dir+"/gdas1.fnl0p25."+datee+".f00.grib2 "+\
		"-match ':VGRD:....*mb:' -nc4 -nc_nlev 26 -netcdf "+output_dir+"/fnl025_v_"+datee+".nc4")


#wgrib2 gdas1.fnl0p25.2018042300.f00.grib2 -match ":HGT:....*mb:" -nc4 -nc_nlev 26  -netcdf ../test.nc
