import os
os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command

# OLR and U925 anomaly
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/anomaly_olr_u925/plot_hov_anomaly_olr_u925_-5_5.ncl")
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/anomaly_olr_u925/plot_hov_anomaly_olr_u925_5_15.ncl")

