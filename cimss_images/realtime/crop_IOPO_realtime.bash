
# plot realtime cimss nhc
#/home/hsushipei/miniconda2/bin/python /data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/realtime_cimss_NHC_IOPO_overlay.py 


# NHC
/usr/bin/convert -crop 2872x666+0+340 \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/overlaid_cimss_NHC_IOPO_latest.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/overlaid_cimss_NHC_IOPO_latest_temp.png

/usr/bin/convert -crop 2872x27+0+1273 \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/overlaid_cimss_NHC_IOPO_latest.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/date.png

/usr/bin/convert \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/overlaid_cimss_NHC_IOPO_latest_temp.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/date.png \
	-append \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/overlaid_cimss_NHC_IOPO_latest_cropped.png

rm /data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/overlaid_cimss_NHC_IOPO_latest_temp.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/nhc/date.png

# WV
/usr/bin/convert -crop 2872x666+0+340 \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/overlaid_cimss_WV_IOPO_latest.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/overlaid_cimss_WV_IOPO_latest_temp.png

/usr/bin/convert -crop 2872x27+0+1273 \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/overlaid_cimss_WV_IOPO_latest.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/date.png

/usr/bin/convert \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/overlaid_cimss_WV_IOPO_latest_temp.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/date.png \
	-append \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/overlaid_cimss_WV_IOPO_latest_cropped.png

rm /data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/overlaid_cimss_WV_IOPO_latest_temp.png \
	/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/realtime/wv/date.png
