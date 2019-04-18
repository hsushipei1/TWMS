import os
os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command

# U925 anomaly
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/calculate_anomaly/u925/calculate_u925_anomalyWH04.ncl")

# V925 anomaly
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/calculate_anomaly/v925/calculate_v925_anomalyWH04.ncl")

# pw anomaly
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/calculate_anomaly/pw/calculate_pw_anomalyWH04.ncl")
