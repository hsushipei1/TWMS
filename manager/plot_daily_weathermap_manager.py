import os
os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command

# total OLR and 925 wind 
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/olr_wind_hist/plot_olr_925wind_hist.ncl")
# OLR and 925 wind anomaly 
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/olr_wind_anomaly_hist/plot_olr_925wind_anomaly_hist.ncl")
# OISST 
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/sst_hist/plot_sst_hist.ncl")
# OISST anomaly 
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/sst_anoamly_hist/plot_sst_anom_hist.ncl")
# IMERG precip 
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/precip_hist/plot_precip_hist.ncl")
# TPW & 925 wind
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/pw_wind_hist/plot_pw_925wind_hist.ncl")
# Weekly 200 wind
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/windspd_wind_200_hist/plot_200wsp_wind_hist.ncl")
# Weekly 500 hgt
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/hgt_500_hist/plot_500hgt_hist.ncl")
# Weekly 850 streamline
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/windspd_wind_850_hist/plot_850wsp_wind_hist.ncl")

