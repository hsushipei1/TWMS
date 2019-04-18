import os, urllib, shutil
os.chdir("/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/")

try:
	os.makedirs("processing_rt_cimss")
except:
	pass

print "Downloading and processing..."
# Download images (modify the website to download dfferent product)
urllib.urlretrieve("http://tropic.ssec.wisc.edu/real-time/indian/images/wvm5.GIF", "./processing_rt_cimss/io_wv_iopo.GIF")
urllib.urlretrieve("http://tropic.ssec.wisc.edu/real-time/westpac/images/wvgms.GIF", "./processing_rt_cimss/wnp_wv_iopo.GIF")
urllib.urlretrieve("http://tropic.ssec.wisc.edu/real-time/austwest/images/wvgms.GIF", "./processing_rt_cimss/wau_wv_iopo.GIF")
urllib.urlretrieve("http://tropic.ssec.wisc.edu/real-time/austeast/images/wvgms.GIF", "./processing_rt_cimss/eau_wv_iopo.GIF")
urllib.urlretrieve("http://tropic.ssec.wisc.edu/real-time/seastpac/images/wvg10s.GIF", "./processing_rt_cimss/sep_wv_iopo.GIF")
urllib.urlretrieve("http://tropic.ssec.wisc.edu/real-time/eastpac/images/wvg9.GIF", "./processing_rt_cimss/enp_wv_iopo.GIF")

# Crop images
os.system("convert ./processing_rt_cimss/io_wv_iopo.GIF -crop 1080x666+0+0 ./processing_rt_cimss/io2_wv_iopo.GIF")
os.system("convert ./processing_rt_cimss/wau_wv_iopo.GIF -crop 868x680+260+0 ./processing_rt_cimss/wau2_wv_iopo.GIF")
os.system("convert ./processing_rt_cimss/wnp_wv_iopo.GIF -crop 1080x644+0+0 ./processing_rt_cimss/wnp2_wv_iopo.GIF")
os.system("convert ./processing_rt_cimss/eau_wv_iopo.GIF -crop 1080x668+0+0 ./processing_rt_cimss/eau2_wv_iopo.GIF")
os.system("convert ./processing_rt_cimss/sep_wv_iopo.GIF -crop 1080x680+0+36 ./processing_rt_cimss/sep2_wv_iopo.GIF")
os.system("convert ./processing_rt_cimss/enp_wv_iopo.GIF -crop 1128x668+0+0 ./processing_rt_cimss/enp2_wv_iopo.GIF")

# Overlay images
os.system("convert -size 3017x1300 xc:black ./processing_rt_cimss/bk_wv_iopo.png")
os.system("convert -composite -geometry +0+334.1 ./processing_rt_cimss/bk_wv_iopo.png ./processing_rt_cimss/io2_wv_iopo.GIF ./processing_rt_cimss/out_wv_iopo.png")
os.system("convert -composite -geometry +872+612.1 ./processing_rt_cimss/out_wv_iopo.png ./processing_rt_cimss/wau2_wv_iopo.GIF ./processing_rt_cimss/out2_wv_iopo.png")
os.system("convert -composite -geometry +889+57 ./processing_rt_cimss/out2_wv_iopo.png ./processing_rt_cimss/wnp2_wv_iopo.GIF ./processing_rt_cimss/out3_wv_iopo.png")
os.system("convert -composite -geometry +1111+612 ./processing_rt_cimss/out3_wv_iopo.png ./processing_rt_cimss/eau2_wv_iopo.GIF ./processing_rt_cimss/out4_wv_iopo.png")
os.system("convert -composite -geometry +1556+647 ./processing_rt_cimss/out4_wv_iopo.png ./processing_rt_cimss/sep2_wv_iopo.GIF ./processing_rt_cimss/out5_wv_iopo.png")
os.system("convert -composite -geometry +1889+0 ./processing_rt_cimss/out5_wv_iopo.png ./processing_rt_cimss/enp2_wv_iopo.GIF ./overlaid_cimss_WV_IOPO_latest.png")

# Delete intermediate files
shutil.rmtree("./processing_rt_cimss")
print "Done overlaying, Thank you!"
