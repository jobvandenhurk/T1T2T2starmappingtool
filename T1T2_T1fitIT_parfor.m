function [T1Map,FitMap,fitparams,fun,data] = T1T2_T1fitIT_parfor(data,ITmat,TRmat,TheseVox,opts)

invertnegativesignal = 1; % from magnitude to real

datasize = size(data);
T1Map = zeros([datasize(2) datasize(3)]);
FitMap = zeros(size(T1Map));

fitIRparameter = 1;

if fitIRparameter
    fitparams = zeros([3 size(T1Map)]);
    fun = @(x,xdata) x(1) * (1 - x(3) * exp(-xdata./x(2)) + exp(-TRmat(1)./x(2))); % the x(3) = 2 presupposes a perfect symmetry along x axis.
else
    fun = @(x,xdata) x(1) * (1 - 2 * exp(-xdata./x(2)) + exp(-TRmat(1)./x(2))); % the 2 presupposes a perfect symmetry along x axis.
    fitparams = zeros([2 size(T1Map)]);
end

T1MapSize = size(T1Map);

firstvol = squeeze(data(1,:,:));
[X,N] = hist(firstvol(:),(max(firstvol(:)) - min(firstvol(:))));
[~,maxap] = max(X);
zeroval = N(maxap);
data = data-zeroval;

disp('Computing T1 map... ');
parfor xv = 1:T1MapSize(1) * T1MapSize(2)
    
    if TheseVox(xv)
        
        signal = double(squeeze(data(:,xv)));
        
        
        xdata = ITmat(:);
        
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
        data(:,xv) = ydata;

        
        if ~fitIRparameter
            %k * PD * (1 ? 2 * exp(-TI / T1) + exp(-TR / T1))
            
            %x0 = [-100 250 ];
            x0 = [0 100];
            % UB = [Inf 7500];
            % LB = [-Inf 100];
            UB = [];
            LB = [];
        else
            
            %x0 = [-100 250 2];
            x0 = [0 250 2];
            %                 UB = [Inf 7500 2];
            %                 LB = [-Inf 100 0];
            UB = [];
            LB = [];
        end
        
        %[x, resnorm, res,flag] = lsqcurvefit(fun,x0,xdata,ydata,T1lb,T1ub,opts);
        
        [x, resnorm, res,flag] = lsqcurvefit(fun,x0,xdata,ydata,LB,UB,opts);
        fitparams(:,xv) = x;
        
        T1Map(xv) = x(2);
        %T1Map(xv,yv) = 0.63*x(1);
        FitMap(xv) = 1 - (sum(res.^2))/sum((mean(ydata) - ydata').^2);
        
    end
end


