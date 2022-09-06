function varargout = gmmPriorSelect(varargin)
% GMMPRIORSELECT MATLAB code for gmmPriorSelect.fig
%      GMMPRIORSELECT, by itself, creates a new GMMPRIORSELECT or raises the existing
%      singleton*.
%
%      H = GMMPRIORSELECT returns the handle to a new GMMPRIORSELECT or the handle to
%      the existing singleton*.
%
%      GMMPRIORSELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GMMPRIORSELECT.M with the given input arguments.
%
%      GMMPRIORSELECT('Property','Value',...) creates a new GMMPRIORSELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gmmPriorSelect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gmmPriorSelect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gmmPriorSelect

% Last Modified by GUIDE v2.5 18-Aug-2022 18:08:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gmmPriorSelect_OpeningFcn, ...
                   'gui_OutputFcn',  @gmmPriorSelect_OutputFcn, ...
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


% --- Executes just before gmmPriorSelect is made visible.
function gmmPriorSelect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gmmPriorSelect (see VARARGIN)

image(varargin{1}, 'Parent', handles.axes1, 'CDataMapping','scaled')
hold(handles.axes1,'on');
pos = GetPixellatedROI(varargin{3});
plot(pos(1,:),pos(2,:), 'r', 'LineWidth', 2, 'Parent', handles.axes1)

handles.axes1.XColor = 'none';
handles.axes1.YColor = 'none';
handles.axes1.CLim = varargin{2};
colormap(handles.axes1, 'gray')

for n = 1:4
    eval(['handles.mu_mu_' num2str(n) '.Value = varargin{4}.mu_mu(' num2str(n) ');'])
    eval(['handles.mu_mu_' num2str(n) '.String = num2str(varargin{4}.mu_mu(' num2str(n) '));'])

    eval(['handles.mu_sigma_' num2str(n) '.Value = varargin{4}.mu_sigma(' num2str(n) ');'])
    eval(['handles.mu_sigma_' num2str(n) '.String = num2str(varargin{4}.mu_sigma(' num2str(n) '));'])

    eval(['handles.sigma_mu_' num2str(n) '.Value = varargin{4}.sigma_mu(' num2str(n) ');'])
    eval(['handles.sigma_mu_' num2str(n) '.String = num2str(varargin{4}.sigma_mu(' num2str(n) '));'])

    eval(['handles.sigma_cov_' num2str(n) '.Value = varargin{4}.sigma_cov(' num2str(n) ');'])
    eval(['handles.sigma_cov_' num2str(n) '.String = num2str(varargin{4}.sigma_cov(' num2str(n) '));'])
end

% Choose default command line output for gmmPriorSelect
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gmmPriorSelect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gmmPriorSelect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function mu_mu_1_Callback(hObject, eventdata, handles)
% hObject    handle to mu_mu_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mu_mu_1 as text
%        str2double(get(hObject,'String')) returns contents of mu_mu_1 as a double


% --- Executes during object creation, after setting all properties.
function mu_mu_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mu_mu_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mu_mu_2_Callback(hObject, eventdata, handles)
% hObject    handle to mu_mu_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mu_mu_2 as text
%        str2double(get(hObject,'String')) returns contents of mu_mu_2 as a double


% --- Executes during object creation, after setting all properties.
function mu_mu_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mu_mu_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mu_mu_3_Callback(hObject, eventdata, handles)
% hObject    handle to mu_mu_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mu_mu_3 as text
%        str2double(get(hObject,'String')) returns contents of mu_mu_3 as a double


% --- Executes during object creation, after setting all properties.
function mu_mu_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mu_mu_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mu_mu_4_Callback(hObject, eventdata, handles)
% hObject    handle to mu_mu_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mu_mu_4 as text
%        str2double(get(hObject,'String')) returns contents of mu_mu_4 as a double


% --- Executes during object creation, after setting all properties.
function mu_mu_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mu_mu_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mu_sigma_1_Callback(hObject, eventdata, handles)
% hObject    handle to mu_sigma_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mu_sigma_1 as text
%        str2double(get(hObject,'String')) returns contents of mu_sigma_1 as a double


% --- Executes during object creation, after setting all properties.
function mu_sigma_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mu_sigma_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mu_sigma_2_Callback(hObject, eventdata, handles)
% hObject    handle to mu_sigma_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mu_sigma_2 as text
%        str2double(get(hObject,'String')) returns contents of mu_sigma_2 as a double


% --- Executes during object creation, after setting all properties.
function mu_sigma_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mu_sigma_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mu_sigma_3_Callback(hObject, eventdata, handles)
% hObject    handle to mu_sigma_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mu_sigma_3 as text
%        str2double(get(hObject,'String')) returns contents of mu_sigma_3 as a double


% --- Executes during object creation, after setting all properties.
function mu_sigma_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mu_sigma_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mu_sigma_4_Callback(hObject, eventdata, handles)
% hObject    handle to mu_sigma_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mu_sigma_4 as text
%        str2double(get(hObject,'String')) returns contents of mu_sigma_4 as a double


% --- Executes during object creation, after setting all properties.
function mu_sigma_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mu_sigma_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigma_mu_1_Callback(hObject, eventdata, handles)
% hObject    handle to sigma_mu_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma_mu_1 as text
%        str2double(get(hObject,'String')) returns contents of sigma_mu_1 as a double


% --- Executes during object creation, after setting all properties.
function sigma_mu_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma_mu_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigma_mu_2_Callback(hObject, eventdata, handles)
% hObject    handle to sigma_mu_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma_mu_2 as text
%        str2double(get(hObject,'String')) returns contents of sigma_mu_2 as a double


% --- Executes during object creation, after setting all properties.
function sigma_mu_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma_mu_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigma_mu_3_Callback(hObject, eventdata, handles)
% hObject    handle to sigma_mu_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma_mu_3 as text
%        str2double(get(hObject,'String')) returns contents of sigma_mu_3 as a double


% --- Executes during object creation, after setting all properties.
function sigma_mu_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma_mu_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigma_mu_4_Callback(hObject, eventdata, handles)
% hObject    handle to sigma_mu_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma_mu_4 as text
%        str2double(get(hObject,'String')) returns contents of sigma_mu_4 as a double


% --- Executes during object creation, after setting all properties.
function sigma_mu_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma_mu_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigma_cov_1_Callback(hObject, eventdata, handles)
% hObject    handle to sigma_cov_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma_cov_1 as text
%        str2double(get(hObject,'String')) returns contents of sigma_cov_1 as a double


% --- Executes during object creation, after setting all properties.
function sigma_cov_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma_cov_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigma_cov_2_Callback(hObject, eventdata, handles)
% hObject    handle to sigma_cov_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma_cov_2 as text
%        str2double(get(hObject,'String')) returns contents of sigma_cov_2 as a double


% --- Executes during object creation, after setting all properties.
function sigma_cov_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma_cov_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigma_cov_3_Callback(hObject, eventdata, handles)
% hObject    handle to sigma_cov_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma_cov_3 as text
%        str2double(get(hObject,'String')) returns contents of sigma_cov_3 as a double


% --- Executes during object creation, after setting all properties.
function sigma_cov_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma_cov_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigma_cov_4_Callback(hObject, eventdata, handles)
% hObject    handle to sigma_cov_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sigma_cov_4 as text
%        str2double(get(hObject,'String')) returns contents of sigma_cov_4 as a double


% --- Executes during object creation, after setting all properties.
function sigma_cov_4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sigma_cov_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
