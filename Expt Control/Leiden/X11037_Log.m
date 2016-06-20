%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using X11037 cernox thermometer in Leiden using a lockin
% Created in Jun 2016 by Jesse Crossno
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = X11037_Log(Rex,address)

% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.X110375(Rex,address);


% Initialize variables
TempInterval = input('Time interval between temperature measurements (in second) [1] = ');
if isempty(TempInterval)
    TempInterval = 1;
end
UniqueName = input('Enter uniquie file identifier: ','s');
start_dir = 'D:\Crossno\data';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('X11037log_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');


% Initialize VNA Data
data = struct('time',[],'temperature',[],'voltage',[]);
data.Rex = Rex;
data.Vex = TC.sineAmp;
% Log Loop

n = 1;
pause on;
stopbutton = waitbar(0,'1','Name','Monitoring temperature of X110375',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
setappdata(stopbutton,'canceling',0)
figure(992); clf; xlabel('time (min)');ylabel('Temperature (K)'); grid on; 
while true
    if getappdata(stopbutton,'canceling')
        break
    end
    data.time(n) = etime(clock, StartTime);
    data.temperature(n) = TC.temperature();
    data.voltage(n) = TC.R;
    
    save(fullfile(start_dir, FileName),'data')

    change_to_figure(992);
    plot(data.time/60,data.temperature,'r')
    waitbar((mod(n,20)+5)/30,stopbutton,sprintf('%f',data.temperature(n)))
    n = n+1;
    pause(TempInterval);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TC.disconnect();
delete(stopbutton);
clear TC;