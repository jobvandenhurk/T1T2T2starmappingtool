function x0_optim = T1T2_optimizeinitialparameters(fun,x0,xdata,ydata,searchrange,opts)

% select the starting parameters to optimize (max 2)
optimization_ix = find(searchrange~=0);
nrofsearchsteps = 20;
x0_optim = x0;
if numel(optimization_ix) > 2
    warning('Maximum number of parameters for optimization exceeded! No optimization performed!')
    
    return
else
    params = zeros(numel(optimization_ix),nrofsearchsteps);
    if numel(optimization_ix) == 1
        params = linspace(x0(optimization_ix)-(searchrange(optimization_ix)),x0(optimization_ix)+(searchrange(optimization_ix)),nrofsearchsteps);
        results = zeros(1,nrofsearchsteps);
        
        currstep = 0;
        
        for xx = 1:nrofsearchsteps
            
        temp_x0 = x0;
                temp_x0(optimization_ix(1)) = params(1,xx);
                
                try
                    [x, resnorm, res,flag] = lsqcurvefit(fun,temp_x0,xdata,ydata,[],[],opts);
                    results(xx) = 1 - (sum(res.^2))/sum((mean(ydata) - ydata').^2);
                    
                    if results(xx)<0
                        results(xx)=0;
                    end
                    
                catch
                    results(xx) = nan;
                end
                %disp([xx yy])
            end
        
        [~,bestx] = max(results(:));
        
        x0_optim(optimization_ix(1)) = params(1,bestx);
        
    else
        params(1,:) = linspace(x0(optimization_ix(1))-(searchrange(optimization_ix(1))),x0(optimization_ix(1))+(searchrange(optimization_ix(1))),nrofsearchsteps);
        params(2,:) = linspace(x0(optimization_ix(2))-(searchrange(optimization_ix(2))),x0(optimization_ix(2))+(searchrange(optimization_ix(2))),nrofsearchsteps);
        results = zeros(nrofsearchsteps,nrofsearchsteps);
        totalsteps = nrofsearchsteps ^ 2;
        currstep = 0;
        
        for xx = 1:nrofsearchsteps
            for yy = 1:nrofsearchsteps
                
                currstep = currstep+1;
                
                temp_x0 = x0;
                temp_x0(optimization_ix(1)) = params(1,xx);
                temp_x0(optimization_ix(2)) = params(2,yy);
                try
                    [x, resnorm, res,flag] = lsqcurvefit(fun,temp_x0,xdata,ydata,[],[],opts);
                    results(xx,yy) = 1 - (sum(res.^2))/sum((mean(ydata) - ydata').^2);
                    
                    if results(xx,yy)<0
                        results(xx,yy)=0;
                    end
                    
                catch
                    results(xx,yy) = nan;
                end
                %disp([xx yy])
            end
        end
        [~,bestcell] = max(results(:));
        [bestx,besty] = ind2sub(size(results),bestcell);
        x0_optim(optimization_ix(1)) = params(1,bestx);
        x0_optim(optimization_ix(2)) = params(2,besty);
        
    end
    
end

