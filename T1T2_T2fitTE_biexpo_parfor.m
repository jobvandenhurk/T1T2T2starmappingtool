function [T2Map,FitMap,fitparams,T2Map_bi,FitMap_bi,fitparams_bi,fun,fun_bi,data] = T1T2_T2fitTE_biexpo_parfor(data,TEmat,TRmat,TheseVox,opts)


datasize = size(data);
T2Map = zeros([datasize(2) datasize(3)]);
T2Map_bi = zeros([2 datasize(2) datasize(3)]);
FitMap = zeros(size(T2Map));
FitMap_bi = zeros(size(T2Map));
fitparams = zeros([2 size(T2Map)]);
fitparams_bi = zeros([3 size(T2Map)]);
T2MapSize = size(T2Map);

firstvol = squeeze(data(1,:,:));
[X,N] = hist(firstvol(:),(max(firstvol(:)) - min(firstvol(:))));
[~,maxap] = max(X);
zeroval = N(maxap);
tdata = data-zeroval;

if min(tdata(:))>0
    data = tdata;
end




disp('Computing biexponential T2 map... ');
% fun = @(x,xdata)x(1)*exp(-xdata./x(2)); % T2 decay function
fun = @(x,xdata)x(1)*exp(-xdata./x(2));
fun_bi = @(x,xdata)x(1)*exp(-xdata./x(2)) + (1-x(1))*exp(-xdata./x(3));
tic
parfor xv = 1:T2MapSize(1)*T2MapSize(2);
    %disp((xv/T2MapSize)*100)
    %         voxcounter = voxcounter + 1;
    %         textprogressbar((voxcounter/totalvox) * 100);
    % textprogressbar((xv/T2MapSize(1)^2)*100);
    if TheseVox(xv)
        
        signal = double(squeeze(data(:,xv)));
        
        
        xdata = TEmat(:);
        ydata = signal(:);
        
        xshift = 0;
        
        % fit monoexponential T2
        x0 = [500 10];
        
        [x, ~, res,~] = lsqcurvefit(fun,x0,xdata,ydata,[],[],opts);
        fitparams(:,xv) = x;
        T2Map(xv) = x(2) + xshift;
        
        FitMap(xv) = 1 - (sum(res.^2))/sum((mean(ydata) - ydata').^2);
        
        
        % fit biexponential T2
        
        x0 = [50 10 10];
        
        [x, ~, res,~] = lsqcurvefit(fun_bi,x0,xdata,ydata,[],[],opts);
        fitparams_bi(:,xv) = x;
        T2Map_bi(:,xv) = [x(2) x(3)];
        %T2Map_bi(2,xv) = x(3) + xshift;
        
        FitMap_bi(xv) = 1 - (sum(res.^2))/sum((mean(ydata) - ydata').^2);
        
    end
end

delete(gcp);