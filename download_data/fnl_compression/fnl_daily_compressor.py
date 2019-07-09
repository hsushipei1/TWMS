import os, sys
sys.dont_write_bytecode = True

def compress_fnl_daily(infile, outfile):
	"""
	Compress each daily data with level=2 (compression rate is about 33% and spent around 6 sec.)
	This program is used as a module.

	Arguments:
	infile: input file (uncompressed file)
	outfile: output file (compressed file) 
	"""
	NCCOPY = "~/software/bin/nccopy"
	ncco_lev = 2
	os.system(NCCOPY+" -d "+str(ncco_lev)+" "+infile+" "+outfile)
	print infile+" compressed -> "+outfile

