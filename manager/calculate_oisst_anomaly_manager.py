import os
os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command

# OISST anomaly
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/calculate_anomaly/sst/calculate_sst_anomalyWH04.ncl")

