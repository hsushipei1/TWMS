import os, datetime, sys
"""
Add time coordinate to GPM_daily_accRain

$ python add_time_coordinate.py yyyymmdd

yyyymmdd: date to add to date
"""

data_shortn = "GPM_daily_accRain"
ori_data_name_pf = "3B-DAY-E.MS.MRG.3IMERG." # prefix of data name, separated by date
ori_data_name_sf = "-S000000-E235959.V04.nc4" # suffix of data name, separated by date
new_data_name_pf = "GPM_IMERG_accRain_" # prefix of data name, separated by date
new_data_name_sf = "_daily.nc4" # suffix of data name, separated by date
downloader_dir = "/data5/hsushipei/tropical_weather_monitoring_system/download_data/dl_GPM_daily_accRain"
data_dir = "/data5/hsushipei/data/total_field/Precip/GPM/realtime"
CDO = "/home/hsushipei/software/bin/cdo"

latestt = datetime.datetime.strptime( (sys.argv[1]), "%Y%m%d" ) 
latestt_str = latestt.strftime('%Y%m%d')
latestt_str2 = latestt.strftime('%Y-%m-%d')

# Add time coordinate to data
print "* Adding time coordinate to "+new_data_name_pf+latestt_str+new_data_name_sf
os.system(CDO+" setdate,"+latestt_str2+"T00:00:00 "+data_dir+"/"+ori_data_name_pf+latestt_str+ori_data_name_sf+" "+data_dir+"/"+new_data_name_pf+latestt_str+new_data_name_sf)
