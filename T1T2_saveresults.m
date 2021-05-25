function T1T2_saveresults(dir,map,FitMap,fitparams,fun,usedxdata,data,est_par,TheseVoxels,x_label,sliceselection,header,saveasdicom)

filename = [dir '/' est_par '_mappingresults_slice_' num2str(sliceselection) '_' date '.mat'];

save(filename,'map','FitMap','fitparams','fun','usedxdata','data','est_par','TheseVoxels','x_label');
disp(['Results saved to file ' filename]);

if saveasdicom
    if ~exist([dir '/DICOM'],'dir')
        mkdir([dir '/DICOM']);
    end
    
    dicomfilename = filename;
    dicomfilename = strrep(dicomfilename,dir,[dir '/DICOM/']);
    dicomwrite(map, strrep(dicomfilename,'.mat','.IMA'), header);
end