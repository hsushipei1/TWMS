import os, datetime
"""
Download OISST once per week
"""

currt = datetime.datetime.now()
currt_yy = currt.strftime('%Y')
data_dir = "/data5/hsushipei/data/total_field/SST/noaa_oisst_v2"

os.chdir(data_dir)
wlink = "ftp://ftp.cdc.noaa.gov/Datasets/noaa.oisst.v2.highres/sst.day.mean."+currt_yy+".v2.nc"
data_name = os.path.basename(wlink)

# Delete previous data
try:
	os.remove(data_dir+"/"+data_name)
	print "Previous data "+data_name+" deleted for the following "+data_name+" download."
except:
	pass

# Download data
os.system("wget -q "+wlink)
