function [TheseVox,VoxelSelectionRange] = T1T2_selectvoxels(data,mappingtype)

FirstVol = squeeze(data(1,:,:));
LastVol = squeeze(data(end,:,:));


if strcmp(mappingtype,'useTEstar') || strcmp(mappingtype,'useTE')
    thisSlice = 1;
    thisVol = FirstVol;
else
    thisSlice = size(data,1);
    thisVol = LastVol;
end


VoxelSelectionRange = [round(min(thisVol(:)) + (max(thisVol(:)) - min(thisVol(:)))*0.05) round(max(thisVol(:)))];

OK = 0;

while ~OK
    TheseVoxmax = thisVol < max(VoxelSelectionRange);
    TheseVoxmin = thisVol >= min(VoxelSelectionRange);
    TheseVox = (TheseVoxmax+TheseVoxmin)==2;
    
    figure(3);subplot(1,2,1); imagesc(squeeze(data(thisSlice,:,:)));colormap(gca,'gray'); colorbar; axis image;
    
    figure(3);subplot(1,2,2); imagesc(double(TheseVox));colormap(gca,'gray');axis image;caxis([0 1]);
    v = input(['Current range: ' num2str(min(VoxelSelectionRange)) ' to ' num2str(max(VoxelSelectionRange)) ' - provide min - max intensity values for selection (enter if OK): '],'s');
    
    figure(3)
    
    
    
    
    title('Voxel selection');
    
    adaptedv = ['[' v ']'];
    
    if ~isempty(v)
        try
            VoxelSelectionRange = eval(adaptedv);
        catch
            disp('Invalid entry.');
        end
        
    else
        OK = 1;
        close all
    end
    
end



