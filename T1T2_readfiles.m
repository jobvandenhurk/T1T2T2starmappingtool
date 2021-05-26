function [data,TEmat,vTEmat,ITmat,TRmat,PVmat,FAmat,mappingtype,header,extraData,extraFA] = T1T2_readfiles(files,fileselection,sliceselection,NrOfSlices,doubleDataexists,useallslices)

emptyfiles = [];
data = [];
TEmat = zeros(1,numel(files));
vTEmat = zeros(1,numel(files));
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
                if strfind(header.ImageComments, 'TE [ms]:');
                    vTEmat(ff) = str2double(strrep(header.ImageComments, 'TE [ms]:', ''));
                else
                    vTEmat(ff) = -1;
                end
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
        
        if ~useallslices
            if ff + NrOfSlices - 1 < numel(files)
                ff = ff + NrOfSlices-1;
            else
                ff = numel(files);
            end
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
vTEmat(skippedslices==1) = [];
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
zvTEmat = (vTEmat==0);
zTEmat = (TEmat==0);
zITmat = (ITmat==0);
zTRmat = (TRmat==0);
zPVmat = (PVmat==0);
zFAmat = (FAmat==0);

total = zvTEmat + zTEmat + zITmat + zTRmat + zPVmat + zFAmat;

if any(total~=total(1))
    deleteDCM = total > min(total);
    %if ~useallslices
    disp(['Skipping ' num2str(sum(deleteDCM)) ' files.']);
    if size(data,3) == numel(deleteDCM)
        data(:,:,deleteDCM) = [];
    elseif size(data,3)~=sum(deleteDCM==0)
        error('Error in skipping irrelevant files: number of items do not match.');
    end
    %  end
    vTEmat(deleteDCM) = [];
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
    vTEmat(doubleData) = [];
    ITmat(doubleData) = [];
    TRmat(doubleData) = [];
    PVmat(doubleData) = [];
    FAmat(doubleData) = [];
end

% determine parameter of interest

if numel(TEmat)/NrOfSlices == numel(unique(TEmat))
    usedparameter = TEmat;
    par = 'T2/T2*';
    mappingtype = 'useTE';
elseif numel(vTEmat)/NrOfSlices == numel(unique(vTEmat))
    usedparameter = vTEmat;
    par = 'T2/T2*';
    mappingtype = 'usevTE';
    TEmat = vTEmat;
elseif numel(ITmat)/NrOfSlices == numel(unique(ITmat))
    usedparameter = ITmat;
    mappingtype = 'useIT';
    par = 'T1';
elseif numel(TRmat)/NrOfSlices == numel(unique(TRmat))
    usedparameter = TRmat;
    mappingtype = 'useTR';
    par = 'T1';
elseif numel(PVmat)/NrOfSlices == numel(unique(PVmat))
    usedparameter = PVmat;
    mappingtype = 'usePV';
    par = 'T1';
elseif numel(FAmat)/NrOfSlices == numel(unique(FAmat))
    usedparameter = FAmat;
    mappingtype = 'useFA';
    par = 'T1';
else
    error('Data not suitable for T1/T2/T2* mapping.');
end


% manual data selection
OK = 0;
parameterrange = 1:numel(unique(usedparameter));
uniqueparameters = unique(usedparameter);
while ~OK
    parstr = [];
    for pp = 1:numel(parameterrange)
        if ~strcmp(mappingtype,'useFA')
            parstr = [parstr num2str(parameterrange(pp)) '. (' num2str(uniqueparameters(parameterrange(pp))) 'ms) '];
        else
            parstr = [parstr num2str(parameterrange(pp)) '. (' num2str(uniqueparameters(parameterrange(pp))) 'deg) '];
            
        end
    end
    commandwindow;
    disp(['Current parameter range for ' par ' mapping :'  parstr]);
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

if ~useallslices
    data = data(parameterrange,:,:);
    %vTEmat = vTEmat(parameterrange);
    TEmat = TEmat(parameterrange);
    ITmat = ITmat(parameterrange);
    TRmat = TRmat(parameterrange);
    PVmat = PVmat(parameterrange);
    FAmat = FAmat(parameterrange);
    
    
else
    delthese = ones(1,size(data,1));
    
    for pp = 1:numel(parameterrange);
        delthese(((parameterrange(pp)-1) * (NrOfSlices) + 1):(parameterrange(pp)) * (NrOfSlices)) = 0;
    end
    % %         t = ones(1,numel(uniqueparameters));
    % %         t(parameterrange) = 0;
    % %         delthese(((pp-1)*numel(uniqueparameters)) + 1:((pp-1)*numel(uniqueparameters)) + numel(uniqueparameters)) = t;
    %     end
    
    
    data(delthese==1,:,:) = [];
    %vTEmat(delthese==1) = [];
    TEmat(delthese==1) = [];
    ITmat(delthese==1) = [];
    TRmat(delthese==1) = [];
    PVmat(delthese==1) = [];
    FAmat(delthese==1) = [];
end
