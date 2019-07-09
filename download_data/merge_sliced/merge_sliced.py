#!/home/hsushipei/miniconda2/bin/python
import os, pickle, datetime, sys
sys.path.append(os.path.abspath("/data5/hsushipei/tropical_weather_monitoring_system/development/dev_compression/download_data/fnl_compression"))
from fnl_daily_compressor import compress_fnl_daily

#CDO = "~/software/PREVIOUS_SOFTWARE/cdo-1.9.3/bin/cdo -O "
CDO = "~/software/bin/cdo -O "
NCCOPY = "~/software/bin/nccopy"
slic_6h_dir = "/data5/hsushipei/data/fnl/sliced/latest/6hr/"
slic_day_dir = "/data5/hsushipei/data/fnl/sliced/latest/daily/"

crt = datetime.datetime.strptime( (sys.argv[1]), "%Y%m%d%H" ) # read current time from command line
crtyyyymmdd = crt.strftime("%Y%m%d")
crtH = crt.strftime("%H") # hr of each day
crtd = crt.strftime("%d") # "day"

def sixhr2daily( indv_6h_files, singldaily_file, varname_ori, varname_chd ):
	"""
	20180722
	Merge 6 hr data to daily data and compress it. 
	"""
	os.system(CDO+" -a -f nc -shifttime,-9hours -daymean -chname,'"+varname_ori+"','"+varname_chd+"' -cat '"+indv_6h_files+"' "+singldaily_file) # without compression


# At 18Z, run the following procedure
if crtH == "18":
	print "**** Enter 'merge_sliced.py' at "+str(crt)+" => Start merging sliced files ****"

	# Merge 6 hr data to daily data
	sixhr2daily( slic_6h_dir+"fnl025_pw_"+crtyyyymmdd+"*.nc4", \
			slic_day_dir+"fnl025_pw_"+crtyyyymmdd+"_unzip.nc4", "PWAT_entireatmosphere_consideredasasinglelayer_" ,"pw" )
	sixhr2daily( slic_6h_dir+"fnl025_u_"+crtyyyymmdd+"*.nc4", \
			slic_day_dir+"fnl025_u_"+crtyyyymmdd+"_unzip.nc4", "UGRD","u")
	sixhr2daily( slic_6h_dir+"fnl025_v_"+crtyyyymmdd+"*.nc4", \
			slic_day_dir+"fnl025_v_"+crtyyyymmdd+"_unzip.nc4","VGRD","v")
	sixhr2daily( slic_6h_dir+"fnl025_hgt_"+crtyyyymmdd+"*.nc4", \
			slic_day_dir+"fnl025_hgt_"+crtyyyymmdd+"_unzip.nc4","HGT","HGT")

	# Compress (with nccopy) daily data 
	compress_fnl_daily( slic_day_dir+"fnl025_pw_"+crtyyyymmdd+"_unzip.nc4", \
			slic_day_dir+"fnl025_pw_"+crtyyyymmdd+".nc4" )
	compress_fnl_daily( slic_day_dir+"fnl025_u_"+crtyyyymmdd+"_unzip.nc4", \
			slic_day_dir+"fnl025_u_"+crtyyyymmdd+".nc4" )
	compress_fnl_daily( slic_day_dir+"fnl025_v_"+crtyyyymmdd+"_unzip.nc4", \
			slic_day_dir+"fnl025_v_"+crtyyyymmdd+".nc4" )
	compress_fnl_daily( slic_day_dir+"fnl025_hgt_"+crtyyyymmdd+"_unzip.nc4", \
			slic_day_dir+"fnl025_hgt_"+crtyyyymmdd+".nc4" )
	
	# Remove intermediate file
	os.remove(slic_day_dir+"fnl025_pw_"+crtyyyymmdd+"_unzip.nc4")
	os.remove(slic_day_dir+"fnl025_u_"+crtyyyymmdd+"_unzip.nc4")
	os.remove(slic_day_dir+"fnl025_v_"+crtyyyymmdd+"_unzip.nc4")
	os.remove(slic_day_dir+"fnl025_hgt_"+crtyyyymmdd+"_unzip.nc4")

else:
	print "t= "+crtH+" Wait untill 18Z to create daily data."

print "**** Leave 'merge_sliced.py' at "+str(crt)+" => End merging sliced files ****"


