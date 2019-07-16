export PATH=/home/hsushipei/software/bin:${PATH}
export rtolrdir="/data5/hsushipei/data/total_field/OLR/realtime/"
export merge_dir=${rtolrdir}"for_merging/" 
		# Download the raw OLR file into directory "for_merging" for the convenience to merge into "latest.nc"

yyyy=$(date +%Y) # current year

echo "==== Enter 'rt_olr_data.bash'. Download and create realtime OLR data... ===="

rm ${merge_dir}olr-daily_v01r02-preliminary_${yyyy}0101_latest.nc
exit


wget http://olr.umd.edu/CDR/Daily/v01r02-interim/olr-daily_v01r02-preliminary_${yyyy}0101_latest.nc \
	-O ${rtolrdir}olr-daily_v01r02-preliminary_${yyyy}0101_latest.nc

exit
# Create realtime OLR data (relative time)
cdo -O -cat \
	${rtolrdir}olr-daily_v01r02_20150101_prelim20181231.nc ${rtolrdir}olr-daily_v01r02-preliminary_20190101_latest.nc \
	${rtolrdir}latest_grads.nc

# Create realtime OLR data (absolute time)
cdo -O -a shifttime,-12hour ${rtolrdir}latest_grads.nc ${rtolrdir}latest.nc

echo "!!!! Leave 'rt_olr_data.bash'.End of processing realtime OLR data. !!!!"
