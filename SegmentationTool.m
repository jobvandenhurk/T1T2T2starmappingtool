function varargout = SegmentationTool(varargin)
% SegmentationTool V1.1 by Job van den Hurk, 2019
% SEGMENTATIONTOOL MATLAB code for SegmentationTool.fig
%      SEGMENTATIONTOOL, by itself, creates a new SEGMENTATIONTOOL or raises the existing
%      singleton*.
%
%      H = SEGMENTATIONTOOL returns the handle to a new SEGMENTATIONTOOL or the handle to
%      the existing singleton*.
%
%      SEGMENTATIONTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENTATIONTOOL.M with the given input arguments.
%
%      SEGMENTATIONTOOL('Property','Value',...) creates a new SEGMENTATIONTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SegmentationTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SegmentationTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SegmentationTool

% Last Modified by GUIDE v2.5 18-Mar-2020 12:17:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SegmentationTool_OpeningFcn, ...
    'gui_OutputFcn',  @SegmentationTool_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SegmentationTool is made visible.
function SegmentationTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SegmentationTool (see VARARGIN)

% Choose default command line output for SegmentationTool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
movegui(gcf,'center')

set(handles.pushbutton2,'enable','off');
set(handles.pushbutton3,'enable','off');
set(handles.pushbutton4,'enable','off');
set(handles.checkbox1,'enable','off');
set(handles.checkbox2,'enable','off');

axes(handles.axes1);
axis off
axes(handles.axes2);
axis off
axes(handles.axes3);
axis off
axes(handles.axes4);
axis off

% UIWAIT makes SegmentationTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SegmentationTool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%clear all
handles.meanmap = [];
handles.tmask = [];
handles.data = [];
handles.tdata = [];
handles.est_par = [];
handles.maxval = [];
handles.map = [];
handles.currslice = 1;
handles.nrofslices = [];
handles.anatomyintensity = [0 1000];
%


[file, dir] = uigetfile({'.mat','Matlab file';'.ima','Dicom file'},'Multiselect','on');
file = sort(file(:));
handles.filename = char(file{1});
handles.dir = dir;
if ~isempty(dir)
    [~,~,ext] = fileparts(char(file{1}));
    fp = 0;
    handles.nrofslices = 0;
    if strcmp(ext,'.IMA') ||...
            strcmp(ext,'.ima')
        
        dcminfo = dicominfo([dir char(file{1})]);
        
        if strfind(dcminfo.ProtocolName,'IRFF')
            fp = 1;
        end
    end
    % clear figures
    axes(handles.axes1);
    cla reset
    axes(handles.axes2);
    cla reset
    axes(handles.axes3);
    cla reset
    axes(handles.axes4);
    cla reset
    tdata = [];
    tmap = [];
    t2map = [];
    if ~fp % no fingerprinting dicoms
        fileix = zeros(1,numel(file));
        for ff = 1:numel(file)
            tfile = char(file{ff});
            usix = strfind(tfile,'_');
            fileix(ff) = str2double(tfile((usix(3)+1):(usix(4)-1)));
        end
        [~,sfileix] = sort(fileix);
        file = file(sfileix);
        
        
        %file = sort(file);
        % file = 'T2_mappingresults_slice_9_28-Jun-2019.mat';
        % dir = '/Users/Job/Documents/fMRI/Mammo T1T2/_MAMMO_VRIJWILLIGER4/T2 se_mc_8contrast_9 slices_TR1500/';
        
        if iscell(file)
            multislice = 1;
            for ff = 1:numel(file)
                load([dir char(file{ff})]);
                tmap = cat(3,tmap,map);
                tdata = cat(3,tdata,squeeze(data(1,:,:)));
            end
            map = permute(tmap,[3 1 2]);
            data = permute(tdata,[3 1 2]);
        else
            %multislice = 0;
            load([dir file]);
            tmap = map;
            tdata = data;
        end
    else % if fingerprinting
        for ff = 1:numel(file)
            dcminfo = dicominfo([dir char(file{ff})]);
            try
                est_par = 'T1';
                if strfind(dcminfo.ImageComments,'PD')
                    tdata = cat(3,tdata,double(dicomread([dir char(file{ff})])));
                    handles.nrofslices = handles.nrofslices + 1;
                elseif strfind(dcminfo.ImageComments,'T1 Map')
                    tmap = cat(3,tmap,double(dicomread([dir char(file{ff})])));
                elseif strfind(dcminfo.ImageComments,'T2 Map')
                    t2map = cat(3,t2map,double(dicomread([dir char(file{ff})])));
                end
                
                
            catch
                % no imagecomments
            end
        end
        t1map = tmap;
    end
    set(handles.pushbutton2,'enable','on');
    set(handles.pushbutton3,'enable','on');
    set(handles.pushbutton4,'enable','on');
    set(handles.checkbox1,'enable','on');
    if fp
        set(handles.checkbox2,'enable','on');
    else
        set(handles.checkbox2,'enable','off');
    end
    
    handles.currslice = 1;
    if ~fp
        handles.nrofslices = numel(file);
    end
    handles.NrOfBins = 25;
    handles.meanmap = [];
    set(handles.text2,'String',num2str(handles.currslice));
    
    
    map = squeeze(tmap(:,:,handles.currslice));
    data = squeeze(tdata(:,:,handles.currslice));
    handles.tmask = zeros(size(tmap));
    map(isnan(map)) = 0;
    handles.map = map;
    
    if strcmp(est_par,'T2')
        if fp
            handles.maxval = 500;
        else
            handles.maxval = 200;
        end
        map(map>500) = 0;
        handles.t2map = t2map;
    elseif strcmp(est_par,'T1')
        if fp
            handles.maxval = 1500;
        else
            handles.maxval = 3000;
        end
        map(map>5000) = 0;
        handles.t1map = t1map;
    end
    
    % Quantitative map
    axes(handles.axes2);
    m = imagesc(map);
    axis image;colormap(handles.axes2,'jet');colorbar;caxis([0 handles.maxval]);
    axis off;
    %m.Parent = handles.axes2;
    
    
    % Anatomical image
    axes(handles.axes1)
    a = imagesc(squeeze(data));
    %a.Parent = handles.axes1;
    axis image;colormap(handles.axes1,'bone');colorbar;caxis(handles.anatomyintensity);
    axis off;
    handles.est_par = est_par;
    handles.tdata = tdata;
    handles.tmap = tmap;
    
    
    
    guidata(hObject,handles);
