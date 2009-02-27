function contdemo(action,varargin);
%   OpenCV contour functions demo

global demoName;
demoName = 'OpenCV Contour Demo';
if nargin<1,
   action='InitializeDEMO';
end;

feval(action,varargin{:});
return;


%%%
%%%  Sub-function - InitializeDEMO
%%%

function InitializeDEMO()

global demoName;

% If demo is already running, bring it to the foreground.
h = findobj(allchild(0), 'tag', demoName);
if ~isempty(h)
   figure(h(1))
   return
end

screenD = get(0, 'ScreenDepth');
if screenD>8
   grayres=256;
else
   grayres=128;
end
 
DemoFig=figure( ...
   'Name',demoName, ...
   'NumberTitle','off', 'HandleVisibility', 'on', ...
   'tag', demoName, ...
   'Visible','off', 'Resize', 'off',...
   'BusyAction','Queue','Interruptible','off',...
   'IntegerHandle', 'off', ...
   'Doublebuffer', 'on', ...
   'Colormap', gray(grayres));

%====================================
% Information for all buttons (and menus)
btnWid=0.175;
btnHt=0.06;

%====================================
% The CONSOLE frame
frmBorder=0.02;
frmBottom = 0.15;

frmLeft = 0.5-btnWid-1.5*frmBorder;
frmWidth = 2*btnWid+3*frmBorder;
frmHeight = btnHt+2*frmBorder;
frmPos=[frmLeft frmBottom frmWidth frmHeight];
h=uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','frame', ...
   'Units','normalized', ...
   'Position',frmPos, ...
   'BackgroundColor',[0.45 0.45 0.45]);

%====================================
% The Apply button
labelStr='Apply';
callbackStr='contdemo(''Apply'')';
yPos=frmBottom+frmBorder;
applyHndl=uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','pushbutton', ...
   'Units','normalized', ...
   'Position',[frmLeft+frmBorder yPos btnWid btnHt], ...
   'String',labelStr, ...
   'Enable', 'off', ...
   'Callback',callbackStr);


%====================================
% The CLOSE button
labelStr='Close';
callbackStr='close(gcf)';

closeHndl=uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','pushbutton', ...
   'Units','normalized', ...
   'Position',[frmLeft+btnWid+2*frmBorder yPos btnWid btnHt], ...
   'Enable', 'off', ...
   'String',labelStr, ...
   'Callback',callbackStr);

c = get(DemoFig,'Color');
if [.298936021 .58704307445 .114020904255]*c'<.5,
   fgColor = [1 1 1];
else
   fgColor = [0 0 0];
end

%==================================
% Set up the image axes
figpos = get(DemoFig, 'position');
row = figpos(4); col = figpos(3);  % dimensions of figure window

vertSpac = (row-256)/3;
horSpac = (col-3*128)/4;
hSrcAx = axes('Parent', DemoFig, ...
   'units', 'pixels', ...
   'BusyAction','Queue','Interruptible','off',...
   'ydir', 'reverse', ...
   'XLim', [.5 128.5], ...
   'YLim', [.5 128.5],...
   'CLim', [0 255], ...
   'XTick',[],'YTick',[], ...
   'Position', [horSpac row-vertSpac-128 128 128]);
title('Source Image');

hBinAx = axes('Parent', DemoFig, ...
   'units', 'pixels', ...
   'BusyAction','Queue', 'Interruptible','off',...
   'ydir', 'reverse', ...
   'XLim', [.5 128.5], ...
   'YLim', [.5 128.5],...
   'CLim', [0 255], ...
   'XTick',[],'YTick',[], ...
   'Position', [2*horSpac + 128 row - vertSpac-128 128 128]);
title('Threshold Image');

hContAx = axes('Parent', DemoFig, ...
   'units', 'pixels', ...
   'BusyAction','Queue', 'Interruptible','off',...
   'ydir', 'reverse', ...
   'XLim', [.5 128.5], ...
   'YLim', [.5 128.5],...
   'CLim', [0 255], ...
   'XTick',[],'YTick',[], ...
   'Position', [3*horSpac + 256 row - vertSpac-128 128 128]);
title('Contour Image');

%==================================
% Set up the images
blank = repmat(uint8(0),128,128);
hSrcImage = image('Parent', hSrcAx,...
   'CData', blank, ...
   'BusyAction','Queue','Interruptible','off',...
   'CDataMapping', 'scaled', ...
   'Xdata', [1 128],...
   'Ydata', [1 128],...
   'EraseMode', 'none');

hBinImage = image('Parent', hBinAx,...
   'CData', blank, ...
   'BusyAction','Queue','Interruptible','off',...
   'CDataMapping', 'scaled', ...
   'Xdata', [1 128],...
   'Ydata', [1 128],...
   'EraseMode', 'none');

