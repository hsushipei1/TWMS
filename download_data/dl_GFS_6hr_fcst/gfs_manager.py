import os, pickle

print "!!!!! Leave -> gfs_manager.py  !!!!!"
gfs_process_file_dir = "/data5/hsushipei/tropical_weather_monitoring_system/download_data/dl_GFS_6hr_fcst"

# Download GFS data
os.system("/home/hsushipei/miniconda2/bin/python "+gfs_process_file_dir+"/gfs_downloader.py")

# Merge GFS data into one
os.system("/home/hsushipei/miniconda2/bin/python "+gfs_process_file_dir+"/gfs_merger.py")

# Create ctl file
os.system("/home/hsushipei/miniconda2/bin/python "+gfs_process_file_dir+"/gfs_ctl_creater.py")

# Create nc file
os.system("/home/hsushipei/miniconda2/bin/python "+gfs_process_file_dir+"/gfs_olr_nc_creater.py")
os.system("/home/hsushipei/miniconda2/bin/python "+gfs_process_file_dir+"/gfs_pw_nc_creater.py")
os.system("/home/hsushipei/miniconda2/bin/python "+gfs_process_file_dir+"/gfs_u_nc_creater.py")
os.system("/home/hsushipei/miniconda2/bin/python "+gfs_process_file_dir+"/gfs_v_nc_creater.py")
os.system("/home/hsushipei/miniconda2/bin/python "+gfs_process_file_dir+"/gfs_hgt_nc_creater.py")

print "!!!!! Leave -> gfs_manager.py  !!!!!"
