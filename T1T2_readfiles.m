function [data,TEmat,ITmat,TRmat,PVmat,FAmat,extraData,extraFA] = T1T2_readfiles(files,fileselection,sliceselection,NrOfSlices,doubleDataexists)

emptyfiles = [];
data = [];
TEmat = zeros(1,numel(files));
ITmat = zeros(1,numel(files));
TRmat = zeros(1,numel(files));
PVmat = zeros(1,numel(files));
FAmat = zeros(1,numel(files));
textprogressbar('Reading files... ');

ff = 1;
while ff <= numel(files)
    
    if fileselection(ff) %~mod(ff,sliceselection)
        header = dicominfo(files{ff},'UseDictionaryVR',true);
        
        
        if ~isempty(dicomread(char(files{ff})))
            data = cat(3,data,dicomread(char(files{ff})));
            
            
            try
                TEmat(ff) = header.EchoTime;
            end
            
            try
                TRmat(ff) = header.RepetitionTime;
            end
            
            try
                FAmat(ff) = header.FlipAngle;
            end
            
            try
                ITmat(ff) = header.InversionTime;
            end
            
            try
                RS = header.RescaleSlope;
            end
            
            try
                RI = header.RescaleIntercept;
            end
            
            try
                SS = header.Private_2005_100e;
            end
            
            try
                PVmat(ff) = typecast(header.Private_2005_1572,'single');
            end
            
        else
            %disp('Dicom file contains no data.');
            emptyfiles = [emptyfiles; ff];
        end
        skippedslices(ff) = 0;
        
        if ff + NrOfSlices - 1 < numel(files)
            ff = ff + NrOfSlices-1;
        else
            ff = numel(files);
        end
    end
    textprogressbar((ff/numel(files) * 100));
    ff = ff + 1;
    
end

if strfind(header.Manufacturer, 'Philips')
    % translate to ms resolution
    TEmat = fileselection * 1000;
    TRmat = TRmat * 1000;
end


textprogressbar(' ');

skippedslices(emptyfiles) = 1;

% delete empty files
TEmat(skippedslices==1) = [];
TRmat(skippedslices==1) = [];
ITmat(skippedslices==1) = [];
FAmat(skippedslices==1) = [];
PVmat(skippedslices==1) = [];

if doubleDataexists
    doubleData(skippedslices==1) = [];
    doubleData = find(doubleData==1);
end

% check for non-relevant dicoms
zTEmat = (TEmat==0);
zITmat = (ITmat==0);
zTRmat = (TRmat==0);
zPVmat = (PVmat==0);
zFAmat = (FAmat==0);

total = zTEmat + zITmat + zTRmat + zPVmat + zFAmat;

if any(total~=total(1))
    deleteDCM = total > min(total);
    disp(['Skipping ' num2str(sum(deleteDCM)) ' files.']);
    if size(data,3) == numel(deleteDCM)
        data(:,:,deleteDCM) = [];
    elseif size(data,3)~=sum(deleteDCM==0)
        error('Error in skipping irrelevant files: number of items do not match.');
    end
    TEmat(deleteDCM) = [];
    ITmat(deleteDCM) = [];
    TRmat(deleteDCM) = [];
    PVmat(deleteDCM) = [];
    FAmat(deleteDCM) = [];
end

data = double(permute(data,[3 1 2]));

if doubleDataexists % more than one sequence in data folder
    doubleData = doubleData(2:end);
    extraData = squeeze(data(doubleData,:,:));
    extraFA = FAmat(doubleData);
    data(doubleData,:,:) = [];
    
    TEmat(doubleData) = [];
    ITmat(doubleData) = [];
    TRmat(doubleData) = [];
    PVmat(doubleData) = [];
    FAmat(doubleData) = [];
end

% determine parameter of interest
if numel(TEmat) == numel(unique(TEmat))
   usedparameter = TEmat;
elseif numel(ITmat) == numel(unique(ITmat))
   usedparameter = ITmat;
elseif numel(TRmat) == numel(unique(TRmat))
   usedparameter = TRmat;
elseif numel(PVmat) == numel(unique(PVmat))
   usedparameter = PVmat;
elseif numel(FAmat) == numel(unique(FAmat))
   usedparameter = FAmat;
end


% manual data selection
OK = 0;
parameterrange = 1:size(data,1);
while ~OK
    parstr = [];
    for pp = 1:numel(parameterrange)
        parstr = [parstr num2str(parameterrange(pp)) '. (' num2str(usedparameter(parameterrange(pp))) 'ms) '];
    end
    
    commandwindow;
    disp(['Current parameter range: ' parstr]);
    v = input('Adapt selection if required (enter if OK): ','s');
    adaptedv = ['[' v ']'];
    
    if ~isempty(v)
        try
            parameterrange = eval(adaptedv);
        catch
            disp('Invalid entry.');
        end
        
    else
        OK = 1;
    end
    
end

data = data(parameterrange,:,:);
TEmat = TEmat(parameterrange);
ITmat = ITmat(parameterrange);
TRmat = TRmat(parameterrange);
PVmat = PVmat(parameterrange);
FAmat = FAmat(parameterrange);
