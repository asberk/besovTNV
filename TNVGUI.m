function varargout = TNVGUI(varargin)
%% TNVGUI MATLAB code for TNVGUI.fig. Creates an interface to manipulate parameters of the TNV-type decomposition over the Besov space B_1^1(L^1).
%      TNVGUI, by itself, creates a new TNVGUI or raises the existing
%      singleton*.
%
%      H = TNVGUI returns the handle to a new TNVGUI or the handle to
%      the existing singleton*.
%
%      TNVGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TNVGUI.M with the given input arguments.
%
%      TNVGUI('Property','Value',...) creates a new TNVGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TNVGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TNVGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%      
%      This code depends on the file(s):
%      * besovROF.m
%      * decompTNV.m
%      * distinguishable_colors.m
%      * getImage.m
%      * imageTNV.m
%      * updateAxesNorms.m
%      * updateAxesTNV.m
%      * updateAxesWvlt.m
%      * updateSlidersLH.m
%      * updateWCoeff.m
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TNVGUI

% Last Modified by GUIDE v2.5 28-May-2014 23:46:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TNVGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @TNVGUI_OutputFcn, ...
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


% --- Executes just before TNVGUI is made visible.
function TNVGUI_OpeningFcn(hObject, eventdata, handles, varargin)
%% TNVGUI_OpeningFcn
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TNVGUI (see VARARGIN)

set(handles.axesWvlt, 'ColorOrder', distinguishable_colors(25));

% % % % % % % % % %
% for all handles having the property 'Units', change the entry of this
% property to 'pixels'
% set(findall(gcf, '-property', 'Units'), 'Units', 'pixels');

% % % for now, we use static text, because it will look nicer.
% % hack slider label to get LaTeX formatting
% panelProperties_Position = get(handles.panelProperties, 'Position');
% PropertiesLabelLow_Position = get(handles.labelLow,'Position')
% lam_x = panelProperties_Position(1) + PropertiesLabelLow_Position(1);
% lam_y = panelProperties_Position(2) + panelProperties_Position(4)*(57/80);
% lam_x
% lam_y
% axes('Units', 'characters', 'position',[lam_x, lam_y, 5, 2],...
%     'visible','off');
% text(.5,.5,'Initial threshold, $\lambda_0$','interpreter','latex',... 
%     'horiz','left','vert','middle', 'FontSize', 12);
% % % % % % % % % % % 

% set variables
[filename, pathname, fI] = uigetfile(...
    {'*.jpg;*.png;*.tif;*.bmp','All Image Files (*.jpg, *.png, *.tif, *.bmp)';...
    '*.jpg', 'JPEG images (*.jpg)'; '*.png', 'PNG images (*.png)';...
    '*.tif', 'TIFF images (*.tif)'; '*.bmp', 'Bitmap images (*.bmp)'},...
    'Pick an image');
if ~isnumeric(filename) %then it should be a string
    [handles.currentImage, handles.imageSize] = getImage([pathname filename]);
end

handles.wname = 'haar';

handles = updateWCoeff(handles);

% load initial/sample image
axes(handles.axesOriginal);
imshow(handles.currentImage);

% set up initial slider settings
% initial threshold is between 0 and largest magnitude of wavelet
% coefficients.
% starting value for initial threshold is 8*mean(C), where C is the vector
% of wavelet coefficients (cf. my Medical Imaging paper for why this value
% is chosen)
%
% if value of initial threshold is  zero, then set sliderMax to be 1
% (arbitrarily, since nothing will happen, now); otherwise, choose the
% largest possible integer for sliderMax such that 
% (initial threshold)*(1 + 2 + 4 + ... + 2^sliderMax) ? max(abs(C))
% 
% set properties of sliderLow. 
%
% set properties of sliderHigh, noting that it is pointless for the Min of
% sliderHigh to be lower than the value of sliderLow. This will be
% reinforced in CallBacks, later. 

% set/initialize LamInit Slider and Edit objects
set(handles.sliderLamInit, 'Min', log(mean(handles.wCoeff)), 'Max', log(handles.wMaxAbs),...
    'Value', log(8*mean(handles.wCoeff)));
set(handles.editLamInit, 'String', num2str(round(1000*exp(get(handles.sliderLamInit, 'Value')))/1000));

% set initialize {Low, High}*{Slider, Edit} objects
set(handles.sliderLow, 'Value', 0);
set(handles.sliderHigh, 'Value', 6);

