import os
"""
Download IR and VIS satellite images over East Asia from CWb Open Data and make a copy for TWMR
If the images are empty (size= 0 byte), dont make a copy.
"""
img_dir = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/cwbopendata_satelImg"
TWMR_fig_dir = "/data5/hsushipei/tropical_weather_monitoring_system/report/generator/figures"

## Download
# 1. IR
irlink = "http://opendata.cwb.gov.tw/opendata/MSC/O-B0032-004.jpg"
irf = "cwb_ir_ea_latest.jpg"
os.system("curl -s -f "+irlink+" -o "+img_dir+"/"+irf)

# 2. VIR
vislink = "http://opendata.cwb.gov.tw/opendata/MSC/O-B0032-001.jpg"
visf = "cwb_vis_ea_latest.jpg"
os.system("curl -s -f "+vislink+" -o "+img_dir+"/"+visf)

## Make a copy for TWMR (if the file is not empty)
f_li = [irf, visf]
for each_img in f_li:
	fsize = os.path.getsize(img_dir+"/"+each_img)
	if fsize != 0:
		print "* Copying "+each_img+" to TWMR."
		os.system("cp "+img_dir+"/"+each_img+" "+TWMR_fig_dir)

