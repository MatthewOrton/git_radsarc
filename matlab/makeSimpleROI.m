function varargout = makeSimpleROI(varargin)
% MAKESIMPLEROI MATLAB code for makeSimpleROI.fig
%      MAKESIMPLEROI, by itself, creates a new MAKESIMPLEROI or raises the existing
%      singleton*.
%
%      H = MAKESIMPLEROI returns the handle to a new MAKESIMPLEROI or the handle to
%      the existing singleton*.
%
%      MAKESIMPLEROI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAKESIMPLEROI.M with the given input arguments.
%
%      MAKESIMPLEROI('Property','Value',...) creates a new MAKESIMPLEROI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before makeSimpleROI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to makeSimpleROI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help makeSimpleROI

% Last Modified by GUIDE v2.5 11-Nov-2022 18:58:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @makeSimpleROI_OpeningFcn, ...
                   'gui_OutputFcn',  @makeSimpleROI_OutputFcn, ...
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


% --- Executes just before makeSimpleROI is made visible.
function makeSimpleROI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to makeSimpleROI (see VARARGIN)

handles.figure1.UserData = struct('image', varargin{1},...
                                  'CLim', varargin{2},...
                                  'fileout', varargin{3});

nSlices = size(varargin{1},3);
handles.slider1.SliderStep = [1/(nSlices-1) 10/(nSlices-1)];
handles.slider1.Value = 0.5;

updateAll(handles)

% Choose default command line output for makeSimpleROI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes makeSimpleROI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = makeSimpleROI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% delete(hObject);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

updateAll(handles)


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbuttonROI.
function pushbuttonROI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.axes1.UserData = drawellipse(handles.axes1);
uiwait(handles.figure1)

function updateAll(handles)

nSlices = size(handles.figure1.UserData.image,3);
slice = round(handles.slider1.Value*(nSlices-1)+1);

imVol = handles.figure1.UserData.image;
imSlice = imVol(:,:,slice);

image(imSlice, 'Parent', handles.axes1, 'CDataMapping', 'scaled')
handles.axes1.CLim = handles.figure1.UserData.CLim;
handles.axes1.XColor = 'none';
handles.axes1.YColor = 'none';

colormap(handles.axes1, 'gray')


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: delete(hObject) closes the figure
delete(hObject);



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

nSlices = size(handles.figure1.UserData.image,3);
slice = round(handles.slider1.Value*(nSlices-1)+1);

mask = false(size(handles.figure1.UserData.image));
mask(:,:,slice) = createMask(handles.axes1.UserData);

save(handles.figure1.UserData.fileout, 'mask')
uiresume()

