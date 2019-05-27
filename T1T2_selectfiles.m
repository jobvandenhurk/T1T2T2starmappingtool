function [files, dir] = T1T2_selectfiles

dir = uigetdir;

if ~dir
    [files, dir] = uigetfile({'*.IMA', 'Raw Dicom file (*.IMA)';...
        '*.dcm', 'BrainVoyager Dicom file (*.dcm)';...
        '*.*', 'Any file'}, 'MultiSelect', 'on');
    
    if ~dir
        error('No folder or files selected!');
    end
    
    cd(dir)
else
    cd(dir)
    files = T1T2_listfiletypes(dir,'0');
end

