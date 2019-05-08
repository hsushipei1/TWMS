out_dir=/data5/hsushipei/tropical_weather_monitoring_system/report/TWMR_ver3/latest_figs
## Satellite anomation
cp /data5/hsushipei/tropical_weather_monitoring_system/cimss_images/animation/NHC/EH/cimss_ani_past1w_latest.gif \
	${out_dir}/satellite_ani.gif

## Past 3 pentad
dir=/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map
# OLR 
convert -crop 836x1128+184+28 \
	${dir}/olr_wind_hist/olr_fnl025_925wind_hist.pdf ${out_dir}/penta_olr.png
# OLRA 
convert -crop 836x1128+184+28 \
	${dir}/olr_wind_anomaly_hist/olr_fnl025_925wind_anomaly_hist.pdf ${out_dir}/penta_olra.png
# Precip 
convert -crop 836x1128+184+28 \
	${dir}/precip_hist/GPM_precip_hist.pdf ${out_dir}/penta_pcp.png
# PW 
convert -crop 836x1128+184+28 \
	${dir}/pw_wind_hist/pw_fnl025_925wind_hist.pdf ${out_dir}/penta_pw.png
# SST 
convert -crop 836x1128+184+28 \
	${dir}/sst_hist/oisst_hist.pdf ${out_dir}/penta_sst.png
# SSTA 
convert -crop 836x1128+184+28 \
	${dir}/sst_anoamly_hist/oisst_anomaly_hist.pdf ${out_dir}/penta_ssta.png

## ENSO
dir=/data5/hsushipei/tropical_weather_monitoring_system/hovmoller
# Hov ssta
convert -crop 828x894+134+170 \
	${dir}/oisst_anomaly_eq_1y/hov_ssta_9dAvg_latest.pdf ${out_dir}/enso_hov_ssta.png
# Hov olra
convert -crop 828x929+136+173 \
	${dir}/olr_u925_anomaly_eq_1y/hov_olr_u925_anomaly_9dAvg_latest.pdf ${out_dir}/enso_hov_olra.png

dir=/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/interannual_scale
# ssta
convert -crop 1006x506+78+362 \
	${dir}/interannual_sst_925wind/interannual_sst_925wind_latestMonth.pdf ${out_dir}/enso_ssta.png
# olra
convert -crop 1006x506+78+362 \
	${dir}/interannual_olr/interannual_olr_latestMonth.pdf ${out_dir}/enso_olra.png
# SSTA fcst time series 
# SSTA fcst map

## Seasonal
dir=/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map
# 200 hPa
convert -rotate "-90" -crop 1136x924+32+133 \
	${dir}/windspd_wind_200_hist/windspd_wind_200_hist.pdf ${out_dir}/weekly_windspd_wind_200.png
# 500 hPa
convert -crop 1128x1136+34+30 \
	${dir}/hgt_500_hist/hgt_500_hist.pdf ${out_dir}/weekly_hgt_500.png
# 850 hPa
convert -rotate "-90" -crop 1138x862+32+163 \
	${dir}/windspd_wind_850_hist/windspd_wind_850_hist.pdf ${out_dir}/weekly_windspd_wind_850.png

## MJO and tropical waves
# RMM diagram
# RMM fcst

# hovmoller 
dir=/data5/hsushipei/tropical_weather_monitoring_system/hovmoller/wkfiltered_waves/olr_onOLRanomaly_fcst
# -5 5
convert -crop 828x838+135+234 \
	${dir}/hov_wkfilter_olr_onOLRanomaly_gfs_latest_-5_5.pdf ${out_dir}/wave_hov_olr_-5_5.png
# 5 15
convert -crop 828x838+135+234 \
	${dir}/hov_wkfilter_olr_onOLRanomaly_gfs_latest_5_15.pdf ${out_dir}/wave_hov_olr_5_15.png

dir=/data5/hsushipei/tropical_weather_monitoring_system/daily_weather_map/wkfiltered_waves/on_OLRanoamly_gfs
# MJO VP200
convert -crop 1128x774+36+248 \
	${dir}/mjo_vp200_onOLRanomaly_gfs.pdf ${out_dir}/mjo_vp200.png
# Kel olr
convert -crop 988x1072+106+92 \
	${dir}/kelvin_olr_onOLRanomaly_gfs.pdf ${out_dir}/kel_olr.png
# ER olr
convert -crop 1128x1011+34+130 \
	${dir}/er_olr_onOLRanomaly_gfs.pdf ${out_dir}/er_olr.png
# MRG-TD olr
convert -crop 1128x1011+34+130 \
	${dir}/mrgtd_olr_onOLRanomaly_gfs.pdf ${out_dir}/mt_olr.png

## TC
# world wide
# TC tracker


