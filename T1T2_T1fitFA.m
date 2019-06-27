function [T1Map,FitMap,fitparams,fun,usedFAmat] = T1T2_T1fitFA(data,FAmat,TRmat,TheseVox,opts)


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
    [B1files, B1dir] = uigetfile({'*.dcm', 'BrainVoyager Dicom file (*.dcm)'; ...
        '*.IMA', 'Raw Dicom file (*.IMA)';...
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

totalvox = numel(T1Map);
voxcounter = 0;

if useLiberman
    textprogressbar('Computing T1 map by fitting Ernst equation (Liberman et al., 2014)... ');
    for xv = 1:T1MapSize(1)
        for yv = 1:T1MapSize(2)
            if CorrectFAUsingB1Map
                xdata = squeeze(xdatacorr(:,xv,yv));
            end
            voxcounter = voxcounter + 1;
            textprogressbar((voxcounter/totalvox) * 100);
            %textprogressbar((voxcounter/totalvox)*100);
            
            if TheseVox(xv,yv)
                
                signal = double(squeeze(data(:,xv,yv)));
                ydata = signal(:);
                
                % fun = @(x,xdata) (x(1).*((1-exp(-TRmat(1)./x(2))./(1-(cosd(xdata(:))).*(exp(-TRmat(1)./x(2))))))).*sind(xdata(:)); % Liberman 2014
                fun = @(x,xdata) (x(1) .* (1-exp(-TRmat(1)/x(2))) .* sind(xdata(:)))...
                    ./ (1-cosd(xdata(:)) .* exp(-TRmat(1)/x(2))); % Fram 1987
                
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
    textprogressbar(' ');
    
    %
    % elseif useLee
    %     disp('Computing T1 map using algebraic expression by Helms et al., 2008... ');
    %     %for aa = 1:numel(FAmat)-1
    %
    %     aa = 4;
    %     sFA = [aa numel(FAmat)]; % selected Flip Angles
    %
    %
    %     S1 = squeeze(data(sFA(1),:,:));
    %     S2 = squeeze(data(sFA(2),:,:));
    %     a1 = squeeze(xdatacorr(sFA(1),:,:));
    %     a2 = squeeze(xdatacorr(sFA(2),:,:));
    %     TR = TRmat(1);
    %
    %     T1Map = 2*TR*((S1./a1 - S2./a2) ./ (S2.*a2 - S1.*a1));
    %     T1Map(TheseVox==0) = 0;
    %     figure; imagesc(T1Map);colormap('jet');axis image;c = colorbar;c.Label.String = 'T1 (ms)'; title(['T1 Map with flip angles ' num2str(FAmat(sFA(1))) char(176) ' - ' num2str(FAmat(sFA(2))) char(176)]);caxis([0 2500]);
    %     drawnow;
    % end
end