function [T1Map,FitMap,fitparams,fun,usedFAmat] = T1T2_T1fitIT_PV_TR(data,ITmat,TRmat,PVmat,TheseVoxels,opts)

NormalizeDataToZero = 0;
invertnegativesignal = 1; % from magnitude to real

if useIT || usePV
    firstvol = squeeze(data(1,:,:));
    [X,N] = hist(firstvol(:),(max(firstvol(:)) - min(firstvol(:))));
    [~,maxap] = max(X);
    zeroval = N(maxap);
    data = data-zeroval;
    
    fitIRparameter = 1;
    
end

totalvox = numel(T1Map);
voxcounter = 0;
textprogressbar('Computing T1 map... ');
for xv = 1:T1MapSize(1)
    for yv = 1:T1MapSize(2)
        voxcounter = voxcounter + 1;
        textprogressbar((voxcounter/totalvox) * 100);
        %textprogressbar((voxcounter/totalvox)*100);
        if TheseVox(xv,yv)
            
            signal = double(squeeze(data(:,xv,yv)));
            
            if useTR
                xdata = TRmat(:);
            elseif useIT
                xdata = ITmat(:);
            elseif usePV
                xdata = PVmat(:);
            end
            
            
            % invert signal for IR or PV
            if useIT || usePV
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
                    
                    signal(1:beforenull) = -signal(1:beforenull);
                    % signal = signal+abs(min(signal)) + 1;
                end
            end
            ydata = signal(:);
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
            
            if useTR
                fun = @(x,xdata) (x(1).*(1-exp(-xdata./x(2)))); % T1 for TR relaxation function
            elseif useIT || usePV
                
                if ~fitIRparameter
                    %k * PD * (1 ? 2 * exp(-TI / T1) + exp(-TR / T1))
                    fun = @(x,xdata) x(1) * (1 - 2 * exp(-xdata./x(2)) + exp(-TRmat(1)./x(2))); % the 2 presupposes a perfect symmetry along x axis.
                    %x0 = [-100 250 ];
                    x0 = [0 250 ];
                    LB = [-Inf 0];
                    UB = [Inf 15000];
                else
                    fun = @(x,xdata) x(1) * (1 - x(3) * exp(-xdata./x(2)) + exp(-TRmat(1)./x(2))); % the x(3) = 2 presupposes a perfect symmetry along x axis.
                    %x0 = [-100 250 2];
                    x0 = [0 250 2];
                    LB = [-Inf 0 1];
                    UB = [Inf 15000 2];
                end
            end
            %[x, resnorm, res,flag] = lsqcurvefit(fun,x0,xdata,ydata,T1lb,T1ub,opts);
            
            [x, resnorm, res,flag] = lsqcurvefit(fun,x0,xdata,ydata,LB,UB,opts);
            
            
            T1Map(xv,yv) = x(2) + xshift;
            %T1Map(xv,yv) = 0.63*x(1);
            FitMap(xv,yv) = 1 - (sum(res.^2))/sum((mean(ydata) - ydata').^2);
            
            
        end
    end
end
textprogressbar(' ');