end

% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


meanmap = handles.meanmap;

%    inputkey = '';
%     while ~strcmp(inputkey,'enter')
%         set(dfig,'KeyPressFcn',@(h_obj,evt) disp(evt.Key));
%         %set(dfig,'KeyPressFcn',@(H,E) assignin('base','inputkey',E.Key));
%       %  disp(inputkey)
%     end
%set(dfig,'KeyPressFcn',@(h_obj,evt) disp(evt.Key));
axes(handles.axes1);

roi = roipoly;


% draw ROI in figure




axes(handles.axes2);
m = imagesc(handles.tmap(:,:,handles.currslice));
axis image;colormap(handles.axes2,'jet');colorbar;caxis([0 handles.maxval]);
axis off;


hold on
map = handles.map;
mask = handles.tmask(:,:,handles.currslice);

mask(roi==1) = 0.6;
handles.tmask(:,:,handles.currslice) = mask;


white = cat(3,ones(size(map)),ones(size(map)),ones(size(map)));
mm = imshow(white);
set(mm,'AlphaData',mask);
hold off


axes(handles.axes3);



plotdata = map(roi==1);
meanmap = [meanmap; plotdata(plotdata>0)];
[h,n]= hist(plotdata(plotdata>0),handles.NrOfBins);

plot(n,h);
xlabel([handles.est_par ' (ms)']);
ylabel('Voxel count');
title(['Mean ' handles.est_par ' value: ' num2str(mean(map(roi==1),'omitnan')) ' ms']);
%xlim([0 max(h)]);




MaxVal = 200;
map(isnan(map)) = 0;

if strcmp(handles.est_par,'T2')
    map(map>500) = 0;
elseif strcmp(handles.est_par,'T1')
    map(map>5000) = 0;
end


[h,n]= hist(meanmap,handles.NrOfBins);
axes(handles.axes4);
plot(n,h);
xlabel([handles.est_par ' (ms)']);
ylabel('Voxel count');
title(['Mean ' handles.est_par ' value across selected ROIs: ' num2str(mean(meanmap(:),'omitnan')) ' ms']);
xlim([0 handles.maxval]);

handles.meanmap = meanmap;


