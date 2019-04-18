#!/home/hsushipei/miniconda2/bin/python
"""
Manager for the 2nd version of FNL data downloader
"""
import pickle, os, datetime, glob

data_shortn = "GPM_daily_accRain"
ori_data_name_pf = "3B-DAY-E.MS.MRG.3IMERG." # prefix of data name, separated by date
ori_data_name_sf = "-S000000-E235959.V05.nc4" # suffix of data name, separated by date
new_data_name_pf = "GPM_IMERG_accRain_" # prefix of data name, separated by date
new_data_name_sf = "_daily.nc4" # suffix of data name, separated by date
downloader_dir = "/data5/hsushipei/tropical_weather_monitoring_system/download_data/dl_GPM_daily_accRain"
data_dir = "/data5/hsushipei/data/total_field/Precip/GPM/realtime"
next_t_step_f = "/data5/hsushipei/tropical_weather_monitoring_system/download_data/dl_GPM_daily_accRain/GPM_daily_accRain_next_t_step"

fnextt = open( next_t_step_f, "r" )
latestt = ( pickle.load(fnextt) )+datetime.timedelta(days=-1) # time of the latest data (on offcial website)
#latestf_n = os.path.basename( ( sorted( glob.glob(data_dir+"/"+new_data_name_pf+"*"+new_data_name_sf) ) )[-1] ) 
# name of latest data ON DISK
len_new_data_name_pf = len(new_data_name_pf)
len_new_data_name_sf =  len(new_data_name_sf)
#latestft = datetime.datetime.strptime( latestf_n[ len_new_data_name_pf : (len_new_data_name_pf+8+len_new_data_name_sf)-len_new_data_name_sf ], "%Y%m%d" )  # time of latest data ON DISK

## Download data
os.system("/home/hsushipei/miniconda2/bin/python "+downloader_dir+"/GPM_daily_accRain_downloader.py")

#dt = (latestt-latestft).total_seconds()/86400. # lagged days between the latest availbale data online and latest data on DISK.

## Add time coordinate to file
"""
dd=1
while dd <= dt:
	latestft = latestft+datetime.timedelta(days=+1)
	latestft_str = latestft.strftime("%Y%m%d")

	## Special treatment
	# Add time coordinate to data per download
	os.system("/home/hsushipei/miniconda2/bin/python "+downloader_dir+"/add_time_coordinate.py "+latestft_str)

	# delete original data
	os.remove(data_dir+"/"+ori_data_name_pf+latestft_str+ori_data_name_sf)

	# merge single file to long-term daily data


	dd=dd+1
"""



