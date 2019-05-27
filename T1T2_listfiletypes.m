% ListFiletypes.m Job van den Hurk 2014 returns all files of a given
% extention in a particular folder
function [FileList, FileNames, FileSize] = ListFiletypes(StartFolder,extension,addfolder,matchextension)

if ~iscell(extension)
    extension = {extension};
end

tExtensions = extension;
if numel(tExtensions)>1
    extension = tExtensions(1);
end
FileList = {};
FileNames = {};
FileSize = [];
if ~exist(StartFolder,'dir')
    error(['Folder not found: ',StartFolder]);
else
    cd(StartFolder);
    FoundFiles = dir(StartFolder);
    dimension = size(FoundFiles);
    NrOfFiles = dimension(1);
    NrOfCorrFiles = 0;
    for currFile = 1:NrOfFiles;
        if strfind(FoundFiles(currFile).name,char(extension))
            
            if nargin < 4 || (~matchextension || strfind(FoundFiles(currFile).name,char(extension)) + length(char(extension)) ...
                    == length(FoundFiles(currFile).name)+1)
                
                NrOfCorrFiles = NrOfCorrFiles + 1;
                if nargin>2
                    if addfolder~=0
                        FileNames{NrOfCorrFiles} = FoundFiles(currFile).name;
                        FileList{NrOfCorrFiles} = [StartFolder '/' FoundFiles(currFile).name];
                        FileSize(NrOfCorrFiles) = FoundFiles(currFile).bytes;
                    else
                        FileList{NrOfCorrFiles} = FoundFiles(currFile).name;
                        FileSize(NrOfCorrFiles) = FoundFiles(currFile).bytes;
                    end
                else
                    FileList{NrOfCorrFiles} = FoundFiles(currFile).name;
                    FileNames{NrOfCorrFiles} = FoundFiles(currFile).name;
                    FileSize(NrOfCorrFiles) = FoundFiles(currFile).bytes;
                end
            end
        end
        
    end
end
FileList = FileList';
FileSize = FileSize';
FileNames = FileNames';

if numel(tExtensions)>1
    files = zeros(1,numel(FileList));
    for ff = 1:numel(FileList);
        for ee = 2:numel(tExtensions)
            if any(strfind(char(FileNames{ff}),char(tExtensions{ee})))
                files(ff) = 1;
            end
        end
    end
    
    files = ~files;
    FileList(files) = [];
    FileSize(files) = [];
    FileNames(files) = [];
    
end
