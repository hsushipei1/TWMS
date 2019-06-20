import os

## Eastern hemisphere (EH)
# NHC 
print "Enter 'realtime_cimss_NHC_EH_overlay.py'..."
os.system("/home/hsushipei/miniconda2/bin/python \
		/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/realtime_cimss_NHC_EH_overlay.py")
print "Leave 'realtime_cimss_NHC_EH_overlay.py'..."
# WV
print "Enter 'realtime_cimss_WV_EH_overlay.py'..."
os.system("/home/hsushipei/miniconda2/bin/python \
		/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/realtime_cimss_WV_EH_overlay.py")
print "Leave 'realtime_cimss_NHC_EH_overlay.py'..."
print "Enter 'crop_EH_realtime.bash'..."
os.system("bash /data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/crop_EH_realtime.bash")
print "Leave 'crop_EH_realtime.bash'..."

## Indian Ocean-Pacific Ocean (IOPO)
# NHC
print "Enter 'realtime_cimss_NHC_IOPO_overlay.py'..."
os.system("/home/hsushipei/miniconda2/bin/python \
		/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/realtime_cimss_NHC_IOPO_overlay.py")
print "Leave 'realtime_cimss_NHC_IOPO_overlay.py'..."
# WV
print "Enter 'realtime_cimss_WV_IOPO_overlay.py'..."
os.system("/home/hsushipei/miniconda2/bin/python \
		/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/realtime_cimss_WV_IOPO_overlay.py")
print "Leave 'realtime_cimss_NHC_IOPO_overlay.py'..."
print "Enter 'crop_IOPO_realtime.bash'..."
os.system("bash /data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/crop_IOPO_realtime.bash")
print "Leave 'crop_IOPO_realtime.bash'..."

