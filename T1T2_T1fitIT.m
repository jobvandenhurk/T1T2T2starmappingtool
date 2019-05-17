function [T1Map,FitMap,fitparams,fun,data] = T1T2_T1fitIT(data,ITmat,TRmat,TheseVox,opts)

NormalizeDataToZero = 0;
invertnegativesignal = 1; % from magnitude to real

datasize = size(data);
T1Map = zeros([datasize(2) datasize(3)]);
FitMap = zeros(size(T1Map));

fitIRparameter = 1;

if fitIRparameter
    fitparams = zeros([3 size(T1Map)]);
else
    fitparams = zeros([2 size(T1Map)]);
end
T1MapSize = size(T1Map);

firstvol = squeeze(data(1,:,:));
[X,N] = hist(firstvol(:),(max(firstvol(:)) - min(firstvol(:))));
[~,maxap] = max(X);
zeroval = N(maxap);
data = data-zeroval;





totalvox = numel(T1Map);
voxcounter = 0;
textprogressbar('Computing T1 map... ');
for xv = 1:T1MapSize(1)
    for yv = 1:T1MapSize(2)
        
        if xv==155 && yv==120
           t = 1; 
        end
        voxcounter = voxcounter + 1;
        textprogressbar((voxcounter/totalvox) * 100);
        %textprogressbar((voxcounter/totalvox)*100);
        if TheseVox(xv,yv)
            
            signal = double(squeeze(data(:,xv,yv)));
            
            
            xdata = ITmat(:);
            
            if xv == 85
                t = 1;
            end
            
            % invert signal for IR or PV
            
            if invertnegativesignal
                % NormalizeDataToZero = invertnegativesignal;
                neg = Derivative(signal) < 0;
                beforenull = 0;
                for ii = 1:numel(neg)
                    if neg(ii)
                        beforenull = ii;
                    else
                        break
                    end
                    beforenull = beforenull + 1;
                end
                if beforenull
                    signal(1:beforenull) = -signal(1:beforenull);
                    signal_alt = signal;
                    signal_alt(beforenull) = -signal(beforenull);
                    signal = signal_alt;
                end
            end
            ydata = signal(:);
            data(:,xv,yv) = ydata;
            %NormalizeDataToZero = usePV;
            if NormalizeDataToZero
                ydata = ydata - min(ydata);
                if xdata(1) >0
                    xshift = min(xdata);
                    xdata = xdata - min(xdata);
                end
                x0 = [0 500];
            else
                x0 = [500 500];
                xshift = 0;
            end
            %   fun = @(x,xdata)abs(x(1)*(1-exp(-xdata./x(2)))); % abs T1 relaxation function
            
            
            if ~fitIRparameter
                %k * PD * (1 ? 2 * exp(-TI / T1) + exp(-TR / T1))
                fun = @(x,xdata) x(1) * (1 - 2 * exp(-xdata./x(2)) + exp(-TRmat(1)./x(2))); % the 2 presupposes a perfect symmetry along x axis.
                %x0 = [-100 250 ];
                x0 = [0 100];
                % UB = [Inf 7500];
                % LB = [-Inf 100];
                UB = [];
                LB = [];
            else
                fun = @(x,xdata) x(1) * (1 - x(3) * exp(-xdata./x(2)) + exp(-TRmat(1)./x(2))); % the x(3) = 2 presupposes a perfect symmetry along x axis.
                %x0 = [-100 250 2];
                x0 = [0 250 2];
                %                 UB = [Inf 7500 2];
                %                 LB = [-Inf 100 0];
                UB = [];
                LB = [];
            end
            
            %[x, resnorm, res,flag] = lsqcurvefit(fun,x0,xdata,ydata,T1lb,T1ub,opts);
            
            [x, resnorm, res,flag] = lsqcurvefit(fun,x0,xdata,ydata,LB,UB,opts);
            fitparams(:,xv,yv) = x;
            
            T1Map(xv,yv) = x(2) + xshift;
            %T1Map(xv,yv) = 0.63*x(1);
            FitMap(xv,yv) = 1 - (sum(res.^2))/sum((mean(ydata) - ydata').^2);
            if FitMap(xv,yv) < 0.85
%                 disp(['Optimizing initial parameters for voxel [' num2str(xv) ',' num2str(yv) ']...']);
%                 
%                 x0_optim = T1T2_optimizeinitialparameters(fun,x0,xdata,ydata,[0 250 0],opts);
%                 [x, resnorm, res,flag] = lsqcurvefit(fun,x0_optim,xdata,ydata,LB,UB,opts);
%                 x0 = x0_optim;
%                 disp(['G-o-F before optimalization: ' num2str(FitMap(xv,yv)) ', after: ' num2str(1 - (sum(res.^2))/sum((mean(ydata) - ydata').^2)) '.']);
% 
%                 
            end
            
        end
    end
end
textprogressbar(' ');

