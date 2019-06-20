import os, pickle
print "!!!!! start -> gfs_merger.py  !!!!!"
gfs_data_dir = "/data5/hsushipei/data/gfs/ncep"

f = open(gfs_data_dir+"/"+"current_data_time.txt","rb")
dd = pickle.load(f)
f.close()
data_time = dd.strftime('%Y%m%d%H')

print "Merging GFS data on "+data_time
os.system("cat "+gfs_data_dir+"/"+"gfs."+data_time+".*.grib2 > "+gfs_data_dir+"/"+"gfs."+data_time+".pgrb2.1p00.f000_f384.grib2")

print "!!!!! Leave -> gfs_merger.py  !!!!!"
