function T1T2_interactiveplot(map,data,FitMap,fitparams,fun,TheseVox,usedxdata,est_par,x_label)

fig = figure(123);
movegui(fig,'northwest')
if strcmp(est_par,'T1')
    maxval = 50*ceil(2*mean(map(map>0))/50);
    if maxval>3000
        maxval = 3000;
    end
    imagesc(map);colormap('jet');axis image;c = colorbar;c.Label.String = [est_par ' (ms)'];caxis([0 maxval]);
elseif strcmp(est_par,'T2')
    maxval = 50*ceil(2*mean(map(map>0))/50);
    if maxval>300
        maxval = 300;
    end
    imagesc(map);colormap('jet');axis image;c = colorbar;c.Label.String = [est_par ' (ms)'];caxis([0 maxval]);
elseif strcmp(est_par,'T2star')
    maxval = 50*ceil(2*mean(map(map>0))/50);
    if maxval>200
        maxval = 200;
    end
    imagesc(map);colormap('jet');axis image;c = colorbar;c.Label.String = [est_par ' (ms)'];caxis([0 maxval]);
end
drawnow;
fig = figure(120); movegui(fig,'southwest');imagesc(FitMap);axis image;colormap('jet');c = colorbar;c.Label.String = 'Goodness-of-fit';caxis([0.75 1]);


if numel(size(usedxdata)) == 2;
    usedxdata = squeeze(repmat(usedxdata,1,1,size(data,2),size(data,3)));
end
button = 1;
disp('Press ESC to exit...');
while button==1
    figure(123);
    [xx, yy, button] = ginput(1);
    if button ~= 1
        break
    end
    yyy = cast(floor(yy),'int16');
    xxx = cast(floor(xx),'int16');
    
    xx = yyy;
    yy = xxx;
    if TheseVox(xx,yy)
        xdata = squeeze(usedxdata(:,xx,yy));
        ydata = squeeze(data(:,xx,yy));
        if numel(size(fitparams)) == 2
            fitparams = reshape(fitparams,[2 size(map)]);
        end
        x = fitparams(:,xx,yy);
        fig = figure(124);
        movegui(fig,'northeast')
        
        plot(xdata,ydata,'ko',linspace(xdata(1),2*xdata(end)),fun(x,linspace(xdata(1),2*xdata(end))),'b-');
        title(sprintf(['Location X = %d, Y = %d, ' est_par ' = %g ms, G-o-F = %g'],cast(floor(xx),'int16'),cast(floor(yy),'int16'),map(xx,yy),FitMap(xx,yy)));
        xlabel(x_label);
        ylabel('Signal (a.u.)');
        drawnow;
    end
end