function [ismultislice, sliceselection, NrOfSlices, doubleDataexists, fileselection] = T1T2_checkformultislicedata(files)

% first see if data is multislice or not:
textprogressbar('Reading headers to discover multislice information... ');
headerInstances = zeros(1,numel(files));
headerAcq = zeros(1,numel(files));
emptyfiles = [];
data = [];
TEmat = zeros(1,numel(files));
ITmat = zeros(1,numel(files));
TRmat = zeros(1,numel(files));
PVmat = zeros(1,numel(files));
FAmat = zeros(1,numel(files));



for ff = 1:numel(files)
    textprogressbar((ff/numel(files)) * 100);
    header = dicominfo(files{ff},'UseDictionaryVR',true);
    if ~isempty(dicomread(char(files{ff})))
        
        
        
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
        
    end
    
    try
        headerAcq(ff) = header.AcquisitionNumber;
    end
    
    try
        headerInstances(ff) = header.InstanceNumber;
    end
end
textprogressbar(' ');

AcqFreq = T1T2_vecFreq(headerAcq);
InsFreq = T1T2_vecFreq(headerInstances);




if AcqFreq(1,1) == 0
    AcqFreq(1,:) = [];
end




if size(AcqFreq,1) == 1
    NrOfSlices = 1;
else
    NrOfSlices = max(InsFreq(:,1));
end

% are there multiple sequences within this dataset?
if numel(unique(AcqFreq(:,2)))>1 && ~mod(max(AcqFreq(:,2)),min(AcqFreq(:,2)))
    doubleDataexists = 1;
    disp('This dataset seems to contain multiple sequences.');
    [~,doubleIx] = max(AcqFreq(:,2));
    doubleData = (headerAcq == AcqFreq(doubleIx,1));
else
    doubleDataexists = 0;
end


if NrOfSlices == 1
    % double check if header info makes slice detection impossible
    if numel(unique(TEmat))>1 && numel(unique(TEmat)) < numel(TEmat)
        TEfreq = T1T2_vecFreq(TEmat);
        if numel(unique(TEfreq(:,2))) == 1
            NrOfSlices = TEfreq(1,2);
            disp('Header slice count information does not match with TE parameter variation. Assuming multiple slices now...');
        else
            error('Can not detect correct slice count! Contact J.vandenhurk@scannexus.nl!');
        end
    elseif numel(unique(TRmat))>1 && numel(unique(TRmat)) < numel(TRmat)
        TRfreq = T1T2_vecFreq(TEmat);
        if numel(unique(TRfreq(:,2))) == 1
            NrOfSlices = TRfreq(1,2);
            disp('Header slice count information does not match with TR parameter variation. Assuming multiple slices now...');
        else
            error('Can not detect correct slice count! Contact J.vandenhurk@scannexus.nl!');
        end
    elseif numel(unique(ITmat))>1 && numel(unique(ITmat)) < numel(ITmat)
        ITfreq = T1T2_vecFreq(TEmat);
        if numel(unique(ITfreq(:,2))) == 1
            NrOfSlices = ITfreq(1,2);
            disp('Header slice count information does not match with IT parameter variation. Assuming multiple slices now...');
        else
            error('Can not detect correct slice count! Contact J.vandenhurk@scannexus.nl!');
        end
    elseif numel(unique(PVmat))>1 && numel(unique(PVmat)) < numel(PVmat)
        PVfreq = T1T2_vecFreq(TEmat);
        if numel(unique(PVfreq(:,2))) == 1
            NrOfSlices = PVfreq(1,2);
            disp('Header slice count information does not match with IT (private header) parameter variation. Assuming multiple slices now...');
        else
            error('Can not detect correct slice count! Contact J.vandenhurk@scannexus.nl!');
        end
        
    elseif numel(unique(FAmat))>1 && numel(unique(FAmat)) < numel(FAmat)
        FAfreq = T1T2_vecFreq(TEmat);
        if numel(unique(FAfreq(:,2))) == 1
            NrOfSlices = FAfreq(1,2);
            disp('Header slice count information does not match with FA parameter variation. Assuming multiple slices now...');
        else
            error('Can not detect correct slice count! Contact J.vandenhurk@scannexus.nl!');
        end
    end
    
end



if NrOfSlices > 1
    disp(['Data seems to contain ' num2str(NrOfSlices) ' slices.']);
    sliceselection = round(NrOfSlices/2);
    OK = 0;
    
    while ~OK
        usethisslice = input(['Picking slice (' num2str(sliceselection) ') for analysis. Choose another slice if wanted, or Enter to continue... '],'s');
        
        if ~isempty(usethisslice)
            
            
            if isnan(str2double(usethisslice))
                disp('Invalid value. Please try again.');
            else
                
                if str2double(usethisslice) > 0 && str2double(usethisslice) <  NrOfSlices
                    sliceselection = round(str2double(usethisslice));
                    OK = 1;
                else
                    disp('Slice selection out of range. Please try again.');
                end
            end
        else
            OK = 1;
        end
    end
    ismultislice = 1;
else
    disp('Data seems to contain single slice.');
    sliceselection = 1;
    ismultislice = 0;
end

fileselection = zeros(1,numel(files));
for ii = 1:NrOfSlices:numel(files)
    fileselection(ii+sliceselection-1) = 1;
end