#!/home/hsushipei/miniconda2/bin/python
import os, pickle, datetime, sys
CDO = "~/software/PREVIOUS_SOFTWARE/cdo-1.9.3/bin/cdo -O "
slic_6h_dir = "/data5/hsushipei/data/fnl/sliced/latest/6hr/"
slic_day_dir = "/data5/hsushipei/data/fnl/sliced/latest/daily/"

#f = open("/data5/hsushipei/tropical_weather_monitoring_system/download_data/sliced_fnl/current_time","r")
#crt = pickle.load(f) # latest time of sliced data
crt = datetime.datetime.strptime( (sys.argv[1]), "%Y%m%d%H" ) # read current time from command line
crtyyyymmdd = crt.strftime("%Y%m%d")
crtH = crt.strftime("%H") # hr of each day
crtd = crt.strftime("%d") # "day"
#print crt

def sixhr2daily( indv_6h_files, singldaily_file, varname_ori, varname_chd ):
	"""
	20180722
	Merge 6 hr data to daily data and compress it. 
	"""
	os.system(CDO+" -a -z zip_4 -f nc4 -shifttime,-9hours -daymean -chname,'"+varname_ori+"','"+varname_chd+"' -cat '"+indv_6h_files+"' "+singldaily_file)

def merg2_long_day_data(long_term_daily_file, singldaily_file ):
	"""
	Merge single daily data with long-term daily data.
	"""
	os.system(CDO+" mergetime "+long_term_daily_file+" "+singldaily_file+" "+long_term_daily_file+".temp")
	os.system("mv "+long_term_daily_file+".temp "+long_term_daily_file)

def to_rel_time(input_file, output_file):
	"""
	Create relative time coordinate version for grads
	"""
	os.system(CDO+" -r copy "+input_file+" "+output_file)


# At 18Z, run the following procedure
if crtH == "18":
	print "**** Enter 'merge_sliced.py' at "+str(crt)+" => Start merging sliced files ****"

	# Merge 6 hr data to daily data
	sixhr2daily( slic_6h_dir+"fnl025_pw_"+crtyyyymmdd+"*.nc4", slic_day_dir+"fnl025_pw_"+crtyyyymmdd+".nc4","PWAT_entireatmosphere_consideredasasinglelayer_" ,"pw" )
	sixhr2daily( slic_6h_dir+"fnl025_u_"+crtyyyymmdd+"*.nc4", slic_day_dir+"fnl025_u_"+crtyyyymmdd+".nc4","UGRD","u")
	sixhr2daily( slic_6h_dir+"fnl025_v_"+crtyyyymmdd+"*.nc4", slic_day_dir+"fnl025_v_"+crtyyyymmdd+".nc4","VGRD","v")
	sixhr2daily( slic_6h_dir+"fnl025_hgt_"+crtyyyymmdd+"*.nc4", slic_day_dir+"fnl025_hgt_"+crtyyyymmdd+".nc4","HGT","HGT")

	# Merge daily data with long daily data and save file to "slic_day_dir"
	"""
	Stop this procedure to save disk usage since data in multiple time steps can be read by "addfiles" in NCL
	20180413

	merg2_long_day_data( slic_day_dir+"fnl025_u_201601_latest_daily.nc",\
			slic_day_dir+"fnl025_u_"+crtyyyymmdd+".nc" ) # u
	merg2_long_day_data( slic_day_dir+"fnl025_v_201601_latest_daily.nc",\
			slic_day_dir+"fnl025_v_"+crtyyyymmdd+".nc" ) # v
	merg2_long_day_data( slic_day_dir+"fnl025_pw_201601_latest_daily.nc",\
			slic_day_dir+"fnl025_pw_"+crtyyyymmdd+".nc" ) # v

	if int(crtd)%2 == 0: # on even day, create relative time coordinate version for grads
		print "YES"
		to_rel_time( slic_day_dir+"fnl025_u_201601_latest_daily.nc",\
				slic_day_dir+"fnl025_u_201601_latest_daily_grads.nc") # u
		to_rel_time( slic_day_dir+"fnl025_v_201601_latest_daily.nc",\
				slic_day_dir+"fnl025_v_201601_latest_daily_grads.nc") # v
	"""

else:
	print "t= "+crtH+" Wait untill 18Z to create daily data."

print "**** Leave 'merge_sliced.py' at "+str(crt)+" => End merging sliced files ****"


