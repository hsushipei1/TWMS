#!/home/hsushipei/miniconda2/bin/python
"""
Slice FNL data and merge them (with cdo) to single file (6 hr or daily)
Delete cache (intermediate)
"""
import pickle, os, datetime
os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command
PYTHON = "/home/hsushipei/miniconda2/bin/python "
sliced_dir = "/data5/hsushipei/data/fnl/sliced/latest/6hr/" # destination for sliced FNL file
os.chdir(sliced_dir)
fnl_slicer_dir = "/data5/hsushipei/tropical_weather_monitoring_system/download_data/sliced_fnl/" # slice program

def chk_sliced_exist(file_path, file_name):
	if not os.path.exists(file_path+file_name):
		print "Fatal: Sliced data "+file_name+" doesnt exist after slicing!"
		#quit()

fnewt = open("/data5/hsushipei/data/fnl/ncep/download_script/nexttimestep.donttouchme","r")
newt = pickle.load(fnewt) + datetime.timedelta(hours=-6) # date of latest FNL data
#newt = datetime.datetime(2018,7,23,06) # FOR DEBUGGING
fcrt = open(fnl_slicer_dir+"current_time","rb")
crt = pickle.load(fcrt) # lastest sliced data.
#crt = datetime.datetime( 2018,7,22,12 ) # FOR DEBUGGING 
dt = (newt-crt).total_seconds()/3600 # new t - current t (hours): dt between latest FNL and sliced data
#print newt
#print crt
#print dt
#quit()

print "&&&& Enter 'fnl_slicer_manager.py' at "+str(crt)+" => Start slicing files &&&&"

if dt >= 6: ## does sliced data lags (including newt) latest FNL for more than 1 t step?
	tstep = dt/6.0 # lagged t steps
	tt = 1 # counter
	while tt <= tstep:
		# Slice FNL to generate 6 hourly data
		print "Latest FNL: "+str(newt)+", latest sliced: "+str(crt)+" ==> lagged t step= "+str(tstep)
		crt = crt+datetime.timedelta(hours=+6)
		crt_str = crt.strftime("%Y%m%d%H") # yyyymmddhh

		print "# Slicing FNL at "+crt_str+" ("+str(tt)+"th lagged time steps)"
		#os.system("DATE="+crt_str+" VAR=u "+NCL+fnl_slicer_dir+"fnl_slicer.ncl") # u, NCL slicer 
		#os.system("DATE="+crt_str+" VAR=v "+NCL+fnl_slicer_dir+"fnl_slicer.ncl") # v
		#os.system("DATE="+crt_str+" VAR=pw "+NCL+fnl_slicer_dir+"fnl_slicer_2d.ncl") # pw

		# wgrib2 slicer (20180425: newer slicer. Hope to replace NCL slicer.)
		os.system(PYTHON+fnl_slicer_dir+"fnl_slicer_wgrib2.py "+crt_str) 
		chk_sliced_exist(sliced_dir, "fnl025_hgt_"+crt_str+".nc4") # check slicing
		chk_sliced_exist(sliced_dir, "fnl025_pw_"+crt_str+".nc4") # check slicing
		chk_sliced_exist(sliced_dir, "fnl025_u_"+crt_str+".nc4") # check slicing
		chk_sliced_exist(sliced_dir, "fnl025_v_"+crt_str+".nc4") # check slicing
	
		# Merge sliced data to single long-term daily data
		os.system("/data5/hsushipei/tropical_weather_monitoring_system/download_data/merge_sliced/merge_sliced.py "+crt_str)

		tt=tt+1
	fcrt = open(fnl_slicer_dir+"current_time","wb")
	pickle.dump(crt, fcrt) # update latest sliced data
	fcrt.close()
elif dt == 0.0:  # sliced data is up-to-dated.
	print "Sliced data is up-to-dated. t= "+str(crt)+" (dt = 0hr)"
	quit()
else:
	print "dt != 6 or 0hr. Something wrong?"
	quit()

## Delete cache
del_days = 30
deleter = "/data5/hsushipei/tropical_weather_monitoring_system/download_data/delete_cache/delete_fnl_6hr_cache.py"
os.system(deleter+" u "+str( del_days ) )
os.system(deleter+" v "+str( del_days ) )
os.system(deleter+" pw "+str( del_days ) )
os.system(deleter+" hgt "+str( del_days ) )


print "&&&& Leaving 'fnl_slicer_manager.py' at "+str(crt)+" => End slicing files &&&&"
