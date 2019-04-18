import datetime, os, shutil

channel = "NHC"
region = "EH"
case = channel+"_"+region
wave = "Kelvin" # "MJO", "Kelvin", "ER", "MRG-TD" (MRG/TD), "pMRG" (Pure asymmetric MRG)
hist_root = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/past_7d"
channel_root = hist_root+"/"+channel
overlaid_img = channel_root+"/overlaid"
cropped_img = "cropped"
wave_dir = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/wave_overlay/plot_waves"
cwd = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/wave_overlay"
os.chdir(cwd)

os.environ["NCARG_ROOT"]="/home/hsushipei/software/PREVIOUS_SOFTWARE/ncl-6.3.0" # necessary for NCL
NCL = "~/software/PREVIOUS_SOFTWARE/ncl-6.3.0/bin/ncl -Q " # NCL command

startd = datetime.datetime(2017,8,7)
startd_str = startd.strftime('%Y%m%d')
endd = datetime.datetime(2017,8,17)
endd_str = endd.strftime('%Y%m%d')
deltad = datetime.timedelta(days=+1) 
subt = ["06"] # only satellite image on 06z is chosen
subt_str = ",".join(subt)

# Download, overlay, and crop satellite images
os.system("python "+hist_root+"/hist_img_DoItOnceManager.py "+startd_str+" "+endd_str+" "+subt_str+" "+channel+" "+region)

# Plot waves
if wave=="Kelvin":
	print "Kelvin"
	os.system("DSTART="+startd_str+" DEND="+endd_str+" WAVE="+wave+" "+\
			NCL+wave_dir+"/plot_wave_2overlay_satellite_10S10N.ncl")
elif (wave=="MJO") or (wave=="ER") or (wave=="MRG-TD") or (wave=="pMRG"):
	print wave
	os.system("DSTART="+startd_str+" DEND="+endd_str+" WAVE="+wave+" "+\
			NCL+wave_dir+"/plot_wave_2overlay_satellite_20S20N.ncl")

# Overlay wave on satellite image (time step by time step)
intm_overlay_dir = "process_overlay_wave"
try:
	os.makedirs(intm_overlay_dir)
except:
	pass

while startd <= endd:
	strd_str = startd.strftime('%Y%m%d')
	for hh in subt:
		if wave=="Kelvin":
			print "Overlaying "+wave+" on satellite on "+strd_str+" "+hh+"..."
			# create plain backgroud
			os.system("convert -size 1664x608 xc:black ./"+intm_overlay_dir+"/bk_"+wave+"_"+case+"_"+strd_str+"."+hh+".png")
			# overlay satellite image on plain background to be the background for wave
			os.system("convert -composite -geometry +112+50 \
				./"+intm_overlay_dir+"/bk_"+wave+"_"+case+"_"+strd_str+"."+hh+".png \
				"+channel_root+"/"+cropped_img+"/overlaid_NHC_EH_"+strd_str+"."+hh+"_cropped.png \
				"+intm_overlay_dir+"/bk_satellite_"+wave+"_"+case+"_"+strd_str+"."+hh+".png")
			# crop and resize the original wave plot
			os.system("convert -crop 772x259+15+217 -resize 222% "+wave_dir+"/"+wave+"_olr_"+strd_str+".png "\
					+intm_overlay_dir+"/"+wave+"_olr_"+strd_str+"_cropped.png")
			# Overlay  wave plot on satellite background
			os.system("convert -composite -geometry -3+3 \
					"+intm_overlay_dir+"/bk_satellite_"+wave+"_"+case+"_"+strd_str+"."+hh+".png " \
					+intm_overlay_dir+"/"+wave+"_olr_"+strd_str+"_cropped.png " \
					+cwd+"/overlaying_wave_on_satellite/"+wave+"_overlaid_"+case+"_"+strd_str+".png")
			
		if (wave=="MJO") or (wave=="ER") or (wave=="MRG-TD") or (wave=="pMRG"):
			print "Overlaying "+wave+" on satellite on "+strd_str+" "+hh+"..."
			# create plain backgroud
			os.system("convert -size 1664x688 xc:black ./"+intm_overlay_dir+"/bk_"+wave+"_"+case+"_"+strd_str+"."+hh+".png")
			# overlay satellite image on plain background to be the background for wave
			os.system("convert -composite -geometry +112+50 \
				./"+intm_overlay_dir+"/bk_"+wave+"_"+case+"_"+strd_str+"."+hh+".png \
				"+channel_root+"/"+cropped_img+"/overlaid_NHC_EH_"+strd_str+"."+hh+"_cropped.png \
				"+intm_overlay_dir+"/bk_satellite_"+wave+"_"+case+"_"+strd_str+"."+hh+".png")
			# crop and resize the original wave plot
			os.system("convert -crop 772x310+15+216 -resize 221% "+wave_dir+"/"+wave+"_olr_"+strd_str+".png "\
					+intm_overlay_dir+"/"+wave+"_olr_"+strd_str+"_cropped.png")
			# Overlay  wave plot on satellite background
			os.system("convert -composite -geometry +9+0 \
					"+intm_overlay_dir+"/bk_satellite_"+wave+"_"+case+"_"+strd_str+"."+hh+".png " \
					+intm_overlay_dir+"/"+wave+"_olr_"+strd_str+"_cropped.png " \
					+cwd+"/overlaying_wave_on_satellite/"+wave+"_overlaid_"+case+"_"+strd_str+".png")
			

	startd = startd + deltad

# Delete intermediate files
#shutil.rmtree(intm_overlay_dir)

print "Done "+wave+" overlaying on "+case+"! Thank you!"
