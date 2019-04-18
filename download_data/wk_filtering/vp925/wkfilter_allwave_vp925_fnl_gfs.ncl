begin
plev = 925
variab = "vp925"
variab_long = "velocity potential 925"
fcstModel = "GFS"

;;---- read data
f1 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_allwave_u"+plev+"_GFSfcst_latest.nc","r")
umjo = f1->$("u"+plev+"mjo")$ ; t x lat x lon
ukel = f1->$("u"+plev+"kel")$ ; t x lat x lon
uer = f1->$("u"+plev+"er")$ ; t x lat x lon
umt = f1->$("u"+plev+"mt")$ ; t x lat x lon
printVarSummary(umjo)

f2 = addfile("/data5/hsushipei/filters/wk99_filter_ncl/latest/wk99_filt_allwave_v"+plev+"_GFSfcst_latest.nc","r")
vmjo = f2->$("v"+plev+"mjo")$ ; t x lat x lon
vkel = f2->$("v"+plev+"kel")$ ; t x lat x lon
ver = f2->$("v"+plev+"er")$ ; t x lat x lon
vmt = f2->$("v"+plev+"mt")$ ; t x lat x lon
printVarSummary(vkel)

;;---- calculate VP
sfvp_mjo = uv2sfvpF(umjo, vmjo) ; 2 x t x lat x lon
sfvp_kel = uv2sfvpF(ukel, vkel)
sfvp_er = uv2sfvpF(uer, ver)
sfvp_mt = uv2sfvpF(umt, vmt)

vpmjo = sfvp_mjo(1,:,:,:)  ; mjo
copy_VarMeta(umjo, vpmjo)
vpmjo@long_name = variab_long
printVarSummary(vpmjo)

vpkel = sfvp_kel(1,:,:,:)  ; kel
copy_VarMeta(ukel, vpkel)
vpkel@long_name = variab_long
printVarSummary(vpkel)

vper = sfvp_er(1,:,:,:)  ; er
copy_VarMeta(uer, vper)
vper@long_name = variab_long
printVarSummary(vper)

vpmt = sfvp_mt(1,:,:,:)  ; mt
copy_VarMeta(umt, vpmt)
vpmt@long_name = variab_long
printVarSummary(vpmt)

;;---- output NetCDF
outdir = "/data5/hsushipei/filters/wk99_filter_ncl/latest/"
outf = "wk99_filt_allwave_"+variab+"_"+fcstModel+"_latest.nc"
system("/bin/rm -f "+outdir+outf)
ncdf1 = addfile(outdir+outf ,"c")
filedimdef(ncdf1,"time",-1,True)
ncdf1->vpmjo = vpmjo
ncdf1->vpkel = vpkel
ncdf1->vper = vper
ncdf1->vpmt = vpmt

ncdf1->rt_startdate = f1->rt_startdate
ncdf1->rt_enddate = f1->rt_enddate
ncdf1->fcst_startdate = f1->fcst_startdate
ncdf1->fcst_enddate = f1->fcst_enddate

print("output-> "+outdir+outf)

end

