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

% Last Modified by GUIDE v2.5 15-Nov-2016 21:03:52

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



function run_game(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pushbutton11.Enable='off';
guidata(hObject, handles);
global quit;
quit = false;
global input;
input = 0;
axes(handles.axes1)
axis([0 100 0 100])
x = [80, -10]';
fuel = 50;
inputs_saved = zeros(1,9999);

for i = 1:9e9
    if quit
        break;
    end
    if input > 0
        fuel = fuel - 1;
    end
    if fuel <= 0
        fuel = 0;
        input = 0;
    end
    inputs_saved(i) = input;
    x = SpaceX_student_function(x, input);
    patch([45,55,55,50,45],[x(1),x(1),x(1)+10, x(1)+15,x(1)+10],[0,0,0]);
    if input==8000
        patch([45,47,48.5,50,51.5,53,55],[x(1),x(1)-2,x(1)-1,x(1)-4, x(1)-1,x(1)-2,x(1)],[1,0,0]);
    end
    handles.text1.String = strcat('Velocity =  ',num2str(x(2)));
    handles.text2.String = strcat('Fuel =  ',num2str(fuel));
    grav = 3000*1000/(1000+x(1))^2;
    handles.text3.String = strcat('Gravity =  ',num2str(grav));
    pause(0.1)
    if x(1) < 0 
        quit = true;
        he = patch([0,100,100,0],[0,0,100,100],[1,0,0]);
        set(he, 'FaceAlpha',0.3);
    end
    if x(1) < 1 && abs(x(2)) < 1
        quit = true;
        he = patch([0,100,100,0],[0,0,100,100],[0,1,0]);
        set(he, 'FaceAlpha',0.3);
        inputs_saved = inputs_saved(1:i);
        save('SpaceX_Winning_Inputs','inputs_saved');
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
    handles.pushbutton11.Enable='on';
    handles.pushbutton22.Enable='on';
    guidata(hObject, handles);
elseif strcmp(eventdata.Key,'uparrow')
    input = 8000;
elseif strcmp(eventdata.Key,'return')
    run_game(hObject, eventdata, handles);
elseif strcmp(eventdata.Key,'shift')
    run_game_s(hObject, eventdata, handles);
end

% --- Executes on key release with focus on figure1 or any of its controls.
function figure1_WindowKeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)
global input;
input = 0;


% --- Executes on button press in pushbutton2.
function run_game_s(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pushbutton22.Enable='off';
handles.pushbutton11.Enable='off';
guidata(hObject, handles);
global quit;
quit = false;
global input;
input = 0;
axes(handles.axes1)

axis([0 100 0 100])
x = [80, -10]';
x2 = [80, -10]';
fuel = 50;

for i = 1:9e9
    pause(1.1)
    if quit
        break;
    end
    if input > 0
        fuel = fuel - 1;
    end
    if fuel <= 0
        fuel = 0;
        input = 0;
    end
    x = SpaceX_student_function(x, input);
    x2 = SpaceX_student_function(x2, input+0.3*rand());
    xx = [45 45 55 55];
    yy = [x(1) x(1)+10 x(1)+10 x(1)];
    patch(xx,yy,'green','FaceAlpha',0.3);
    hold on
    xx = [45 45 55 55];
    yy = [x2(1) x2(1)+10 x2(1)+10 x2(1)];
    patch(xx,yy,'blue','FaceAlpha',0.5);
    hold off
    handles.text1.String = strcat('Velocity =  ',num2str(x(2)));
    handles.text2.String = strcat('Fuel =  ',num2str(fuel));
    grav = 3000*1000/(1000+x(1))^2;
    handles.text3.String = strcat('Gravity =  ',num2str(grav));
    pause(0.1)
    cla();
    if x2(1) < 0 
        quit = true;
        h = rectangle('Position',[0 0 100 100]);
        h.FaceColor = [1,0,0];
        
    end
    if x2(1) < 1 && abs(x2(2)) < 1
        quit = true;
        h = rectangle('Position',[0 0 100 100]);
        h.FaceColor = [0,1,0];
    end
end
