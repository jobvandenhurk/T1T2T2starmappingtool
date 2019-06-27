function [T1Map,FitMap,fitparams,fun,usedFAmat] = T1T2_T1fitFA_parfor(data,FAmat,TRmat,TheseVox,opts)


useLiberman = 1;
useLee = 0;
datasize = size(data);
T1Map = zeros([datasize(2) datasize(3)]);
FitMap = zeros(size(T1Map));
usedFAmat = zeros([numel(FAmat) size(T1Map)]);
fitparams = zeros([2 size(T1Map)]);
T1MapSize = size(T1Map);
converttoradian = useLee;

cont = 0;
while ~cont
    disp('Select files for B1 map (cancel for T1 fitting without B1-correction)');
    [B1files, B1dir] = uigetfile({'*.IMA', 'Raw Dicom file (*.IMA)';'*.dcm', 'BrainVoyager Dicom file (*.dcm)';...
        '*.*', 'Any file'}, 'MultiSelect', 'on');
    if ~B1dir
        B1 = nan;
        CorrectFAUsingB1Map = 0; % default: 1
        cont = 1;
    else
        cd(B1dir);
        if iscell(B1files)
            B1 = dicomread(char(B1files{sliceselection}));
        else
            B1 = dicomread(B1files);
        end
        
        CorrectFAUsingB1Map = 1; % default: 1
        
        % resize image
        disp('Rescaling B1 image to match FA data...');
        
        TargetResolution = datasize(2:3);
        B1 = imresize(B1, TargetResolution, 'lanczos3');
        B1 = double(B1)./10;
        B1corrmap = (B1./90);
        
        figure(5); imagesc(B1);axis image;colormap('gray');colorbar;title('B1 map');
        drawnow;
        
        v = input('Continue with this B1-map (y/n) (Enter to proceed): ','s');
        if ~strcmp(v,'n')
            cont = 1;
        end
    end
end



xdata = repmat(FAmat,[size(B1,1),1,size(B1,2)]);
xdata = permute(xdata,[2 1 3]);
xdatacorr = zeros(size(xdata));

% fun = @(x,xdata) (x(1).*((1-exp(-TRmat(1)./x(2))./(1-(cosd(xdata(:))).*(exp(-TRmat(1)./x(2))))))).*sind(xdata(:)); % Liberman 2014
fun = @(x,xdata) (x(1) .* (1-exp(-TRmat(1)/x(2))) .* sind(xdata(:)))...
    ./ (1-cosd(xdata(:)) .* exp(-TRmat(1)/x(2))); % Fram 1987

if CorrectFAUsingB1Map
    % correct FA values based on images
    
    disp('Correcting nominal flip angles...');
    for ff = 1:numel(FAmat)
        xdatacorr(ff,:,:) = squeeze(xdata(ff,:,:)) .* B1corrmap;
        %figure;imagesc(squeeze(xdatacorr(ff,:,:)));axis image;caxis([0 90]);title(['FA ' num2str(squeeze(xdata(ff,1,1)))]);
    end
else
    disp('Continuing with uncorrected (nominal) flip angles...');
    xdatacorr = xdata;
end

if converttoradian;
    % degree to radians
    xdatacorr = xdatacorr .* (pi/180);
end


if useLiberman
    disp('Computing T1 map by fitting Ernst equation (Liberman et al., 2014)... ');
    parfor xv = 1:T1MapSize(1) * T1MapSize(2)
        %for xv = 1:T1MapSize(1) * T1MapSize(2)
        % for yv = 1:T1MapSize(2)
        %         if CorrectFAUsingB1Map
        %             xdata = squeeze(xdatacorr(:,xv));
        %         end
        
        if TheseVox(xv)
            
            signal = double(squeeze(data(:,xv)));
            ydata = signal(:);
            
            
            
            x0 = [1 1];
            if CorrectFAUsingB1Map
                [x, resnorm, res,flag] = lsqcurvefit(fun,x0,xdatacorr(:,xv),ydata,[],[],opts);
                usedFAmat(:,xv) = xdatacorr(:,xv);
            else
                [x, resnorm, res,flag] = lsqcurvefit(fun,x0,xdata,ydata,[],[],opts);
                usedFAmat(:,xv) = xdata;
            end
            fitparams(:,xv) = x;
            
            T1Map(xv) = x(2);
            FitMap(xv) = 1 - (sum(res.^2))/sum((mean(ydata) - ydata').^2);
        end
    end
end
