import os, urllib, shutil, datetime, sys

"""
2 command line arguments are needed
python file.py STARTD ENDD HR 
* HR is separated with comma

e.g. python file.py 20170701 20170725 00,06,12,18
STARTD: start date
ENDD: end date
HR: hours
"""

channel = "WV"
indv_img_dir = channel+"_indv_img"
cwd = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/past_7d/"+channel+"/"
os.chdir(cwd)

try:
    os.makedirs(indv_img_dir)
except:
    pass

#startd = datetime.datetime(2017,5,28)
#endd = datetime.datetime(2017,6,2)
startd = datetime.datetime( int(sys.argv[1][0:4]) , int(sys.argv[1][4:6]) , int(sys.argv[1][6:8]) )
endd = datetime.datetime( int(sys.argv[2][0:4]) , int(sys.argv[2][4:6]) , int(sys.argv[2][6:8]) )
deltad = datetime.timedelta(days=+1)
subt = (sys.argv[3]).split(",")  # ["06", "18"] # 06Z 18Z

while startd <= endd:
	startd_str = startd.strftime('%Y%m%d')
	for hh in subt:
		print "Downloading "+channel+" at "+startd_str+" "+hh+"..."
		# IO
		url = "http://tropic.ssec.wisc.edu/archive/data/Indian/"+startd_str+"/WVImage/"+startd_str+"."+hh+".Indian.WVImage.png"
		os.system("curl -s -f "+url+" -o ./"+indv_img_dir+"/"+startd_str+"."+hh+".Indian.WVImage.png")

		# wnp
		url = "http://tropic.ssec.wisc.edu/archive/data/NWPacific/"+startd_str+"/WVImage/"+startd_str+"."+hh+".NWPacific.WVImage.png"
		os.system("curl -s -f "+url+" -o ./"+indv_img_dir+"/"+startd_str+"."+hh+".NWPacific.WVImage.png")

		# wau
		url = "http://tropic.ssec.wisc.edu/archive/data/Australia/"+startd_str+"/WVImageWest/"+startd_str+"."+hh+".Australia.WVImageWest.png"
		os.system("curl -s -f "+url+" -o ./"+indv_img_dir+"/"+startd_str+"."+hh+".Australia.WVImageWest.png")

		# eau
		url = "http://tropic.ssec.wisc.edu/archive/data/Australia/"+startd_str+"/WVImageEast/"+startd_str+"."+hh+".Australia.WVImageEast.png"
		os.system("curl -s -f "+url+" -o ./"+indv_img_dir+"/"+startd_str+"."+hh+".Australia.WVImageEast.png")

		# enp
		url = "http://tropic.ssec.wisc.edu/archive/data/NEPacific/"+startd_str+"/WVImage/"+startd_str+"."+hh+".NEPacific.WVImage.png"
		os.system("curl -s -f "+url+" -o ./"+indv_img_dir+"/"+startd_str+"."+hh+".NEPacific.WVImage.png")

		# sep
		url = "http://tropic.ssec.wisc.edu/archive/data/SEPacific/"+startd_str+"/WVImage/"+startd_str+"."+hh+".SEPacific.WVImage.png"
		os.system("curl -s -f "+url+" -o ./"+indv_img_dir+"/"+startd_str+"."+hh+".SEPacific.WVImage.png")

	startd = startd + deltad

