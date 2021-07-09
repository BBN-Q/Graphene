%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using LakeShore 335 Temperature Controller
% Created in May 2014 by KC Fong
% adapted in July 2021 by Caleb Fried
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CoolLogData = CryoCon_CoolLog()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear temp StartTime start_dir CoolLogData;
close all;
fclose all;

% Initialize variables
DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = 'C:\Users\qlab\Documents\data\CoolLog\';
start_dir = uigetdir(start_dir);
cd(start_dir);
StartTime = clock;
FileName = strcat('CoolLog_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');

% temperature log loop
j=1;
Lockin = deviceDrivers.SRS865();
Lockin.connect('128.33.89.143');
pause on;
while j < 3600*16/10
    TController = deviceDrivers.Lakeshore335();
    TController.connect('2');
    CoolLogData.time(j) = etime(clock, StartTime);
    CoolLogData.T(j) = TController.get_temperature('A');
    CoolLogData.X(j) = Lockin.X;
    CoolLogData.Y(j) = Lockin.Y;
    TController.disconnect();
    save(FileName);
    figure(999); clf; plot(CoolLogData.time/60, CoolLogData.T, '.-'); grid on; xlabel('Time (min)'); ylabel('Temperature (K)'); title(strcat('Cooling for Tc, start date and time: ', datestr(StartTime)));
    figure(998); clf; plot(CoolLogData.time/60, CoolLogData.X, '.-'); grid on; xlabel('Time (min)'); ylabel('Lockin X (V)'); title('Lockin Reading During Cooling');
    pause(DataInterval);
    j = j+1;
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear TController;