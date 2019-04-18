import os, pickle
"""
# Slice one variable from merged GFS data to single file (6 hourly), Convert 6-hourly data to daily
"""
gfs_data_dir = "/data5/hsushipei/data/gfs/ncep"
WGRIB2 = "/home/hsushipei/software/bundle/grib2/wgrib2/wgrib2"
CDO = "/home/hsushipei/software/PREVIOUS_SOFTWARE/cdo-1.9.3/bin/cdo"

f = open(gfs_data_dir+"/"+"current_data_time.txt","rb")
dd = pickle.load(f)
f.close()
data_time = dd.strftime('%Y%m%d%H')

# Configuration
var = "pw"
match_word = "':PWAT:'" # in grib2 GFS data
middle_file = "gfs."+var+"."+data_time+"."+"pgrb2.1p00.f000_f384.6hr.nc" # 6-hr nc file containing sliced var
output_nc_file = "gfs."+var+"."+data_time+"."+"pgrb2.1p00.f000_f384.daily.nc" # final output file

# Slice one variable
print "Slicing "+var+" from GFS on "+data_time+"..."
os.system(WGRIB2+" "+gfs_data_dir+"/gfs."+data_time+".pgrb2.1p00.f000_f384.grib2 -nc4 -netcdf "+gfs_data_dir+"/"+middle_file+" -match "+match_word)

# Convert to daily
print "Convert GFS 6hr "+var+" to daily mean..."
os.system(CDO+" -a -z zip_4 daymean "+gfs_data_dir+"/"+middle_file+" "+gfs_data_dir+"/"+output_nc_file)

# delete middle file
print "Remove middle file "+gfs_data_dir+"/"+middle_file
os.remove(gfs_data_dir+"/"+middle_file)
