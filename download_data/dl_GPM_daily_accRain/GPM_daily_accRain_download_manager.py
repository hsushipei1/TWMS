#!/home/hsushipei/miniconda2/bin/python
import pickle, os, datetime, glob

downloader_dir = "/data5/hsushipei/tropical_weather_monitoring_system/download_data/dl_GPM_daily_accRain"

## Download data
os.system("/home/hsushipei/miniconda2/bin/python "+downloader_dir+"/GPM_daily_accRain_downloader.py")


