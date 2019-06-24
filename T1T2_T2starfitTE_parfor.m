function [T2Map,FitMap,fitparams,fun,data] = T1T2_T2starfitTE_parfor(data,TEmat,TRmat,TheseVox,opts)


datasize = size(data);
T2Map = zeros([datasize(2) datasize(3)]);
FitMap = zeros(size(T2Map));
fitparams = zeros([2 size(T2Map)]);
T2MapSize = size(T2Map);

firstvol = squeeze(data(1,:,:));
[X,N] = hist(firstvol(:),(max(firstvol(:)) - min(firstvol(:))));
[~,maxap] = max(X);
zeroval = N(maxap);
data = data-zeroval;
fun = @(x,xdata)x(1)*exp(-xdata./x(2)); % T2 decay function


textprogressbar('Computing T2* map... ');
parfor xv = 1:T2MapSize(1) * T2MapSize(2)
    
    if TheseVox(xv)
        
        signal = double(squeeze(data(:,xv,yv)));
        
        
        xdata = TEmat(:);
        ydata = signal(:);
        
        xshift = 0;
        %   fun = @(x,xdata)abs(x(1)*(1-exp(-xdata./x(2)))); % abs T1 relaxation function
        
        
        x0 = [500 10];
        %[x, resnorm, res,flag] = lsqcurvefit(fun,x0,xdata,ydata,T1lb,T1ub,opts);
        [x, resnorm, res,flag] = lsqcurvefit(fun,x0,xdata,ydata,[],[],opts);
        fitparams(:,xv) = x;
        T2Map(xv) = x(2) + xshift;
        
        FitMap(xv) = 1 - (sum(res.^2))/sum((mean(ydata) - ydata').^2);
    end
end
