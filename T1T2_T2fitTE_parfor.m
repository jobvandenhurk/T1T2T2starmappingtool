function [T2Map,FitMap,fitparams,fun,data] = T1T2_T2fitTE_parfor(data,TEmat,TRmat,TheseVox,opts)


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




disp('Computing T2 map... ');
fun = @(x,xdata)x(1)*exp(-xdata./x(2)); % T2 decay function

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
        %   fun = @(x,xdata)abs(x(1)*(1-exp(-xdata./x(2)))); % abs T1 relaxation function
        
        
        x0 = [500 10];
        
        [x, resnorm, res,flag] = lsqcurvefit(fun,x0,xdata,ydata,[],[],opts);
        fitparams(:,xv) = x;
        T2Map(xv) = x(2) + xshift;
        %T1Map(xv,yv) = 0.63*x(1);
        FitMap(xv) = 1 - (sum(res.^2))/sum((mean(ydata) - ydata').^2);
        
    end
end
toc
delete(gcp);