hContImage = image('Parent', hContAx,...
   'CData', blank, ...
   'BusyAction','Queue','Interruptible','off',...
   'CDataMapping', 'scaled', ...
   'Xdata', [1 128],...
   'Ydata', [1 128],...
   'EraseMode', 'none');

% Status bar
% rangePos = [64 3 280 15];
rangePos = [0 .01 1 .05];
hStatus = uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','text', ...
   'Units','normalized', ...
   'Position',rangePos, ...
   'Horiz','center', ...
   'Background',c, ...
   'Foreground',[.8 0 0], ...
   'Tag', 'Status', ...
   'String','Status bar');

%====================================
% The Threshold Popup
ctrHt = 19; % controls' height
binImgPos = get(hBinAx, 'Position');
pos = [binImgPos(1) binImgPos(2) - 3*ctrHt binImgPos(3) ctrHt];
hThreshPop=uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','popupmenu', ...
   'BackgroundColor',[.8 .8 .8], ...
   'Units','pixels', ...
   'Position',pos, ...
   'String','binary|binary_inv|trunc|tozero|tozero_inv', ...
   'Tag','ThreshPop', ...
   'Callback','contdemo(''ControlsUpdate'')');
%====================================
% The Threshold Label
pos = [binImgPos(1) binImgPos(2) - 2*ctrHt binImgPos(3) ctrHt];
h = uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','text', ...
   'Units','pixels', ...
   'Position',pos, ...
   'Horiz','center', ...
   'Background',c, ...
   'Foreground','black', ...
   'String','Threshold Type:');

%===================================
% Set up scroll bar
thresh = 128;

pos = [binImgPos(1) binImgPos(2) - 5*ctrHt binImgPos(3) ctrHt];
callbackStr = 'contdemo(''ControlsUpdate'')';
hSlider = uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','slider', ...
   'Units','pixels', ...
   'Position',pos, ...
   'Value',thresh, ...
   'min',0, ...
   'max',255, ...
   'Interruptible','off', ...
   'Callback',callbackStr);

% Left and right range indicators
pos = [binImgPos(1) binImgPos(2) - 6*ctrHt binImgPos(3)/2 ctrHt];
uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','text', ...
   'Units','pixels', ...
   'Position',pos, ...
   'Horiz','left', ...
   'Background',c, ...
   'Foreground',fgColor, ...
   'String','0');

pos = [binImgPos(1)+binImgPos(3)/2 binImgPos(2) - 6*ctrHt binImgPos(3)/2 ctrHt];
uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','text', ...
   'Units','pixels', ...
   'Position',pos, ...
   'Horiz','right', ...
   'Background',c, ...
   'Foreground',fgColor, ...
   'String','255');

pos = [binImgPos(1) binImgPos(2) - 4*ctrHt binImgPos(3) ctrHt];
hThresh = uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','text', ...
   'Units','pixels', ...
   'Position',pos, ...
   'Horiz','center', ...
   'Background',c, ...
   'Foreground',fgColor, ...
   'String',['Threshold: ' int2str(thresh)]);

%====================================
% The Approx Popup
contImgPos = get(hContAx, 'Position');
pos = [contImgPos(1) contImgPos(2) - 3*ctrHt contImgPos(3) ctrHt];
hAppPop=uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','popupmenu', ...
   'BackgroundColor',[.8 .8 .8], ...
   'Units','pixels', ...
   'Position',pos, ...
   'String','none|simple|tc89_l1|tc89_kcos|dp', ...
   'Tag','ThreshPop', ...
   'Callback','contdemo(''ControlsUpdate'')');
%====================================
% The Approx Label
pos = [contImgPos(1) contImgPos(2) - 2*ctrHt contImgPos(3) ctrHt];
h = uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','text', ...
   'Units','pixels', ...
   'Position',pos, ...
   'Horiz','center', ...
   'Background',c, ...
   'Foreground','black', ...
   'String','Approx Type:');

%====================================
% The Approx Edit
pos = [contImgPos(1) contImgPos(2) - 5*ctrHt contImgPos(3) ctrHt];
hAppEdit=uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','edit', ...
   'Background','white', ...
   'Foreground','black', ...
   'Units','pixels', ...
   'Position',pos, ...
   'String','1.0', ...
   'Horiz', 'right',...
   'Tag','AppEdit', ...
   'Enable', 'off', ...
   'UserData', [1.0], ...
   'Callback','contdemo(''ControlsUpdate'')');
%====================================
% The Approx Edit Label
pos = [contImgPos(1) contImgPos(2) - 4*ctrHt contImgPos(3) ctrHt];
h = uicontrol( ...
   'Parent', DemoFig, ...
   'BusyAction','Queue','Interruptible','off',...
   'Style','text', ...
   'Units','pixels', ...
   'Position',pos, ...
   'Horiz','center', ...
   'Background',c, ...
   'Foreground','black', ...
   'String','Approx Param:');

