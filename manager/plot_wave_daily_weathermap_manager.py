import os
os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command

# Filtered wave OLR on OLR anomaly: obs/ GFS fcst
# MJO OLR
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/on_OLRanoamly_gfs/plot_mjo_olr_onOLRanomaly_gfs.ncl")

# MJO VP200
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/on_OLRanoamly_gfs/plot_mjo_vp200_onOLRanomaly_gfs.ncl")

# Kelvin
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/on_OLRanoamly_gfs/plot_kelvin_olr_onOLRanomaly_gfs.ncl")

# ER
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/on_OLRanoamly_gfs/plot_er_olr_onOLRanomaly_gfs.ncl")

# MRG/TD
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/on_OLRanoamly_gfs/plot_mrgtd_olr_onOLRanomaly_gfs.ncl")


