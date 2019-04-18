import os
os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command

## Daily weather map
# SST & 925 wind 
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/interannual_scale/interannual_sst_925wind/plot_interannual_sst_925wind_lastMonth.ncl")
# OLR
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/interannual_scale/interannual_olr/plot_interannual_olr_lastMonth.ncl")

## Hovmoller
# SSTA
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/oisst_anomaly_eq_1y/plot_oisst_anomaly_eqt_1y.ncl")
# OLRA & U925A
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/olr_u925_anomaly_eq_1y/plot_olr_u925_anomaly_eqt_1y.ncl")