if get(handles.checkbox1,'Value') == 1
    axes(handles.axes1);
    a = imagesc(squeeze(handles.tdata(:,:,handles.currslice)));
    axis image;colormap(handles.axes1,'bone');colorbar;caxis(handles.anatomyintensity);
    axis off
    mask = handles.tmask(:,:,handles.currslice);
    map = handles.map;
    %mask(roi==1) = 0.6;
    %handles.tmask(:,:,handles.currslice) = mask;
    
    
    red = cat(3,ones(size(map)),zeros(size(map)),zeros(size(map)));
    hold on
    mm = imshow(red);
    set(mm,'AlphaData',mask);
    hold off
end


guidata(hObject,handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.currslice+1 > handles.nrofslices
    handles.currslice = handles.nrofslices;
else
    handles.currslice = handles.currslice + 1;
end

handles.map = squeeze(handles.tmap(:,:,handles.currslice));
handles.data = squeeze(handles.tdata(:,:,handles.currslice));


% Quantitative map
axes(handles.axes2);
m = imagesc(handles.tmap(:,:,handles.currslice));
set(handles.text2,'String',num2str(handles.currslice));

axis image;colormap(handles.axes2,'jet');colorbar;caxis([0 handles.maxval]);
axis off

hold on
map = handles.map;
mask = handles.tmask(:,:,handles.currslice);

%mask(roi==1) = 0.6;
handles.tmask(:,:,handles.currslice) = mask;


white = cat(3,ones(size(map)),ones(size(map)),ones(size(map)));
mm = imshow(white);
set(mm,'AlphaData',mask);
hold off


% Anatomical image
axes(handles.axes1)
a = imagesc(squeeze(handles.data));
axis image;colormap(handles.axes1,'bone');colorbar;caxis(handles.anatomyintensity);
axis off

if get(handles.checkbox1,'Value') == 1
    %handles.data = squeeze(handles.tdata(:,:,handles.currslice));
    mask = handles.tmask(:,:,handles.currslice);
    map = handles.map;
    %mask(roi==1) = 0.6;
    %handles.tmask(:,:,handles.currslice) = mask;
    
    
    red = cat(3,ones(size(map)),zeros(size(map)),zeros(size(map)));
    hold on
    mm = imshow(red);
    set(mm,'AlphaData',mask);
    hold off
end



guidata(hObject,handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.currslice-1 < 1
    handles.currslice = 1;
else
    handles.currslice = handles.currslice - 1;
end

handles.map = squeeze(handles.tmap(:,:,handles.currslice));
handles.data = squeeze(handles.tdata(:,:,handles.currslice));
handles.map(isnan(handles.map)) = 0;

% Quantitative map
axes(handles.axes2);
m = imagesc(handles.map);
set(handles.text2,'String',num2str(handles.currslice));

axis image;colormap(handles.axes2,'jet');colorbar;caxis([0 handles.maxval]);
axis off

hold on
map = handles.map;
mask = handles.tmask(:,:,handles.currslice);

%mask(roi==1) = 0.6;
handles.tmask(:,:,handles.currslice) = mask;


white = cat(3,ones(size(map)),ones(size(map)),ones(size(map)));
mm = imshow(white);
set(mm,'AlphaData',mask);
hold off


% Anatomical image
axes(handles.axes1)
a = imagesc(squeeze(handles.data));
axis image;colormap(handles.axes1,'bone');colorbar;caxis(handles.anatomyintensity);
axis off



if get(handles.checkbox1,'Value') == 1
    %handles.data = squeeze(handles.tdata(:,:,handles.currslice));
    mask = handles.tmask(:,:,handles.currslice);
    map = handles.map;
    %mask(roi==1) = 0.6;
    %handles.tmask(:,:,handles.currslice) = mask;
    
    
    red = cat(3,ones(size(map)),zeros(size(map)),zeros(size(map)));
    hold on
    mm = imshow(red);
    set(mm,'AlphaData',mask);
    hold off
end



guidata(hObject,handles);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

axes(handles.axes1);

if get(hObject,'Value') == 1
    %handles.data = squeeze(handles.tdata(:,:,handles.currslice));
    mask = handles.tmask(:,:,handles.currslice);
    map = handles.map;
    %mask(roi==1) = 0.6;
    %handles.tmask(:,:,handles.currslice) = mask;
    
    
    red = cat(3,ones(size(map)),zeros(size(map)),zeros(size(map)));
    hold on
    mm = imshow(red);
    set(mm,'AlphaData',mask);
    hold off
else
    axes(handles.axes1)
    a = imagesc(squeeze(handles.tdata(:,:,handles.currslice)));
    axis image;colormap(handles.axes1,'bone');colorbar;caxis(handles.anatomyintensity);
    axis off
end

guidata(hObject,handles);


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cd(handles.dir);
filedef = handles.filename;
filedef(min(strfind(filedef,'_')):end) = [];
filedef = [filedef '_' num2str(handles.nrofslices) 'sl_segmentation.mat'];
[file,dir] = uiputfile({'*.mat','MATLAB File'},'Select file location',filedef);
if ~file==0
    meanmap = handles.meanmap;
    tmask = handles.tmask;
    firstfilename = handles.filename;
    tdata = handles.tdata;
    tmap = handles.tmap;
    disp(['Saving data to file ' file]);
    est_par = handles.est_par;
    maxval = handles.maxval;
    save([dir file], 'meanmap','tmask','firstfilename','tdata','tmap','est_par','maxval');
end


% --------------------------------------------------------------------
function uipushtool2_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, dir] = uigetfile({'*.mat','MATLAB File'});

if ~file==0
    handles.meanmap = [];
    handles.tmask = [];
    handles.data = [];
    handles.tdata = [];
    handles.est_par = [];
    handles.maxval = [];
    handles.map = [];
    handles.currslice = 1;
    handles.nrofslices = [];
    
    load([dir file]);
    
    
    
    set(handles.pushbutton2,'enable','on');
    set(handles.pushbutton3,'enable','on');
    set(handles.pushbutton4,'enable','on');
    set(handles.checkbox1,'enable','on');
    handles.currslice = 1;
    handles.nrofslices = numel(file);
    handles.NrOfBins = 25;
    
    % clear figures
    axes(handles.axes1);
    cla reset
    axes(handles.axes2);
    cla reset
    axes(handles.axes3);
    cla reset
    axes(handles.axes4);
    cla reset
    
    set(handles.text2,'String',num2str(handles.currslice));
    
    
    handles.meanmap = meanmap;
    handles.tmask = tmask;
    
    handles.firstfilename = firstfilename;
    handles.tdata = tdata;
    handles.tmap = tmap;
    handles.maxval = maxval;
    %data = squeeze(tdata(:,:,handles.currslice));
    
    axes(handles.axes2);
    m = imagesc(handles.tmap(:,:,handles.currslice));
    axis image;colormap(handles.axes2,'jet');colorbar;caxis([0 handles.maxval]);
    axis off;
    
    
    hold on
    map = handles.map;
    mask = handles.tmask(:,:,handles.currslice);
    
    handles.tmask(:,:,handles.currslice) = mask;
    roi = mask;
    
    white = cat(3,ones(size(map)),ones(size(map)),ones(size(map)));
    mm = imshow(white);
    set(mm,'AlphaData',mask);
    hold off
    map = squeeze(tmap(:,:,handles.currslice));
    
    % % Anatomical image
    % axes(handles.axes1)
    % a = imagesc(squeeze(handles.data));
    % axis image;colormap(handles.axes1,'bone');colorbar;%caxis([0 1500]);
    % axis off
    
    
    
    if get(handles.checkbox1,'Value') == 1
        %handles.data = squeeze(handles.tdata(:,:,handles.currslice));
        mask = handles.tmask(:,:,handles.currslice);
        %map = handles.map;
        %mask(roi==1) = 0.6;
        %handles.tmask(:,:,handles.currslice) = mask;
        
        
        red = cat(3,ones(size(map)),zeros(size(map)),zeros(size(map)));
        hold on
        mm = imshow(red);
        set(mm,'AlphaData',mask);
        hold off
    else
        axes(handles.axes1)
        a = imagesc(squeeze(handles.tdata(:,:,handles.currslice)));
        axis image;colormap(handles.axes1,'bone');colorbar;caxis(handles.anatomyintensity);
        axis off
    end
    
    
    
    axes(handles.axes3);
    
    
    
    plotdata = map(roi==1);
    meanmap = [meanmap; plotdata(plotdata>0)];
    [h,n]= hist(plotdata(plotdata>0),handles.NrOfBins);
    
    plot(n,h);
    xlabel([handles.est_par ' (ms)']);
    ylabel('Voxel count');
    title(['Mean ' handles.est_par ' value: ' num2str(mean(map(roi==1),'omitnan')) ' ms']);
    %xlim([0 max(h)]);
    
    
    
    
    %MaxVal = 200;
    map(isnan(map)) = 0;
    
    if strcmp(handles.est_par,'T2')
        map(map>500) = 0;
    elseif strcmp(handles.est_par,'T1')
        map(map>5000) = 0;
    end
    
    
    [h,n]= hist(meanmap,handles.NrOfBins);
    axes(handles.axes4);
    plot(n,h);
    xlabel([handles.est_par ' (ms)']);
    ylabel('Voxel count');
    title(['Mean ' handles.est_par ' value across selected ROIs: ' num2str(mean(meanmap(:),'omitnan')) ' ms']);
    xlim([0 handles.maxval]);
    
    handles.meanmap = meanmap;
    
    guidata(hObject,handles);
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
% toggle T1/T2 for fingerprinting
t1map = handles.t1map;
t2map = handles.t2map;

if get(handles.checkbox2,'Value') == 1
    est_par = 'T2';
    tmap = t2map;
    handles.maxval = 500;
    %map(map>500) = 0;
else
    est_par = 'T1';
    tmap = t1map;
    handles.maxval = 1500;
    %map(map>5000) = 0;
end

handles.map = squeeze(tmap(:,:,handles.currslice));
map = handles.map;


% Quantitative map
axes(handles.axes2);
m = imagesc(map);
axis image;colormap(handles.axes2,'jet');colorbar;caxis([0 handles.maxval]);
axis off;
%m.Parent = handles.axes2;


% % Anatomical image
% axes(handles.axes1)
% a = imagesc(squeeze(data));
% %a.Parent = handles.axes1;
% axis image;colormap(handles.axes1,'bone');colorbar;%caxis([0 1500]);
% axis off;
handles.est_par = est_par;
%handles.tdata = tdata;
handles.tmap = tmap;
handles.map = map;
% handles.t1map = t1map;
% handles.t2map = t2map;


hold on
map = handles.map;
mask = handles.tmask(:,:,handles.currslice);

%mask(roi==1) = 0.6;
handles.tmask(:,:,handles.currslice) = mask;


white = cat(3,ones(size(map)),ones(size(map)),ones(size(map)));
mm = imshow(white);
set(mm,'AlphaData',mask);
hold off


% Anatomical image
axes(handles.axes1)
a = imagesc(squeeze(handles.data));
axis image;colormap(handles.axes1,'bone');colorbar;caxis(handles.anatomyintensity);
axis off
meanmap = handles.meanmap;
if get(handles.checkbox1,'Value') == 1
    %handles.data = squeeze(handles.tdata(:,:,handles.currslice));
    mask = handles.tmask(:,:,handles.currslice);
    %map = handles.map;
    %mask(roi==1) = 0.6;
    %handles.tmask(:,:,handles.currslice) = mask;
    
    
    red = cat(3,ones(size(map)),zeros(size(map)),zeros(size(map)));
    hold on
    mm = imshow(red);
    set(mm,'AlphaData',mask);
    hold off
end



handles.tmask(:,:,handles.currslice) = mask;
roi = mask;

axes(handles.axes3);



plotdata = map(roi==1);
meanmap = [meanmap; plotdata(plotdata>0)];
[h,n]= hist(plotdata(plotdata>0),handles.NrOfBins);

plot(n,h);
xlabel([handles.est_par ' (ms)']);
ylabel('Voxel count');
title(['Mean ' handles.est_par ' value: ' num2str(mean(map(roi==1),'omitnan')) ' ms']);
%xlim([0 max(h)]);




%MaxVal = 200;
map(isnan(map)) = 0;

if strcmp(handles.est_par,'T2')
    map(map>500) = 0;
elseif strcmp(handles.est_par,'T1')
    map(map>5000) = 0;
end


[h,n]= hist(meanmap,handles.NrOfBins);
axes(handles.axes4);
plot(n,h);
xlabel([handles.est_par ' (ms)']);
ylabel('Voxel count');
title(['Mean ' handles.est_par ' value across selected ROIs: ' num2str(mean(meanmap(:),'omitnan')) ' ms']);
xlim([0 handles.maxval]);

handles.meanmap = meanmap;

guidata(hObject,handles);
