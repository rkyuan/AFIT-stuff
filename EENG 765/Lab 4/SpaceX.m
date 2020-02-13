function varargout = SpaceX(varargin)
% SPACEX MATLAB code for SpaceX.fig
%      SPACEX, by itself, creates a new SPACEX or raises the existing
%      singleton*.
%
%      H = SPACEX returns the handle to a new SPACEX or the handle to
%      the existing singleton*.
%
%      SPACEX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPACEX.M with the given input arguments.
%
%      SPACEX('Property','Value',...) creates a new SPACEX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpaceX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpaceX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpaceX

% Last Modified by GUIDE v2.5 26-Aug-2016 17:45:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpaceX_OpeningFcn, ...
                   'gui_OutputFcn',  @SpaceX_OutputFcn, ...
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

% --- Executes just before SpaceX is made visible.
function SpaceX_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SpaceX (see VARARGIN)

% Choose default command line output for SpaceX
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
load('SpaceX_Filter_Structure.mat')
% load('Perfect_Filter_Structure.mat')
handles.m = m;
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using SpaceX.
if strcmp(get(hObject,'Visible'),'off')
    plot(0,0);
end

% UIWAIT makes SpaceX wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SpaceX_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on key release with focus on figure1 or any of its controls.
function figure1_WindowKeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)
global input;
input = -3;

% --- Executes on button press in pushbutton4.
function start(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pushbutton4.Enable='off';
guidata(hObject, handles);
global quit;
quit = false;
global input;
input = -3;

axes(handles.axes1)
h = rectangle('Position',[45 80 10 10]);
h.FaceColor = [0,0,0];
axis([0 100 0 100])
x_init = [80, -10, 0]';
x = x_init;
x2_init = [80, -10, 0]';
x2 = x_init;
fuel = 50;
inputs_saved = zeros(1,9999);
P = zeros(3);
P_init = P;
m = handles.m;
for i = 1:9e9
    if quit
        break;
    end
    if input > 0
        fuel = fuel - 1;
    end
    if fuel <= 0
        fuel = 0;
        input = -3;
    end
    inputs_saved(i) = input;
    x = SpaceX_Prop_Mean(x, m, input);
    P = SpaceX_Prop_Cov(P, m);
    x2 = SpaceX_Prop_States(x2, m, input);
    meas = SpaceX_gen_meas(x2,m);
    if mod(i,m.update_interval) == 0
%         [x, P] = SpaceX_Update(x,P,m,meas);
    end
    
    hold on
    plot([70, 70],[sqrt(P(1,1))+x(1)+5,5+x(1)-sqrt(P(1,1))], 'r', 'LineWidth', 3);
    plot([68, 72],[5+x(1)-sqrt(P(1,1)),5+x(1)-sqrt(P(1,1))], 'r', 'LineWidth', 3);
    plot([68, 72],[5+x(1)+sqrt(P(1,1)),5+x(1)+sqrt(P(1,1))], 'r', 'LineWidth', 3);
    patch([45,55,55,50,45],[x(1),x(1),x(1)+10, x(1)+15,x(1)+10],[0,0,0]);
    if input==8
        patch([45,47,48.5,50,51.5,53,55],[x(1),x(1)-2,x(1)-1,x(1)-4, x(1)-1,x(1)-2,x(1)],[1,0,0]);
    end
    patch([45,55,55,50,45]-11,[meas(1),meas(1),meas(1)+10, meas(1)+15,meas(1)+10],[0.86,0.86,0.86]);
    if input==8
        patch([45,47,48.5,50,51.5,53,55]-11,[meas(1),meas(1)-2,meas(1)-1,meas(1)-4, meas(1)-1,meas(1)-2,meas(1)],[1,0,0]);
    end
    patch([45,55,55,50,45]+11,[x2(1),x2(1),x2(1)+10, x2(1)+15,x2(1)+10],[112,128,144]/256);
    if input==8
        patch([45,47,48.5,50,51.5,53,55]+11,[x2(1),x2(1)-2,x2(1)-1,x2(1)-4, x2(1)-1,x2(1)-2,x2(1)],[1,0,0]);
    end
    
    
    handles.text1.String = strcat('Velocity =  ',num2str(x(2)));
    handles.text2.String = strcat('Fuel =  ',num2str(fuel));
    guidata(hObject, handles);
    pause(0.1)

    if x2(1) < 0 
        quit = true;
        he = patch([0,100,100,0],[0,0,100,100],[1,0,0]);
        set(he, 'FaceAlpha',0.3);
    end
    if x2(1) < 1 && abs(x2(2)) < 1
        quit = true;
        he = patch([0,100,100,0],[0,0,100,100],[0,1,0]);
        set(he, 'FaceAlpha',0.3);
        inputs_saved = inputs_saved(1:i);
        save('SpaceX_Winning_Inputs','inputs_saved','x_init','P_init');
    end
    hold off
	if ~quit
        cla
    end
end

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global quit
global input
if strcmp(eventdata.Key,'escape')
    quit = true;
    axes(handles.axes1)
    cla
    handles.pushbutton4.Enable='on';
    guidata(hObject, handles);
elseif strcmp(eventdata.Key,'uparrow')
    input = 8;
elseif strcmp(eventdata.Key,'return')
    start(hObject, eventdata, handles);
end
