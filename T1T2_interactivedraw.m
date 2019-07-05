function T1T2_interactivedraw(map,data,FitMap,fitparams,fun,TheseVox,usedxdata,est_par,x_label)
NrOfBins = 25;
MaxVal = 200;
map(isnan(map)) = 0;

if strcmp(est_par,'T2')
map(map>500) = 0;
elseif strcmp(est_par,'T1')
map(map>5000) = 0;    
end

maxval = 50*ceil(2*mean(map(map>0))/50);
if maxval>MaxVal
    maxval = MaxVal;
end

fig = figure(122);
movegui(fig,'southwest')


imagesc(map);axis image;colormap('jet');colorbar;caxis([0 maxval]);
%imagesc(squeeze(data(1,:,:)));axis image;colormap('bone');colorbar;caxis([0 120]);

fig = figure(123);
movegui(fig,'northwest')


%imagesc(map);axis image;colormap('jet');colorbar;caxis([0 maxval]);
imagesc(squeeze(data(1,:,:)));axis image;colormap('bone');colorbar;caxis([0 220]);



disp('Press escape to quit.');
quit = 0;
meanmap = [];
while ~quit
    figure(123);
    
    roi = roipoly;
    
    if ~isempty(roi)
        
        
        % draw ROI in figure
        
        figure(122);
        hold on
        mask = zeros(size(map));
        mask(roi==1) = 0.6;
        white = cat(3,ones(size(map)),ones(size(map)),ones(size(map)));
        m = imshow(white);
        set(m,'AlphaData',mask);
        hold off
        fig = figure(200);
        movegui(fig,'northeast');
        
        
        plotdata = map(roi==1);
        meanmap = [meanmap; plotdata(plotdata>0)];
        [h,n]= hist(plotdata(plotdata>0),NrOfBins);
        
        plot(n,h);
        xlabel([est_par ' (ms)']);
        ylabel('Voxel count');
        title(['Mean ' est_par ' value: ' num2str(mean(map(roi==1),'omitnan')) ' ms']);
        xlim([0 MaxVal]);
        
        fig = figure(201);
        movegui(fig,'southeast');
        
        
        [h,n]= hist(meanmap,NrOfBins);
        
        plot(n,h);
        xlabel([est_par ' (ms)']);
        ylabel('Voxel count');
        title(['Mean ' est_par ' value across selected ROIs: ' num2str(mean(meanmap(:),'omitnan')) ' ms']);
        xlim([0 MaxVal]);
        
        %     labels_on_axis = 1:round(MaxVal/NrOfBins):MaxVal;
        %     set(gca, 'XTick', 1:round(MaxVal/NrOfBins):MaxVal, 'XTickLabel',labels_on_axis);
    else
        quit = 1;
    end
end
