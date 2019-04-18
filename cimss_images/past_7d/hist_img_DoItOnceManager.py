import datetime, os, shutil, sys

"""
Command line arguments are needed
python file.py STARTD ENDD HR CH RG
* HR is separated with comma

e.g. python file.py 20170701 20170725 00,06,12,18 NHC IOPO
STARTD: start date
ENDD: end date
HR: hours, separate with comma (00,06,12,18)
CH: channel (NHC, WV)
RG: region (EH, IOPO)
"""

channel = sys.argv[4] # "NHC" 
region = sys.argv[5] #"EH"  
case = channel+"_"+region
cwd = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/past_7d/"
os.chdir(cwd)

startd = datetime.datetime( int(sys.argv[1][0:4]) , int(sys.argv[1][4:6]) , int(sys.argv[1][6:8]) )
endd = datetime.datetime( int(sys.argv[2][0:4]) , int(sys.argv[2][4:6]) , int(sys.argv[2][6:8]) )
#startd = datetime.datetime(2017,7,28)
startd_str = startd.strftime('%Y%m%d')
#endd = datetime.datetime(2017,8,4)
endd_str = endd.strftime('%Y%m%d')
deltad = datetime.timedelta(days=+1) 
subt = (sys.argv[3]).split(",") # ["00", "06","12","18"] # (sys.argv[3]).split(",")
subt_str = ",".join(subt)

# download satellite image of each region
os.system("python ./download_indv_img_"+channel+".py "+startd_str+" "+endd_str+" "+subt_str)

# Overlay (combine) satellite images
os.system("python ./hist_overlay_"+region+".py "+startd_str+" "+endd_str+" "+subt_str+" "+channel)

# Crop overlaid satellite images to domain of interest (EH or IOPO)
os.system("python ./hist_crop_"+region+".py "+startd_str+" "+endd_str+" "+subt_str+" "+channel)

print "Done "+case+" for "+startd_str+" to "+endd_str+" "+subt_str+"UTC all in one! Thank you!"
