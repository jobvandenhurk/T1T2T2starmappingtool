function sortDICOMStofolders(sourcedir)

if nargin<1
    sourcedir = [uigetdir '/'];
    
end

%sourcedir = '/Users/Job/Documents/fMRI/Mammo T1T2/MAMMO_VRIJWILL_5/';
files = T1T2_listfiletypes(sourcedir,'.IMA');

prtnames = cell(numel(files),1);

textprogressbar('Sorting files... ');
for ff = 1:numel(files)
    textprogressbar(100*(ff/numel(files)));
    t = dicominfo(char(files{ff}));
    prtnames{ff} = t.ProtocolName;
end
disp(' ');
textprogressbar('Done')
disp(' ');

prtnames_unique = unique(prtnames);

serieslocs = zeros(1,numel(prtnames_unique));

for prtn = 1:numel(prtnames_unique)
    [~,serieslocs(prtn)] = ismember(char(prtnames_unique{prtn}),prtnames);
end

[serieslocs,sortorder] = sort(serieslocs);
prtnames_unique = prtnames_unique(sortorder);


% make new dirs and copy files

for prtn = 1:numel(prtnames_unique)
    
    if prtn<numel(prtnames_unique)
        seriesfilescount = serieslocs(prtn+1) - serieslocs(prtn);
    else
        seriesfilescount = numel(files) - serieslocs(prtn);
    end
    
    dirname = [sourcedir char(prtnames_unique{prtn}) '/'];
    mkdir(dirname);
    for ff = serieslocs(prtn):serieslocs(prtn)+seriesfilescount
        disp([char(files{ff}) ' -> ' dirname]);
        try
            copyfile([sourcedir char(files{ff})],dirname);
        catch
           
        end
    end
    
end

disp('Clearing up...');
for ff = 1:numel(files)
    delete([sourcedir char(files{ff})]);
    
end
