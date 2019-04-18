import datetime, os, pickle

"""
Second version of FNL data downloader: Able to download not only FNL

/ f exists -> + 1day ->                                  / success -> +1 day -> output time ->
                       DOWNLOAD => DOWNLOAD VERIFICATION                                       EXIT
\ f doesnt exist    ->                                   \ fail (try next time )------------>

f is a single data
"""

data_shortn = "GPM_daily_accRain" # short name
data_dir = "/data5/hsushipei/data/total_field/Precip/GPM/realtime"
data_name_pf = "3B-DAY-E.MS.MRG.3IMERG." # prefix of data name, separated by date
data_name_sf = "-S000000-E235959.V05.nc4" # suffix of data name, separated by date
next_t_step_dir = "/data5/hsushipei/tropical_weather_monitoring_system/download_data/dl_GPM_daily_accRain"
next_t_step_f = data_shortn+"_next_t_step"

fts = open(next_t_step_dir+"/"+next_t_step_f, "r") # time step file
nextt = pickle.load(fts) # time of data that will download next time
data_fn = data_name_pf+nextt.strftime('%Y%m%d')+data_name_sf # full file name of data
fts.close()

print "* I will download data: "+data_shortn+" on "+nextt.strftime('%Y%m%d')+", before that, I'll check whether it exists..."
#### Check data at "nextt" and download
## Data at "nextt" already exists, t + 1day
if os.path.exists(data_dir+"/"+data_fn): 
	print("* "+data_shortn+" on "+nextt.strftime('%Y%m%d')+" already exist. ")
	nextt = nextt + datetime.timedelta(days=+1) # move 1 day forward
	print("* Shift download time to-> "+nextt.strftime('%Y%m%d')+" and start downloading.")

## Data at "nextt" doesn't exist. Download it, however, it has two consequences to be considered,
# 1) Data at "nextt" is successfully downloaded, and then move 1 day forward in "next time step" file.
# 2) Try to download the data but it's still not available yet. dont move the time forward.
else: 
	print("* "+data_shortn+" on "+nextt.strftime('%Y%m%d')+" doesn't exist. Start downloading it now.")

## Download data
nextt_yy = nextt.strftime('%Y')
nextt_mm = nextt.strftime('%m')
nextt_str = nextt.strftime('%Y%m%d')
wlink = "https://gpm1.gesdisc.eosdis.nasa.gov/data/GPM_L3/GPM_3IMERGDE.05/"+nextt_yy+"/"+nextt_mm+"/3B-DAY-E.MS.MRG.3IMERG."+nextt_str+"-S000000-E235959.V05.nc4"
os.chdir(data_dir) # Go into directory, so the downloaded data will be placed in this folder.
os.system("wget "+wlink) # download data
####

#### Check whether the download is successful or not. (The data may be still unavailable to download.)
data_fn = data_name_pf+nextt.strftime('%Y%m%d')+data_name_sf # full file name of data
print "* Checking whether the download is successful or not for "+data_shortn+" on "+nextt.strftime('%Y%m%d')+"..."

# If downloaded successfully
if os.path.exists(data_dir+"/"+data_fn): 
	print "* Download is successful. "+data_shortn+" on "+nextt.strftime('%Y%m%d')+" exists. Move 1 day forward in time step file "+next_t_step_f
	# +1day and write to file
	nextt = nextt + datetime.timedelta(days=+1) # move 1 day forward
	fts = open(next_t_step_dir+"/"+next_t_step_f, "w")
	pickle.dump(nextt, fts) # write t to file
	fts.close()
	
# If failed to download
else:
	print "* Cannot find data: "+data_shortn+" on "+nextt.strftime('%Y%m%d')+", why?  Will try again next time. "
	quit() # Leave program and will not +1day to t and try next time
####
