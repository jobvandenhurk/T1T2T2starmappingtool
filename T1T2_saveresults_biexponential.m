function T1T2_saveresults_biexponential(dir,map,map_bi,FitMap,FitMap_bi,fitparams,fitparams_bi,fun,fun_bi,usedxdata,data,est_par,TheseVoxels,x_label,sliceselection,header,saveasdicom)

filename = [dir '/T2_biexponential_mappingresults_slice_' num2str(sliceselection) '_' date '.mat'];

save(filename,'map','map_bi','FitMap','FitMap_bi','fitparams','fitparams_bi','fun','fun_bi','usedxdata','data','est_par','TheseVoxels','x_label');
disp(['Results saved to file ' filename]);

if saveasdicom
    if ~exist([dir '/DICOM'],'dir')
        mkdir([dir '/DICOM']);
    end
    
    dicomfilename = filename;
    dicomfilename = strrep(dicomfilename,dir,[dir '/DICOM/']);
    dicomwrite(map_bi, strrep(dicomfilename,'.mat','.IMA'), header);
end