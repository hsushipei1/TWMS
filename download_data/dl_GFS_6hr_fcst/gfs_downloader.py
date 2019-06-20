import datetime, os, pickle
import numpy as np
print "!!!!! start -> gfs_downloader.py  !!!!!"
gfs_data_dir = "/data5/hsushipei/data/gfs/ncep"
os.chdir(gfs_data_dir)

reso = "1p00" # space resolution of data
fct1 = 0 # beginning forecast time 
fct2 = 384 # end forecast time
fct_int = 6 # time interval of each data
fct_ary = np.arange(fct1, fct2+6, fct_int) # array collecting forecast time
weburl = "http://www.ftp.ncep.noaa.gov/data/nccf/com/gfs/prod/gfs."
tlag = 40 # hour. Download the forecast 00(analysis) at tlag hours before current time.

###### delete previous GFS data
#delt_utc = dlt_utc + datetime.timedelta(hours=-24) # data at this time will be deleted
#os.system("rm "+gfs_data_dir+"/"+"*"+delt_utc.strftime('%Y%m%d%H')+"*.grib2")
os.system("rm "+gfs_data_dir+"/"+"gfs.*")

# For automatically download
tnow = datetime.datetime.now() # download time LST
##tnow = datetime.datetime(2018,5,8,0) # FOR DEBUGGING 

"""
#For Manually Download (un-comment this block)
manut = "2019062000" # download time (LST) in yyyymmddhh. ## For testing
tnow = datetime.datetime.strptime(manut,'%Y%m%d%H')       ## For testing
"""
utcnow = tnow + datetime.timedelta(hours=-8) # download time in UTC

dlt_utc =  utcnow + datetime.timedelta(hours=-tlag)	# download the data in what time (UTC) 
dlt_yyyymmddhh = (dlt_utc.strftime('%Y%m%d'))+"/"+dlt_utc.strftime('%H') 
														# 2019/6/19: yyyymmdd/hh to match the changes over GFS website
dl_hh = dlt_utc.strftime('%H') # hr portion of download time

####### create a file storing current time of GFS data 
f = open(gfs_data_dir+"/"+"current_data_time.txt","wb")
pickle.dump(dlt_utc, f)
f.close()

####### download forecast
for eacht in fct_ary:
	fct2str = "%03d" %(eacht)
	
	fnsvr = "gfs.t"+dl_hh+"z.pgrb2."+reso+".f"+fct2str # file name in server
	furl = os.path.join(weburl+dlt_yyyymmddhh,fnsvr)  # file url
	os.system("wget "+furl)
	
	dlt_yyyymmddhh = dlt_utc.strftime('%Y%m%d%H') # 2019/6/19 Change back to yyyymmddhh
	fnout = "gfs."+dlt_yyyymmddhh+".pgrb2."+reso+".f"+fct2str+".grib2" # output file name
	try:
		os.rename(gfs_data_dir+"/"+fnsvr, gfs_data_dir+"/"+fnout)
	except:
		pass

# download analysis (forecast 00)
"""
anl_fnsvr = "gfs.t"+dl_hh+"z.pgrb2."+reso+".anl"
anl_furl = os.path.join(weburl+dlt_yyyymmddhh, anl_fnsvr)
anl_fnout = "gfs."+dlt_yyyymmddhh+".pgrb2."+reso+".anl.grib2"
anl_dlcmd = " ".join([wgetcmd, anl_furl, wgetopt, anl_fnout])
os.system(anl_dlcmd)
"""

print "!!!!! gfs_downloader.py -> end !!!!!"
