% T1T2_start v1.5
% Job van den Hurk, 17-11-2020
% 1.4 added saveasdicom as option to result saving
% 1.5 added biexponential fitting for vTE T2 mapping

clear all
close all
clc

saveasdicom = 1;

[files,dir] = T1T2_selectfiles;
[ismultislice, sliceselection,NrOfSlices,doubleDataexists,fileselection,useallslices] = T1T2_checkformultislicedata(files);
[data,TEmat,vTEmat,ITmat,TRmat,PVmat,FAmat,mappingtype,header] = T1T2_readfiles(files,fileselection,sliceselection,NrOfSlices,doubleDataexists,useallslices);
%mappingtype = T1T2_checkmappingtype(TEmat,ITmat,TRmat,PVmat,FAmat,doubleDataexists,useallslices);


if ~isempty(mappingtype)
    %T1T2_plotinitialdata(data);
    
    [TheseVoxels,VoxelSelectionRange] = T1T2_selectvoxels(data,mappingtype);
    
    % curve fitting options (generic)
    opts = optimoptions('lsqcurvefit','Algorithm','trust-region-reflective',... % trust-region-reflective levenberg-marquardt
        'Display','off');
    
    
    
    if useallslices
        repetitions = NrOfSlices;
        fulldata = data;
        fullFA = FAmat;
        fullTR = TRmat;
        fullIT = ITmat;
        fullPV = PVmat;
        fullTE = TEmat;
        nrofparams = size(data,1) / NrOfSlices;
        
        if strcmp(mappingtype, 'useFA')
            [B1Files, f2f] = T1T2_selectB1files(data,NrOfSlices);
        end
        
    else
        repetitions = 1;
    end
    
    
    disp('Testing if parallel computing is available...')
    
    
    try
        if isempty(gcp)
            parpool;
        end
        disp('Parallel computing initialized!');
        multicore = 1;
    catch
        disp('No parallel computing available!');
         multicore = 0;
    end
    
    for rep = 1:repetitions
        tic
        if useallslices
            disp(['Processing slice ' num2str(rep) '/' num2str(repetitions)]);
            sliceselection = rep;
            
            dataslicing = zeros(1,NrOfSlices*nrofparams);
            
            for np = 1:nrofparams
                dataslicing(((rep-1)) + (np-1) * NrOfSlices + 1) = 1;
            end
            
            data = fulldata(dataslicing==1,:,:);
            FAmat = fullFA(dataslicing==1);
            ITmat = fullIT(dataslicing==1);
            TRmat = fullTR(dataslicing==1);
            PVmat = fullPV(dataslicing==1);
            TEmat = fullTE(dataslicing==1);
            
            
        end
        
        TheseVoxmax = squeeze(data(1,:,:)) < max(VoxelSelectionRange);
        TheseVoxmin = squeeze(data(1,:,:)) >= min(VoxelSelectionRange);
        TheseVoxels = (TheseVoxmax+TheseVoxmin)==2;
        
        
        
        switch mappingtype
            case 'useTR'
                if multicore
                    [map,FitMap,fitparams,fun,data] = T1T2_T1fitTR_parfor(data,TRmat,TheseVoxels,opts);
                    
                else
                    % [map,FitMap,fitparams,fun,data] = T1T2_T1fitIT(data,TRmat,TheseVoxels,opts);
                    
                    error('Serial processing for TR fitting not yet implemented.');
                end
                est_par = 'T1';
                x_label = 'TR (ms)';
                usedxdata = TRmat;
                
            case 'useFA'
                if useallslices
                    B1Map = dicomread(char(B1Files{f2f(rep)}));
                else
                    B1Map = [];
                end
                if multicore
                    
                    [map,FitMap,fitparams,fun,usedxdata] = T1T2_T1fitFA_parfor(data,FAmat,TRmat,TheseVoxels,B1Map,opts);
                    
                else
                    [map,FitMap,fitparams,fun,usedxdata] = T1T2_T1fitFA(data,FAmat,TRmat,TheseVoxels,B1Map,opts);
                end
                est_par = 'T1';
                x_label = 'Flip angle (degrees)';
                
            case 'useIT'
                if multicore
                    [map,FitMap,fitparams,fun,data] = T1T2_T1fitIT_parfor(data,ITmat,TRmat,TheseVoxels,opts);
                    
                else
                    [map,FitMap,fitparams,fun,data] = T1T2_T1fitIT(data,ITmat,TRmat,TheseVoxels,opts);
                end
                est_par = 'T1';
                x_label = 'Inversion Recovery Time (ms)';
                usedxdata = ITmat;
                
            case 'usePV'
                if multicore
                    [map,FitMap,fitparams,fun,data] = T1T2_T1fitIT_parfor(data,PVmat,TRmat,TheseVoxels,opts);
                    
                else
                    [map,FitMap,fitparams,fun,data] = T1T2_T1fitIT(data,PVmat,TRmat,TheseVoxels,opts);
                end
                
                est_par = 'T1';
                x_label = 'Inversion Recovery Time (private field) (ms)';
                usedxdata = PVmat;
                
            case 'useTE'
                if multicore
                    [map,FitMap,fitparams,fun,data] = T1T2_T2fitTE_parfor(data,TEmat,TRmat,TheseVoxels,opts);
                    
                else
                    [map,FitMap,fitparams,fun,data] = T1T2_T2fitTE(data,TEmat,TRmat,TheseVoxels,opts);
                end
                est_par = 'T2';
                x_label = 'Echo Time (ms)';
                usedxdata = TEmat;
                
            case 'usevTE'
                if multicore
                    [map,FitMap,fitparams,map_bi,FitMap_bi,fitparams_bi,fun,fun_bi,data] = T1T2_T2fitTE_biexpo_parfor(data,TEmat,TRmat,TheseVoxels,opts);
                    
                else
                    [map,FitMap,fitparams,map_bi,FitMap_bi,fitparams_bi,fun,fun_bi,data] = T1T2_T2fitTE_biexpo(data,TEmat,TRmat,TheseVoxels,opts);
                end
                est_par = 'T2star';
                x_label = 'Echo Time (ms)';
                usedxdata = TEmat;
            case 'useTEstar'
                if multicore
                    [map,FitMap,fitparams,fun,data] = T1T2_T2starfit_parfor(data,TEmat,TRmat,TheseVoxels,opts);
                else
                    [map,FitMap,fitparams,fun,data] = T1T2_T2starfit(data,TEmat,TRmat,TheseVoxels,opts);
                end
                
                est_par = 'T2star';
                x_label = 'Echo Time (ms)';
                usedxdata = TEmat;
                
        end
        disp(' ');
        toc
        if ~strcmp(mappingtype,'usevTE')
            T1T2_saveresults(dir,map,FitMap,fitparams,fun,usedxdata,data,est_par,TheseVoxels,x_label,sliceselection,header,saveasdicom);
            if ~useallslices
                T1T2_interactiveplot(map,data,FitMap,fitparams,fun,TheseVoxels,usedxdata,est_par,x_label);
            end
        else
            T1T2_saveresults_biexponential(dir,map,map_bi,FitMap,FitMap_bi,fitparams,fitparams_bi,fun,fun_bi,usedxdata,data,est_par,TheseVoxels,x_label,sliceselection,header,saveasdicom);
        end
    end
    delete(gcp);
end