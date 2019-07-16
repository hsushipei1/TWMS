export PATH=/home/hsushipei/software/bin:${PATH}
export rtolrdir="/data5/hsushipei/data/total_field/OLR/realtime/"

yyyy=$(date +%Y) # current year

echo "==== Enter 'rt_olr_data.bash'. Download and create realtime OLR data... ===="

rm ${rtolrdir}olr-daily_v01r02-preliminary_20190101_latest.nc2
exit

wget http://olr.umd.edu/CDR/Daily/v01r02-interim/olr-daily_v01r02-preliminary_20190101_latest.nc \
	-O ${rtolrdir}olr-daily_v01r02-preliminary_20190101_latest.nc

# Create realtime OLR data (relative time)
cdo -O -cat \
	${rtolrdir}olr-daily_v01r02_20150101_prelim20181231.nc ${rtolrdir}olr-daily_v01r02-preliminary_20190101_latest.nc \
	${rtolrdir}latest_grads.nc

# Create realtime OLR data (absolute time)
cdo -O -a shifttime,-12hour ${rtolrdir}latest_grads.nc ${rtolrdir}latest.nc

echo "!!!! Leave 'rt_olr_data.bash'.End of processing realtime OLR data. !!!!"
