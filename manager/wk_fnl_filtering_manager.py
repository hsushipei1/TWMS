import os
os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command

### Filtering tropical wave 
# FNL U925 (with GFS fcst)
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/u925/wkfilter_allwave_u925_fnl_gfs.ncl")
# FNL V925 (with GFS fcst)
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/v925/wkfilter_allwave_v925_fnl_gfs.ncl")
# Velocity potential 925 (calculated from U V)
#os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/vp925/wkfilter_allwave_vp925_fnl_gfs.ncl")

# FNL U200 (with GFS fcst)
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/u200/wkfilter_allwave_u200_fnl_gfs.ncl")
# FNL V200 (with GFS fcst)
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/v200/wkfilter_allwave_v200_fnl_gfs.ncl")
# Velocity potential 200 (calculated from U V)
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/vp200/wkfilter_allwave_vp200_fnl_gfs.ncl")
