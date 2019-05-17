% T1T2_start v1.0
% Job van den Hurk, 17-05-2019

clear all
close all
clc

[files,dir] = T1T2_selectfiles;
[ismultislice, sliceselection,NrOfSlices,doubleDataexists,fileselection] = T1T2_checkformultislicedata(files);
[data,TEmat,ITmat,TRmat,PVmat,FAmat] = T1T2_readfiles(files,fileselection,sliceselection,NrOfSlices,doubleDataexists);
mappingtype = T1T2_checkmappingtype(TEmat,ITmat,TRmat,PVmat,FAmat,doubleDataexists);

if ~isempty(mappingtype)
    T1T2_plotinitialdata(data);
    
    TheseVoxels = T1T2_selectvoxels(data,mappingtype);
    
    
    % curve fitting options (generic)
    opts = optimoptions('lsqcurvefit','Algorithm','trust-region-reflective',... % trust-region-reflective levenberg-marquardt
        'Display','off');
    tic
    switch mappingtype
        case 'useFA'
            [map,FitMap,fitparams,fun,usedxdata] = T1T2_T1fitFA(data,FAmat,TRmat,TheseVoxels,opts);
            est_par = 'T1';
            x_label = 'Flip angle (degrees)';
        case 'useIT'
            [map,FitMap,fitparams,fun,data] = T1T2_T1fitIT(data,ITmat,TRmat,TheseVoxels,opts);
            est_par = 'T1';
            x_label = 'Inversion Recovery Time (ms)';
            usedxdata = ITmat;
        case 'usePV'
            [map,FitMap,fitparams,fun,data] = T1T2_T1fitIT(data,PVmat,TRmat,TheseVoxels,opts);
            est_par = 'T1';
            x_label = 'Inversion Recovery Time (private field) (ms)';
            usedxdata = PVmat;
        case 'useTE'
            [map,FitMap,fitparams,fun,data] = T1T2_T2fitTE(data,TEmat,TRmat,TheseVoxels,opts);
            est_par = 'T2';
            x_label = 'Echo Time (ms)';
            usedxdata = TEmat;
        case 'useTEstar'
            [map,FitMap,fitparams,fun,data] = T1T2_T2starfitTE(data,TEmat,TRmat,TheseVoxels,opts);
            est_par = 'T2star';
            x_label = 'Echo Time (ms)';
            usedxdata = TEmat;
    end
    disp(' ');
    toc
    T1T2_saveresults(dir,map,FitMap,fitparams,fun,usedxdata,data,est_par,TheseVoxels,x_label);
    T1T2_interactiveplot(map,data,FitMap,fitparams,fun,TheseVoxels,usedxdata,est_par,x_label);
end
