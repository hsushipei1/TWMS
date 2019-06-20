import os

# Download FNL
os.system("python /data5/hsushipei/data/fnl/ncep/download_script/todownload_ornot.py")

# Slice and merge sliced FNL 
# Delete cache (6 hourly data) 
os.system("/data5/hsushipei/tropical_weather_monitoring_system/download_data/sliced_fnl/fnl_slicer_manager.py") 
			# Specific Python Interpreter is given in .py file

# plot latest fnl data (6hr)
#os.system("python /data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wind_6hr/plot_wind_6hr_manager.py")
