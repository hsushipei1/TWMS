
# plot realtime cimss nhc
#/home/hsushipei/miniconda2/bin/python /data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/realtime_cimss_NHC_EH_overlay.py 


# NHC
/usr/bin/convert -crop 1556x558+316+280 \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/overlaid_cimss_NHC_EH_latest.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/overlaid_cimss_NHC_EH_latest_temp.png

/usr/bin/convert -crop 1556x17+316+1223 \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/overlaid_cimss_NHC_EH_latest.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/date.png

/usr/bin/convert \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/overlaid_cimss_NHC_EH_latest_temp.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/date.png \
	-append \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/overlaid_cimss_NHC_EH_latest_cropped.png

rm /data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/overlaid_cimss_NHC_EH_latest_temp.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/date.png

# WV
/usr/bin/convert -crop 1556x558+316+280 \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/overlaid_cimss_WV_EH_latest.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/overlaid_cimss_WV_EH_latest_temp.png

/usr/bin/convert -crop 1556x17+316+1223 \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/overlaid_cimss_WV_EH_latest.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/date.png

/usr/bin/convert \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/overlaid_cimss_WV_EH_latest_temp.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/date.png \
	-append \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/overlaid_cimss_WV_EH_latest_cropped.png

rm /data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/overlaid_cimss_WV_EH_latest_temp.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/date.png
