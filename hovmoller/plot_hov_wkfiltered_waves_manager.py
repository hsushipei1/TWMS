import os
os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command

# hovmoller: filtered OLR overlaid on total OLR
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/wkfiltered_waves/olr/plot_hov_wkfilter_-5_5.ncl")
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/wkfiltered_waves/olr/plot_hov_wkfilter_5_15.ncl")

# hovmoller: filtered OLR overlaid on OLR anomaly with prediction by real-time filtering (Wheeler and Weickmann 2001)
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/wkfiltered_waves/olr_onOLRanomaly_fcst/plot_hov_wkfilter_OLR_onOLRanomaly_fcst_-5_5.ncl")
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/wkfiltered_waves/olr_onOLRanomaly_fcst/plot_hov_wkfilter_OLR_onOLRanomaly_fcst_5_15.ncl")

# hovmoller: forecast verification: ori V.S fcst by filtering
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/wkfiltered_waves/fcst_verif/filterFcst_obs/plot_hov_filterFcst_obs_fcstVerif_-5_5.ncl")
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/wkfiltered_waves/fcst_verif/filterFcst_obs/plot_hov_filterFcst_obs_fcstVerif_5_15.ncl")

