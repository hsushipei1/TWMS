import datetime, os, sys, glob
"""
Load multiple historical cropped satellite images to create animation.

Usage:
	$ python hist_img_anim_creater.py START_DATE END_DATE HR_LIST CHANNEL REGION

* START_DATE: e.g. 20170801
* END_DATE: e.g. 20170805
* HR_LIST: e.g. 00,06,12,18
* CHANNEL: NHC or WV.
* REGION: EH or IOPO

Output: Create satellite image animation from images starting on START_DATE and ending on END_DATE among HR_LIST in CHANNEL 
	observation over REGION.

"""

# Welcome message
welc_msg = \
"""
================================================================================

Manager for creating animation from (historical) satellite images from CIMSS

* File: "hist_img_anim_creater.py"

"""
print welc_msg

# Necessary parameters and paths
channel = sys.argv[4] # "NHC" 
region = sys.argv[5] #"EH"  
case = channel+"_"+region
cwd = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/past_7d/"
os.chdir(cwd)
imgs_dir = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/past_7d/"+channel+"/cropped" 
						# images that will be used to create animation
anim_dir = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/animation/"+channel+"/"+region

# Dealing with dates
startd = datetime.datetime( int(sys.argv[1][0:4]) , int(sys.argv[1][4:6]) , int(sys.argv[1][6:8]) )
endd = datetime.datetime( int(sys.argv[2][0:4]) , int(sys.argv[2][4:6]) , int(sys.argv[2][6:8]) )
#startd = datetime.datetime(2017,7,28)
startd_str = startd.strftime('%Y%m%d')
#endd = datetime.datetime(2017,8,4)
endd_str = endd.strftime('%Y%m%d')
hh_li = (sys.argv[3]).split(",") # list: ["00", "06","12","18"] 
hh_str = ",".join(hh_li) # hr string
hh_str2 = "_".join(hh_li) # hr string 2

dday = (endd-startd).total_seconds()/86400. # "day" difference between start and end
full_fil_li = [] # list to store full file names of files that will be chosen to create animation

# Generate list of files to create animation
dd=0
while dd <= dday: # iterate day in outer loop and iterate hr in inner loop
	for hr in hh_li:
		startd_hh = datetime.datetime( int( startd.strftime('%Y') ),\
				int( startd.strftime('%m') ),\
				int( startd.strftime('%d') ), int(hr) ) # dates that will be chosen to create animation
		full_fil_name = "overlaid_"+channel+"_"+region+"_"+startd_hh.strftime('%Y%m%d.%H')+"_cropped.png"
											# full file name 
		full_fil_li.append(full_fil_name) # append each file name to list
	startd = startd+datetime.timedelta(days=+1)
	dd=dd+1

# Create animation
print "* Creating "+case+" animation from "+startd_str+" to "+endd_str+" every "+hh_str
os.chdir(imgs_dir)
fil_li2arg = " ".join(full_fil_li)
#os.system("convert -delay 50 -loop 0 -crop 1555x555+317+280 "+fil_li2arg+" "+anim_dir+"/ani.gif")
os.system("convert -delay 50 -loop 0 "+fil_li2arg+" "+anim_dir+"/cimss_ani_"+case+"_"+startd_str+"_"+endd_str+"_"+hh_str2+".gif")

# Leaving
quit_msg = \
"""

Leaving "hist_img_anim_creater.py". Thank you!

================================================================================
"""
print quit_msg
