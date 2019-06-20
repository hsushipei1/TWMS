import os

# WK filtering
os.system("python /data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/wk_filtering_manager.py")

## plot hovmoller for wk filtering
# OLR
os.system("python /data5/hsushipei/tropical_weather_monitoring_system/hovmoller/plot_hov_wkfiltered_waves_manager.py")

## plot weather maps for filtered waves (wave overlaid on olr anomaly,...,etc )
os.system("python /data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/plot_weamap_wkfiltered_waves_manager.py")

