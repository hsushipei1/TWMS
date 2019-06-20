import os
os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command

# daily weather map: filtered waves overlaid on olr anomaly
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/on_OLRanoamly_7d/plot_mjo_olr_onOLRanomaly_7d.ncl")
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/on_OLRanoamly_7d/plot_kelvin_olr_onOLRanomaly_7d.ncl")
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/on_OLRanoamly_7d/plot_er_olr_onOLRanomaly_7d.ncl")
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/on_OLRanoamly_7d/plot_mrgtd_olr_onOLRanomaly_7d.ncl")

# daily weather map: all waves overlaid on olr anomaly
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/wave_constr_olrAnomaly_7d/plot_wave_constr_olrAnomaly_7d.ncl")

# daily weather map: waves' contribution to olr anomaly
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/all_wave_on_olrAnomaly_7d/plot_all_wave_on_olrAnomaly_7d.ncl")


