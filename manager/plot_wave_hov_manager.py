import os
os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command

## Hov: obs + gfs
# -5 to 5
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/wkfiltered_waves/olr_onOLRanomaly_fcst/plot_hov_wkfilter_OLR_onOLRanomaly_gfs_-5_5.ncl")

# 5 to 15
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/wkfiltered_waves/olr_onOLRanomaly_fcst/plot_hov_wkfilter_OLR_onOLRanomaly_gfs_5_15.ncl")


