function mappingtype = T1T2_checkmappingtype(TEmat,ITmat,TRmat,PVmat,FAmat,doubleDataexists)


% decide which parameter to use (which vector has only unique values?)
if numel(unique(TEmat)) == numel(TEmat)
    if TRmat(1) > 900
        disp('Data suitable for T2 mapping: using TE');
        
        mappingtype = 'useTE';
    else
        disp('Data suitable for T2* mapping: using TE');
        
        mappingtype = 'useTEstar';
    end
elseif numel(unique(TRmat)) == numel(TRmat)
    disp('Data suitable for T1 mapping: using TR');
    mappingtype = 'useTR';
elseif numel(unique(ITmat)) == numel(ITmat)
    disp('Data suitable for T1 mapping: using Inversion Recovery');
    mappingtype = 'useIT';
elseif numel(unique(PVmat)) == numel(PVmat)
    disp('Data suitable for T1 mapping: using Inversion Time from Private Header');
    mappingtype = 'usePV';
elseif numel(unique(FAmat)) > 1;
    disp('Data suitable for T1 mapping: using Variable Flip Angle');
    mappingtype = 'useFA';
    if doubleDataexists
        disp('B1 map found for flip angle correction.');
    end
else
    disp('Data not suitable for T1, T2 or T2* mapping.');
    mappingtype = [];
    return
end