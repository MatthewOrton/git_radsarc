function varargout = smoothedThreshold(varargin)
% SMOOTHEDTHRESHOLD MATLAB code for smoothedThreshold.fig
%      SMOOTHEDTHRESHOLD, by itself, creates a new SMOOTHEDTHRESHOLD or raises the existing
%      singleton*.
%
%      H = SMOOTHEDTHRESHOLD returns the handle to a new SMOOTHEDTHRESHOLD or the handle to
%      the existing singleton*.
%
%      SMOOTHEDTHRESHOLD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SMOOTHEDTHRESHOLD.M with the given input arguments.
%
%      SMOOTHEDTHRESHOLD('Property','Value',...) creates a new SMOOTHEDTHRESHOLD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before smoothedThreshold_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to smoothedThreshold_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help smoothedThreshold

% Last Modified by GUIDE v2.5 18-Aug-2022 22:21:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @smoothedThreshold_OpeningFcn, ...
                   'gui_OutputFcn',  @smoothedThreshold_OutputFcn, ...
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


% --- Executes just before smoothedThreshold is made visible.
function smoothedThreshold_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to smoothedThreshold (see VARARGIN)

handles.figure1.UserData = struct('image', varargin{1},...
                                  'CLim', varargin{2},...
                                  'mask',varargin{3},...
                                  'imageSmoothed', imgaussfilt(varargin{1},1));

nSlices = size(varargin{1},3);
handles.slider4.SliderStep = [1/(nSlices-1) 10/(nSlices-1)];

updateMask(handles)

% Choose default command line output for smoothedThreshold
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes smoothedThreshold wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = smoothedThreshold_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateMask(handles)

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateMask(handles)

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateMask(handles)

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function updateMask(handles)

nSlices = size(handles.figure1.UserData.image,3);
slice = round(handles.slider4.Value*(nSlices-1)+1);

imVol = handles.figure1.UserData.image;
imSlice = imVol(:,:,slice);

maskVol = handles.figure1.UserData.mask;
maskSlice = maskVol(:,:,slice);

image(imSlice, 'Parent', handles.axes1, 'CDataMapping','scaled')

hold(handles.axes1,'on');

pos = GetPixellatedROI(maskSlice);
plot(pos(1,:),pos(2,:), 'r', 'LineWidth', 2, 'Parent', handles.axes1)

handles.axes1.XColor = 'none';
handles.axes1.YColor = 'none';
handles.axes1.CLim = handles.figure1.UserData.CLim;
colormap(handles.axes1, 'gray')

hold(handles.axes1,'off')

limits = handles.figure1.UserData.CLim;

t1 = limits(1) + (limits(2)-limits(1))*handles.slider1.Value;
t2 = limits(1) + (limits(2)-limits(1))*handles.slider2.Value;
t3 = limits(1) + (limits(2)-limits(1))*handles.slider3.Value;

imVol = handles.figure1.UserData.imageSmoothed;
masks(:,:,:,1) = imVol < t1 & maskVol;
masks(:,:,:,2) = imVol >= t1 & imVol < t2 & maskVol;
masks(:,:,:,3) = imVol >= t2 & imVol < t3 & maskVol;
masks(:,:,:,4) = imVol >= t3 & maskVol;

segVol = sum(masks.*reshape([1 2 3 4],[1 1 1 4]),4);
segVol(~maskVol) = 0;
image(segVol(:,:,slice), 'Parent', handles.axes2,'CDataMapping','scaled')

handles.axes2.XColor = 'none';
handles.axes2.YColor = 'none';
handles.axes2.CLim = [0 4];
cmap = [0 0 0
    0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560];
colormap(handles.axes2, cmap)


% Histogram of raw pixel values
pixels = imVol(maskVol);
skip = ceil(length(pixels)/5000);
pixels = pixels(1:skip:end);
CLim = handles.figure1.UserData.CLim;
h = histogram(pixels(pixels>CLim(1) & pixels<CLim(2)));
binEdges = h.BinEdges;
histogram(pixels, 'BinEdges', [binEdges Inf], 'Normalization','countdensity', 'EdgeColor', 'none', 'Parent', handles.axes3);
hold(handles.axes3, 'on')
PreviousColor
delete(h)


x = linspace(CLim(1), CLim(2), 200);
for mm = 1:4
    pixelsH = imVol(masks(:,:,:,mm));
    mu(mm) = mean(pixelsH);
    sg(mm) = std(pixelsH);
    pixelsH = pixelsH(1:skip:end);
    if length(pixelsH)>1
        fr = ksdensity(pixelsH, x, 'Bandwidth', 5);
        plot(x,fr*nnz(maskVol & masks(:,:,:,mm))/skip, 'LineWidth', 2);
    else
        % plot nothing so the ColorOrderIndex increments
        plot(NaN, NaN);
    end
end

handles.text1.String = num2str(mu(1));
handles.text3.String = num2str(mu(2));
handles.text5.String = num2str(mu(3));
handles.text7.String = num2str(mu(4));

handles.text2.String = num2str(sg(1));
handles.text4.String = num2str(sg(2));
handles.text6.String = num2str(sg(3));
handles.text8.String = num2str(sg(4));

handles.axes3.ColorOrder = cmap(2:end,:);

hold(handles.axes3, 'off')
% disp(prior)


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
updateMask(handles)

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
