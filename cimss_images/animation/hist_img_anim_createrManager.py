import datetime, os, glob

"""
Manager for automatically (crontab) creating animation of satellite images once per day.

*** This program is designed for scheduled creation animation of historical satellite images during the past 1 and 2 weeks.
    to specify the date, channel and region for the animation, please use "hist_img_anim_creater.py".

* Controlled by: crontab
* Launch: "hist_img_anim_creater.py". (Give parameters to it.)

"""

curt =  datetime.datetime.now() # current time
#curt =  datetime.datetime(2017,8,30,20) # fake current time (LST)
curtU = curt + datetime.timedelta(hours=-8) # Current time in UTC
curtU_str = curtU.strftime('%Y%m%d') 
# current time = end of time for animation

p1w_startt = curtU + datetime.timedelta(days=-7)
p1w_startt_str = p1w_startt.strftime('%Y%m%d')
p2w_startt = curtU + datetime.timedelta(days=-14)
p2w_startt_str = p2w_startt.strftime('%Y%m%d')
perd_li = [p1w_startt_str,p2w_startt_str] # list of start time of animation
#perd_li = [p2w_startt_str] # list of start time of animation
hh_li = ["00","06","12","18"] ####
hh = ",".join(hh_li)
hh2 = "_".join(hh_li)

channel = ["NHC"] ####
region =  ["EH"] ####
ani_cretr_dir = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/animation"

for ch in channel:
	for rg in region:
		ani_out_dir = "/data5/hsushipei/tropical_weather_monitoring_system/cimss_images/animation/"+ch+"/"+rg
		for dd in perd_li: # period for the animation
			# Create animation
			print "* Creating aniamtion for "+ch+" over "+rg+" from "+dd+" to "+curtU_str
			os.system("/home/hsushipei/miniconda2/bin/python "+\
					ani_cretr_dir+"/hist_img_anim_creater.py "+dd+" "+curtU_str+" "+hh+" "+ch+" "+rg)

			# rename to include word "latest" to the animation (comment out this block to remain date in file name)
			ww = ( datetime.datetime.strptime(curtU_str,'%Y%m%d') - \
					datetime.datetime.strptime(dd,'%Y%m%d') ).total_seconds()/86400./7. # past ? week (for renaming)
			os.rename(ani_out_dir+"/cimss_ani_"+ch+"_"+rg+"_"+dd+"_"+curtU_str+"_"+hh2+".gif", \
					ani_out_dir+"/cimss_ani_past"+str( int(ww) )+"w_latest.gif") 


