import os
os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command

### Filtering tropical wave 
# OLR (without GFS fcst)
#os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/olr/wkfilter_mjo_olr.ncl")
#os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/olr/wkfilter_kel_olr.ncl")
#os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/olr/wkfilter_er_olr.ncl")
#os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/olr/wkfilter_mrg_olr.ncl")

# OLR (with GFS fcst)
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/olr/wkfilter_allwave_olr_fnl_gfs.ncl")

"""
### Filtering tropical wave for forecast verification
# OLR
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/filter_fcst_verif/olr/filter_fcst_verif_mjo_olr.ncl")
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/filter_fcst_verif/olr/filter_fcst_verif_kel_olr.ncl")
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/filter_fcst_verif/olr/filter_fcst_verif_er_olr.ncl")
os.system(NCL+"/data5/hsushipei/tropical_weather_monitoring_system/download_data/wk_filtering/filter_fcst_verif/olr/filter_fcst_verif_mt_olr.ncl")
"""

