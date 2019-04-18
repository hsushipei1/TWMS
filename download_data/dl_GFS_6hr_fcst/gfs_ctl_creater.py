import os, pickle
print "!!!!! start -> ctl_creater.py  !!!!!"
gfs_data_dir = "/data5/hsushipei/data/gfs/ncep"
PERL = "/home/hsushipei/software/bin/perl "

f = open(gfs_data_dir+"/"+"current_data_time.txt","rb")
dd = pickle.load(f)
f.close()
data_time = dd.strftime('%Y%m%d%H')

print "Creating ctl for GFS data on "+data_time
#os.system("/usr/bin/g2ctl "+gfs_data_dir+"/"+"gfs."+data_time+".pgrb2.1p00.f000_f384.grib2 > "+gfs_data_dir+"/"+"gfs."+data_time+".pgrb2.1p00.f000_f384.ctl") # older g2ctl version
os.system(PERL+"/home/hsushipei/software/PREVIOUS_SOFTWARE/g2ctl-0.1.2/g2ctl "+gfs_data_dir+"/"+"gfs."+data_time+".pgrb2.1p00.f000_f384.grib2 > "+gfs_data_dir+"/"+"gfs."+data_time+".pgrb2.1p00.f000_f384.ctl")

os.system("/data7/SOFT/OpenGrADS/grads-2.0.2.oga.2/Contents/gribmap -i "+gfs_data_dir+"/"+"gfs."+data_time+".pgrb2.1p00.f000_f384.ctl") # older gribmap version, for OpenGrads-2.0.2*
#os.system("/home/hsushipei/software/PREVIOUS_SOFTWARE/grads-2.1.0.oga.1/Contents/gribmap -i "+gfs_data_dir+"/"+"gfs."+data_time+".pgrb2.1p00.f000_f384.ctl")

print "!!!!! Leave -> ctl_creater.py  !!!!!"
