#!/home/hsushipei/miniconda2/bin/python
import os, datetime, glob, sys, pickle

"""
Delete intermediate data. 

Arguments:
	1. Variable e.g. u
	2. Days before e.g. 30 (file before this will be removed)
"""

data_dir = "/data5/hsushipei/data/fnl/sliced/latest/6hr/"
fname_pref = "fnl025" # file name prefix
var = sys.argv[1]  # "u", "v", "pw",...
fname_suf = ".nc4" # file name suffix

fcrt = open("/data5/hsushipei/tropical_weather_monitoring_system/download_data/sliced_fnl/current_time","rb")
crt = pickle.load(fcrt) # latest time of sliced data

del_day = int( sys.argv[2] )
t_remain = crt + datetime.timedelta(days=-del_day ) # file before this will be deleted

for eachf in sorted( glob.glob(data_dir+"fnl025_"+var+"_*") ):
	basenamee = os.path.basename(eachf)
	datee = datetime.datetime.strptime( ( ( basenamee.split("_") )[2] ).split(".")[0], "%Y%m%d%H" ) # Y M D H
	if datee <= t_remain: # Remove files one month before the latest one
		rm_file = data_dir+fname_pref+"_"+var+"_"+datee.strftime("%Y%m%d%H")+fname_suf
		#print rm_file
		os.remove(rm_file)
		print "Cache "+rm_file+" removed!"