handles = updateSlidersLH(handles);

% Compute wavelet decomposition cascade
handles.coeffMat = decompTNV(handles); % returns thresheld wavelet decomposition

% make example display in axesTNV:
% handles.coeffMat = decompTNV(handles); % returns thresheld wavelet decomposition
% handles.axesTNVImage = imageTNV(handles); % returns sum of decomposed images
% axes(handles.axesTNV); % set focus
% cla; % clear figure
% imshow(handles.axesTNVImage);
updateAxesTNV(handles);

% % make bottom two plots of wavelet coefficients
% Norm2f = sqrt(sum(handles.wCoeff.^2));
% uL2Norms = sqrt(sum(handles.coeffMat.'.^2));
% uCumsums = cumsum(handles.coeffMat);
% uCSL2Norms = sqrt(sum(uCumsums.'.^2));
% uBesovNorms = sum(abs(handles.coeffMat).');
% uCSBesovNorms = sum(abs(uCumsums.'));
% mC = mean(uCSL2Norms./uCSBesovNorms);
% vL2Norms = bsxfun(@minus, handles.wCoeff, uCumsums).';
% vL2Norms = sqrt(sum(vL2Norms.^2));
% %clear uCumsums;
% display(handles.sliderMax);
% 
% axes(handles.axesNorms);
% hold on;
% [yyax, yyh1, yyh2] = plotyy(1:handles.sliderMax+1, [uL2Norms; uCSL2Norms; vL2Norms].', 1:handles.sliderMax+1, [uBesovNorms; uCSBesovNorms].');
% for j = 1:length(yyh1)
%     set(yyh1(j), 'Marker', '.');
% end
% for j = 1:length(yyh2)
%     set(yyh2(j), 'Marker', '.');
% end
% L = legend('$\|u_j\|_{L^2}$', '$\|\sum_{k=0}^j \,\,u_j\|_{L^2}$', '$\|v_j\|_{L^2}$', '$\|u_j\|_{B_1^1(L^1)}$', '$\|\sum_{k=0}^j \,\,u_j\|_{B^1_1(L^1)}$');
% set(L, 'Interpreter', 'latex', 'FontSize', 14, 'Location', 'East', 'Box', 'off');
% plot([0, length(vL2Norms)], [Norm2f, Norm2f], '--m');
% hold off;
updateAxesNorms(handles);

% m = get(handles.sliderLow,'Value');
% n = get(handles.sliderHigh, 'Value');
% 
% axes(handles.axesWvlt);
% plot((sign(handles.coeffMat((m:n)+1,:)).*log(1+abs(handles.coeffMat((m:n)+1,:)))).');
% ff = @(x) num2str(x);
% legendLabels = cellfun(ff, num2cell(m:n), 'UniformOutput', 0);
% legend(legendLabels);
updateAxesWvlt(handles);

% Choose default command line output for TNVGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TNVGUI wait for user response (see UIRESUME)
% uiwait(handles.figureTNV);


% --- Outputs from this function are returned to the command line.
function varargout = TNVGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonLoad.
function buttonLoad_Callback(hObject, eventdata, handles)
%% buttonLoad_Callback
% hObject    handle to buttonLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname, fI] = uigetfile(...
    {'*.jpg;*.png;*.tif;*.bmp','All Image Files (*.jpg, *.png, *.tif, *.bmp)';...
    '*.jpg', 'JPEG images (*.jpg)'; '*.png', 'PNG images (*.png)';...
    '*.tif', 'TIFF images (*.tif)'; '*.bmp', 'Bitmap images (*.bmp)'},...
    'Pick an image');
if ~isnumeric(filename) %then it should be a string
    [handles.currentImage, handles.imageSize] = getImage([pathname filename]);
    handles = updateWCoeff(handles);
    handls.coeffMat = decompTNV(handles);

    % load initial/sample image
    axes(handles.axesOriginal);
    imshow(handles.currentImage);
    
    % set/initialize LamInit Slider and Edit objects
    set(handles.sliderLamInit, 'Min', log(mean(handles.wCoeff)), 'Max', log(handles.wMaxAbs),...
        'Value', log(8*mean(handles.wCoeff)));
    set(handles.editLamInit, 'String', num2str(round(1000*exp(get(handles.sliderLamInit, 'Value')))/1000));
    
    handles = updateSlidersLH(handles);
    guidata(hObject, handles);
% else
%   user pressed cancel
end


% --- Executes on slider movement.
function sliderHigh_Callback(hObject, eventdata, handles)
%% sliderHigh_Callback
% hObject    handle to sliderHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(hObject, 'Value', round(get(hObject, 'Value')));
handles = updateSlidersLH(handles);

updateAxesTNV(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderLow_Callback(hObject, eventdata, handles)
%% sliderLow_Callback
% hObject    handle to sliderLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(hObject, 'Value', round(get(hObject, 'Value')));
handles = updateSlidersLH(handles);

updateAxesTNV(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sliderLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderLamInit_Callback(hObject, eventdata, handles)
%% sliderLamInit_Callback
% hObject    handle to sliderLamInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% update editLamInit
set(handles.editLamInit, 'String', num2str(round(1000*exp(get(handles.sliderLamInit, 'Value')))/1000));

handles = updateSlidersLH(handles);
handles.coeffMat = decompTNV(handles);

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function sliderLamInit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderLamInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in buttonUpdate.
function buttonUpdate_Callback(hObject, eventdata, handles)
%% buttonUpdate_Callback
% hObject    handle to buttonUpdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.coeffMat = decompTNV(handles); % returns axesTNVImage

updateAxesTNV(handles);

% make bottom two plots of wavelet coefficients
updateAxesNorms(handles);
updateAxesWvlt(handles);

% pS = prod(handles.bookkeeping, 2);
% pS = pS(1:end-1).';
% pS = repmat(pS, 3, 1);
% pS(1:2, 1) = 0;
% pS = pS(:).';
% 
% xlab = cell2mat(cellfun(@colon, num2cell(ones(1, length(pS))), ...
%     num2cell(pS), 'UniformOutput', 0));

guidata(hObject, handles);


% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
%% buttonSave_Callback
% hObject    handle to buttonSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname, fI] = uiputfile(...
    {'*.jpg;*.png;*.tif;*.bmp','All Image Files (*.jpg, *.png, *.tif, *.bmp)';...
    '*.jpg', 'JPEG images (*.jpg)'; '*.png', 'PNG images (*.png)';...
    '*.tif', 'TIFF images (*.tif)'; '*.bmp', 'Bitmap images (*.bmp)'},...
    'Save as', 'untitled.png');
if ~(isequal(filename,0) || isequal(pathname,0))
%    imsave(handles.axesTNV);
     imwrite(handles.axesTNVImage, [pathname filename]);
end

% --- Executes during object creation, after setting all properties.
function panelProperties_CreateFcn(hObject, eventdata, handles)
% hObject    handle to panelProperties (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupWvlt.
function popupWvlt_Callback(hObject, eventdata, handles)
%% popupWvlt_Callback
% hObject    handle to popupWvlt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupWvlt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupWvlt

contents = cellstr(get(hObject, 'String'));
switch contents{get(hObject, 'Value')}
    case 'Haar'
        handles.wname = 'haar';
    case 'Daubechies 5'
        handles.wname = 'db5';
    case 'Daubechies 10'
        handles.wname = 'db10';
    case 'Daubechies 12'
        handles.wname = 'db12';
    case 'Daubechies 20'
        handles.wname = 'db20';
end
handles = updateWCoeff(handles);
handles.coeffMat = decompTNV(handles);
handles = updateSlidersLH(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupWvlt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupWvlt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLamInit_Callback(hObject, eventdata, handles)
%% editLamInit_Callback
% hObject    handle to editLamInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLamInit as text
%        str2double(get(hObject,'String')) returns contents of editLamInit as a double


% --- Executes during object creation, after setting all properties.
function editLamInit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLamInit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLow_Callback(hObject, eventdata, handles)
%% editLow_Callback
% hObject    handle to editLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLow as text
%        str2double(get(hObject,'String')) returns contents of editLow as a double


% --- Executes during object creation, after setting all properties.
function editLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editHigh_Callback(hObject, eventdata, handles)
%% editHigh_Callback
% hObject    handle to editHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHigh as text
%        str2double(get(hObject,'String')) returns contents of editHigh as a double


% --- Executes during object creation, after setting all properties.
function editHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbNormz.
function cbNormz_Callback(hObject, eventdata, handles)
% hObject    handle to cbNormz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbNormz
