import os, urllib, shutil
os.chdir("/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/")

try:
	os.makedirs("processing_rt_cimss")
except:
	pass

print "Downloading and processing..."
# Download images (modify the website to download dfferent product)
urllib.urlretrieve("http://tropic.ssec.wisc.edu/real-time/indian/images/irnm5.GIF", "./processing_rt_cimss/io.GIF")
urllib.urlretrieve("http://tropic.ssec.wisc.edu/real-time/westpac/images/irngms.GIF", "./processing_rt_cimss/wnp.GIF")
urllib.urlretrieve("http://tropic.ssec.wisc.edu/real-time/austwest/images/irngms.GIF", "./processing_rt_cimss/wau.GIF")

# Crop images
os.system("convert ./processing_rt_cimss/io.GIF -crop 1080x666+0+0 ./processing_rt_cimss/io2.GIF")
os.system("convert ./processing_rt_cimss/wau.GIF -crop 868x680+260+0 ./processing_rt_cimss/wau2.GIF")
os.system("convert ./processing_rt_cimss/wnp.GIF -crop 1080x644+0+0 ./processing_rt_cimss/wnp2.GIF")

# Overlay images
os.system("convert -size 1965x1242 xc:black ./processing_rt_cimss/bk.png")
os.system("convert -composite -geometry +0+277.1 ./processing_rt_cimss/bk.png ./processing_rt_cimss/io2.GIF ./processing_rt_cimss/out.png")
os.system("convert -composite -geometry +872+555.1 ./processing_rt_cimss/out.png ./processing_rt_cimss/wau2.GIF ./processing_rt_cimss/out2.png")
os.system("convert -composite -geometry +889+0 ./processing_rt_cimss/out2.png ./processing_rt_cimss/wnp2.GIF ./overlaid_cimss_NHC_EH_latest.png")

# Delete intermediate files
shutil.rmtree("./processing_rt_cimss")
print "Done overlaying, Thank you!"
