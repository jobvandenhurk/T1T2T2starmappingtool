function [T2Map,FitMap,fitparams,fun,data] = T1T2_T2fitTE(data,TEmat,TRmat,TheseVox,opts)


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


totalvox = numel(T2Map);
voxcounter = 0;

textprogressbar('Computing T2 map... ');
for xv = 1:T2MapSize(1)
    for yv = 1:T2MapSize(2)
        voxcounter = voxcounter + 1;
        textprogressbar((voxcounter/totalvox) * 100);
        %textprogressbar((voxcounter/totalvox)*100);
        if TheseVox(xv,yv)
            
            signal = double(squeeze(data(:,xv,yv)));
            
            
            xdata = TEmat(:);
            ydata = signal(:);
            
            xshift = 0;
            %   fun = @(x,xdata)abs(x(1)*(1-exp(-xdata./x(2)))); % abs T1 relaxation function
            fun = @(x,xdata)x(1)*exp(-xdata./x(2)); % T2 decay function
            
            x0 = [500 10];
            %[x, resnorm, res,flag] = lsqcurvefit(fun,x0,xdata,ydata,T1lb,T1ub,opts);
            [x, resnorm, res,flag] = lsqcurvefit(fun,x0,xdata,ydata,[],[],opts);
            fitparams(:,xv,yv) = x;
            T2Map(xv,yv) = x(2) + xshift;
            %T1Map(xv,yv) = 0.63*x(1);
            FitMap(xv,yv) = 1 - (sum(res.^2))/sum((mean(ydata) - ydata').^2);
        end
    end
end
