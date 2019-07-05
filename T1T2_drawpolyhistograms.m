close all;
[file, dir] = uigetfile('Multiselect','on');

tdata = [];
if iscell(file)
    for ff = 1:numel(file)
        load([dir char(file{ff})]);
        tdata = cat(3,tdata,map);
    end
else
    load([dir file]);
end

T1T2_interactivedraw(map,data,FitMap,fitparams,fun,TheseVoxels,usedxdata,est_par,x_label);