%set(DemoFig,'defaultaxesposition',[0.10 0.1 0.60 0.85])
setstatus(DemoFig, 'Initializing Demo...');
set(DemoFig, 'Pointer', 'watch');
drawnow
set(DemoFig, 'Visible','on');

% Put handles to graphics objects and controls in the figure's userdata
handles.SrcImage = hSrcImage;
handles.BinImage = hBinImage;
handles.ContImage = hContImage;
handles.Slider = hSlider; 
handles.Thresh = hThresh;
handles.SrcAx = hSrcAx;
handles.BinAx = hBinAx;
handles.ContAx = hContAx;
handles.ThreshPop = hThreshPop;
handles.AppPop = hAppPop;
handles.AppEdit = hAppEdit;

set(DemoFig, 'UserData', handles);

LoadNewImage(DemoFig);

set(DemoFig, 'HandleVisibility','Callback')
set([closeHndl applyHndl], 'Enable', 'on');
return


%%%
%%%  Sub-Function - LoadNewImage
%%%

function LoadNewImage(DemoFig)

if nargin<1
   DemoFig = gcbf;
end

set(DemoFig,'Pointer','watch');
handles = get(DemoFig,'UserData');
hSrcImage=handles.SrcImage;
hSrcAx = handles.SrcAx;

saturn = [];  % Make sure saturn is parsed as a variable
load cvdemos saturn

img = saturn;

set(hSrcImage, 'Cdata', img);
blank = repmat(uint8(0),128,128);
set(handles.BinImage, 'Cdata', blank);
drawnow;

ControlsUpdate(DemoFig);
Apply(DemoFig);
return;


%%%
%%%  Sub-Function - Apply
%%%

function Apply(DemoFig)

if nargin<1
   DemoFig = gcbf;
end

handles = get(DemoFig,'UserData');
hSrcImage=handles.SrcImage;
hBinImage=handles.BinImage;
hSlider=handles.Slider;
hBinAx=handles.BinAx;
hContImage = handles.ContImage;
hThreshPop = handles.ThreshPop;
hAppPop = handles.AppPop;
hAppEdit = handles.AppEdit;

img = get(hSrcImage, 'CData');

set(DemoFig,'Pointer','watch');
setstatus(DemoFig, 'Binarizing image...'); drawnow;

% Binarize and display image

thresh = floor(get(hSlider, 'Value'));

% threshType
v = get(hThreshPop,{'value','String'});
threshType = deblank(v{2}(v{1},:));

binImage = cvThreshold(img, thresh, 255, threshType);
set(hBinImage, 'CData', binImage);

contImage = repmat(uint8(0), size(img));
contImage = binImage;

% approx type
v = get(hAppPop,{'Value','String'});
appType = deblank(v{2}(v{1},:));

% approx value
appVal = get(hAppEdit, 'UserData');

if strcmp(appType, 'dp') == 0
    Contours = cvFindContours(contImage, 'list', appType);
else
    Cont = cvFindContours(contImage, 'list', 'none');
    Contours = cvApproxPoly(Cont, 1, 'dp', appVal, 1);
end

contImage = repmat(uint8(0), size(img));
contImage = cvDrawContours(contImage, Contours, 1, 255, 255, 1);

set(hContImage, 'CData', contImage);

drawnow;

setstatus(DemoFig, 'Done');
set(DemoFig,'Pointer','arrow'); drawnow
return


%%%
%%%  Sub-function - ControlsUpdate
%%%

function ControlsUpdate(DemoFig)

if nargin<1
   DemoFig = gcbf;
end;

handles = get(DemoFig,'UserData');

hSlider=handles.Slider;
hThresh = handles.Thresh;
hAppEdit = handles.AppEdit;
hAppPop  = handles.AppPop;

% threshold value
thresh = floor(get(hSlider, 'Value'));
set(hThresh, 'String', ['Threshold: ' int2str(thresh)]);

% approx value
oldv = get(hAppEdit, 'UserData');
newv = str2num(get(hAppEdit, 'String'));
if isempty(newv) | newv(1) < 0
    newv = oldv;
end
set(hAppEdit, 'String', num2str(newv(1)));
set(hAppEdit, 'UserData', newv(1));

% approx type
v = get(hAppPop,{'Value','String'});
appType = deblank(v{2}(v{1},:));
if strcmp(appType, 'dp') == 0
    set(hAppEdit, 'Enable', 'off');
else
    set(hAppEdit, 'Enable', 'on');
end

setstatus(DemoFig, 'Press ''Apply'' button');
return;
