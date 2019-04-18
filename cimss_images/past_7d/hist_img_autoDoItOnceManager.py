import datetime, os, glob, shutil
"""
Manager for automatically downloading (historical [or previous]) satellite images observed at 00, 06, 12, 18Z each day. Give parameters (period, channel, or region) to "DoItOnce Manager" for historical satellite images ("hist_img_DoItOnceManager.py"). 
"hist_img_DoItOnceManager.py" does download, overlay and crop images In Once.

*** This program is designed for scheduled downloading and processing small amount (time step) of historical satellite images.
    to download and process large amount of images, please use "hist_img_DoItOnceManager.py".

* Controlled by: This program is directly controlled by (in the next level to) "crontab".
* Launch: "hist_img_DoItOnceManager.py"

* Crontab configuration: Start downloading 1 hours after observation time (00 06 12 18Z), i.e., 03, 09, 15, 21LST.
"""

curt =  datetime.datetime.now() # current time
#curt =  datetime.datetime(2017,9,9,21) # fake current time (LST)
curt_str = curt.strftime("%Y%m%d%H%M") # 
dltU = curt + datetime.timedelta(hours=-1-8) ## download time in UTC (= curt-1hr-8hr [to UTC])

channel = ["NHC","WV"]
region =  ["EH","IOPO"]
#case = channel+"_"+region
hist_img_mang_dir = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/past_7d"
latest_img_dir = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/past_7d/latest"

welc_msg = \
"""
================================================================================

Manager for automatically downloading (historical) satellite images from CIMSS

* File: "hist_img_autoManager.py"

================================================================================
"""
print welc_msg

for ch in channel:
	for rg in region:
		prev_img_dir = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/past_7d/"+ch+"/cropped"
		os.chdir(prev_img_dir)
		prev_img_li = sorted( glob.glob("overlaid_"+ch+"_"+rg+"_*_cropped.png") ) # list of previous imgs
		latest_prev_img = prev_img_li[len(prev_img_li)-1]
		latest_prev_time = datetime.datetime.strptime( latest_prev_img.split("_")[3], "%Y%m%d.%H" ) 
										## time of latest previous img (datetime object)
		dhr = (dltU-latest_prev_time).total_seconds()/3600.0 # lagged hours
		print "* For case="+ch+"_"+rg+", current time= "+str(dltU) +", latest file= "+str(latest_prev_time)+" UTC"

		# check (*cropped.png) missing previous images
		if dhr >= 6:
			dtstep = dhr / 6. # lagged time step (per 6 hours)
			tt = 1
			while tt <= dtstep:
				latest_prev_time = latest_prev_time+datetime.timedelta(hours=+6)
				latest_prev_time_ymd_str = latest_prev_time.strftime("%Y%m%d") # download time: yyyymmdd
				latest_prev_time_h_str = latest_prev_time.strftime("%H") # download time: hh
				print "* Proccessing "+ch+" over "+rg+" on "+latest_prev_time.strftime("%Y%m%d.%H")+"Z"
				os.system("python "+hist_img_mang_dir+"/hist_img_DoItOnceManager.py "+\
						latest_prev_time_ymd_str+" "+latest_prev_time_ymd_str+" "+latest_prev_time_h_str+" "+\
						ch+" "+rg)

				tt=tt+1

		elif dhr < 6.0:
			print "* Historical images are up-to-dated."
			pass

		# Rename to include the word "latest" in file name of latest images
		latest_img_origname = "overlaid_"+ch+"_"+rg+"_"+dltU.strftime("%Y%m%d.%H")+"_cropped.png"
		rename_name = "overlaid_"+ch+"_"+rg+"_latest_cropped.png"
		shutil.copy(prev_img_dir+"/"+latest_img_origname, latest_img_dir+"/"+rename_name)
		try:
			shutil.copy(prev_img_dir+"/"+latest_img_origname, latest_img_dir+"/"+rename_name)
			print "* Rename "+latest_img_origname+" to "+rename_name+" and moved to the 'latest' directory. \n"
		except:
			print "* Error renaming "+latest_img_origname+"\n"

quit_msg = \
"""
Leaving "hist_img_autoManager.py". Thank you!

================================================================================
"""
print quit_msg


