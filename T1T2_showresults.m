close all;
[file, dir] = uigetfile;

load([dir file])

try
    T1T2_interactiveplot(map,data,FitMap,fitparams,fun,TheseVoxels,usedxdata,est_par,x_label);
catch
    error('Could not load all relevant files!');
end
