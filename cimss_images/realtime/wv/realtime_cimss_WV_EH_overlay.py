import os, urllib, shutil
os.chdir("/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/")

try:
	os.makedirs("processing_rt_cimss")
except:
	pass

print "Downloading and processing..."
# Download images (modify the website to download dfferent product)
urllib.urlretrieve("http://tropic.ssec.wisc.edu/real-time/indian/images/wvm5.GIF", "./processing_rt_cimss/io_wv_eh.GIF")
urllib.urlretrieve("http://tropic.ssec.wisc.edu/real-time/westpac/images/wvgms.GIF", "./processing_rt_cimss/wnp_wv_eh.GIF")
urllib.urlretrieve("http://tropic.ssec.wisc.edu/real-time/austwest/images/wvgms.GIF", "./processing_rt_cimss/wau_wv_eh.GIF")

# Crop images
os.system("convert ./processing_rt_cimss/io_wv_eh.GIF -crop 1080x666+0+0 ./processing_rt_cimss/io2_wv_eh.GIF")
os.system("convert ./processing_rt_cimss/wau_wv_eh.GIF -crop 868x680+260+0 ./processing_rt_cimss/wau2_wv_eh.GIF")
os.system("convert ./processing_rt_cimss/wnp_wv_eh.GIF -crop 1080x644+0+0 ./processing_rt_cimss/wnp2_wv_eh.GIF")

# Overlay images
os.system("convert -size 1965x1242 xc:black ./processing_rt_cimss/bk_wv_eh.png")
os.system("convert -composite -geometry +0+277.1 ./processing_rt_cimss/bk_wv_eh.png ./processing_rt_cimss/io2_wv_eh.GIF ./processing_rt_cimss/out_wv_eh.png")
os.system("convert -composite -geometry +872+555.1 ./processing_rt_cimss/out_wv_eh.png ./processing_rt_cimss/wau2_wv_eh.GIF ./processing_rt_cimss/out2_wv_eh.png")
os.system("convert -composite -geometry +889+0 ./processing_rt_cimss/out2_wv_eh.png ./processing_rt_cimss/wnp2_wv_eh.GIF ./overlaid_cimss_WV_EH_latest.png")

# Delete intermediate files
shutil.rmtree("./processing_rt_cimss")
print "Done overlaying, Thank you!"
