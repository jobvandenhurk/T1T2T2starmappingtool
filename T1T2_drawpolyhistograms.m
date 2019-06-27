close all;
[file, dir] = uigetfile;

load([dir file])


T1T2_interactivedraw(map,data,FitMap,fitparams,fun,TheseVoxels,usedxdata,est_par,x_label);
