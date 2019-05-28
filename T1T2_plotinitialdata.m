function T1T2_plotinitialdata(data)
figure;
[cols,rows] = T1T2_neardiv(size(data,1),'max');
maxintensity = max(data(:));
for ss = 1:size(data,1)
    subplot(rows,cols,ss,'align'); imagesc(squeeze(data(ss,:,:)));colormap('gray'); axis image; caxis([0 maxintensity]);
    axis off
end

drawnow;
