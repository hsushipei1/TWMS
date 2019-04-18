import datetime, os, shutil, sys

"""
2 command line arguments are needed
python file.py STARTD ENDD HR CH 
* HR is separated with comma

e.g. python file.py 20170701 20170725 00,06,12,18
STARTD: start date
ENDD: end date
HR: hours
CH: channel (NHC, WV)
"""

# Date parameters
#startd = datetime.datetime(2017,5,28)
#endd = datetime.datetime(2017,6,2)
startd = datetime.datetime( int(sys.argv[1][0:4]) , int(sys.argv[1][4:6]) , int(sys.argv[1][6:8]) )
endd = datetime.datetime( int(sys.argv[2][0:4]) , int(sys.argv[2][4:6]) , int(sys.argv[2][6:8]) )
deltad = datetime.timedelta(days=+1) 
subt =  (sys.argv[3]).split(",")  # ["06", "18"] # 00Z 12Z

# Channel and region parameters
channel = sys.argv[4] # "NHC", "WV"
region = "IOPO" # fixed
case = channel+"_"+region
indv_img_dir = channel+"_indv_img"
proc_dir = case+"_processing"
cwd = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/past_7d/"+channel+"/"
os.chdir(cwd)

if channel == "NHC":
	CH_weblink = "IRImageNHCEnhancement" # some portion of website link of channel
elif channel == "WV":
	CH_weblink= "WVImage"

try:
	os.makedirs(proc_dir)
	os.makedirs("overlaid")
except:
	pass

while startd <= endd:
	strd_str = startd.strftime('%Y%m%d')
	for hh in subt:
		print "Overlaying "+case+" on "+strd_str+" "+hh+"..."
		# Cropping original image
		os.system("convert ./"+indv_img_dir+"/"+strd_str+"."+hh+".Indian."+CH_weblink+".png \
					-crop 1080x666+0+0 \
					./"+proc_dir+"/cropped_io_"+strd_str+"."+hh+".GIF")
		os.system("convert ./"+indv_img_dir+"/"+strd_str+"."+hh+".Australia."+CH_weblink+"West.png \
					-crop 868x680+260+0 \
					./"+proc_dir+"/cropped_wau_"+strd_str+"."+hh+".GIF")
		os.system("convert ./"+indv_img_dir+"/"+strd_str+"."+hh+".NWPacific."+CH_weblink+".png \
					-crop 1080x644+0+0 \
					./"+proc_dir+"/cropped_wnp_"+strd_str+"."+hh+".GIF")
		os.system("convert ./"+indv_img_dir+"/"+strd_str+"."+hh+".Australia."+CH_weblink+"East.png \
					-crop 1080x668+0+0 \
					./"+proc_dir+"/cropped_eau_"+strd_str+"."+hh+".GIF")
		os.system("convert ./"+indv_img_dir+"/"+strd_str+"."+hh+".SEPacific."+CH_weblink+".png \
					-crop 1080x680+0+36 \
					./"+proc_dir+"/cropped_sep_"+strd_str+"."+hh+".GIF")
		os.system("convert ./"+indv_img_dir+"/"+strd_str+"."+hh+".NEPacific."+CH_weblink+".png \
					-crop 1128x668+0+0 \
					./"+proc_dir+"/cropped_enp_"+strd_str+"."+hh+".GIF")

		# Overlaying
		os.system("convert -size 3017x1300 xc:black ./"+proc_dir+"/bk_"+strd_str+"."+hh+".png")
		os.system("convert -composite -geometry +0+334.1 ./"+proc_dir+"/bk_"+strd_str+"."+hh+".png \
					./"+proc_dir+"/cropped_io_"+strd_str+"."+hh+".GIF ./"+proc_dir+"/out1_"+strd_str+"."+hh+".png")
		os.system("convert -composite -geometry +872+612.1 ./"+proc_dir+"/out1_"+strd_str+"."+hh+".png \
					./"+proc_dir+"/cropped_wau_"+strd_str+"."+hh+".GIF ./"+proc_dir+"/out2_"+strd_str+"."+hh+".png")
		os.system("convert -composite -geometry +889+57 ./"+proc_dir+"/out2_"+strd_str+"."+hh+".png \
					./"+proc_dir+"/cropped_wnp_"+strd_str+"."+hh+".GIF ./"+proc_dir+"/out3_"+strd_str+"."+hh+".png")
		os.system("convert -composite -geometry +1111+612 ./"+proc_dir+"/out3_"+strd_str+"."+hh+".png \
					./"+proc_dir+"/cropped_eau_"+strd_str+"."+hh+".GIF ./"+proc_dir+"/out4_"+strd_str+"."+hh+".png")
		os.system("convert -composite -geometry +1556+647 ./"+proc_dir+"/out4_"+strd_str+"."+hh+".png \
					./"+proc_dir+"/cropped_sep_"+strd_str+"."+hh+".GIF ./"+proc_dir+"/out5_"+strd_str+"."+hh+".png")
		os.system("convert -composite -geometry +1889+0 ./"+proc_dir+"/out5_"+strd_str+"."+hh+".png \
					./"+proc_dir+"/cropped_enp_"+strd_str+"."+hh+".GIF ./overlaid/overlaid_"+case+"_"+strd_str+"."+hh+".png")

	startd = startd + deltad

# Delete intermediate files
shutil.rmtree(proc_dir)

print "Done overlaying "+case+" images! Thank you!"
