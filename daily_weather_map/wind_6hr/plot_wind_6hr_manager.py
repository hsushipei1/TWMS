import pickle, os, datetime
os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command

f = open("/data5/hsushipei/tropical_weather_monitoring_system/download_data/sliced_fnl/current_time")
crt = pickle.load(f)
crt_str = crt.strftime("%Y%m%d%H")

# latest fnl 925, 500, 200 wind 
os.system("DATE="+crt_str+" "+NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wind_6hr/1000/plot_1000wind_6hr.ncl")
os.system("DATE="+crt_str+" "+NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wind_6hr/850/plot_850wind_6hr.ncl")
os.system("DATE="+crt_str+" "+NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wind_6hr/500/plot_500wind_6hr.ncl")
os.system("DATE="+crt_str+" "+NCL+"/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wind_6hr/200/plot_200wind_6hr.ncl")
