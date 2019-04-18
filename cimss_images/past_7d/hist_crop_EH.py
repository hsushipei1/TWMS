import datetime, os, shutil, sys

"""
Command line arguments are needed
python file.py STARTD ENDD HR CH
* HR is separated with comma

e.g. python file.py 20170701 20170725 00,06,12,18 NHC
STARTD: start date
ENDD: end date
HR: hours
CH: channel (NHC, WV)
"""

# Date parameters
#startd = datetime.datetime(2017,7,1)
#endd = datetime.datetime(2017,7,27)
startd = datetime.datetime( int(sys.argv[1][0:4]) , int(sys.argv[1][4:6]) , int(sys.argv[1][6:8]) )
endd = datetime.datetime( int(sys.argv[2][0:4]) , int(sys.argv[2][4:6]) , int(sys.argv[2][6:8]) ) 
deltad = datetime.timedelta(days=+1) 
subt =  (sys.argv[3]).split(",") # ["06", "18"] # 00Z 12Z

# Channel and region parameters
channel = sys.argv[4] # "NHC", "WV"
region = "EH" # fixed
case = channel+"_"+region
savto = "cropped"
cwd = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/past_7d/"+channel+"/"
#os.chdir(os.getcwd())
os.chdir(cwd)

try:
	os.makedirs(savto)
except:
	pass
        
while startd <= endd:
	strd_str = startd.strftime('%Y%m%d')
	for hh in subt:
		print "Cropping "+case+" on "+strd_str+" "+hh+"..."
		# Cropping images to EH
		os.system("convert -crop 1556x558+316+280 ./overlaid/overlaid_"+case+"_"+strd_str+"."+hh+".png \
						./"+savto+"/overlaid_"+case+"_"+strd_str+"."+hh+"_cropped.png")
		if os.path.exists("./"+savto+"/overlaid_"+case+"_"+strd_str+"."+hh+"_cropped.png"):
							# If cropped satellite images exists, add a title for it, or quit.
			# Add a title of time for each satellite images
			os.system("convert -size 1556x40 xc:black \
					-gravity center -font Times-Bold -pointsize 40 -fill white \
					-annotate 0 '"+channel+"(IR) over "+region+" on "+strd_str+" "+hh+"UTC from UW-CIMSS' \
					./"+savto+"/overlaid_"+case+"_"+strd_str+"."+hh+"_cropped.png -append \
					./"+savto+"/overlaid_"+case+"_"+strd_str+"."+hh+"_cropped.png")
					# Create a black background.-> Add text (-annotate) on the background and specify text attribute.-> vertically append the background and satellite image.

	startd = startd + deltad

print "Done cropping "+case+"! "
