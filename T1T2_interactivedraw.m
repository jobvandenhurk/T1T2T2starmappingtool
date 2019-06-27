function T1T2_interactivedraw(map,data,FitMap,fitparams,fun,TheseVox,usedxdata,est_par,x_label)
NrOfBins = 25;
MaxVal = 200;
fig = figure(123);
movegui(fig,'northwest')

maxval = 50*ceil(2*mean(map(map>0))/50);
if maxval>150
    maxval = 150;
end
imagesc(map);axis image;colormap('jet');colorbar;caxis([0 maxval]);
%imagesc(squeeze(data(1,:,:)));axis image;colormap('bone');colorbar;caxis([0 100]);

while 0<1
    figure(123)
    roi = roipoly;
    
    fig = figure(200);
    movegui(fig,'northeast');
    
    [h,n]= hist(map(roi==1),NrOfBins);
    plot(n,h);
    xlabel([est_par ' (ms)']);
    ylabel('Voxel count');
    title(['Mean ' est_par ' value: ' num2str(mean(map(roi==1))) ' ms']);
    xlim([0 MaxVal]);
    %     labels_on_axis = 1:round(MaxVal/NrOfBins):MaxVal;
    %     set(gca, 'XTick', 1:round(MaxVal/NrOfBins):MaxVal, 'XTickLabel',labels_on_axis);
    
end