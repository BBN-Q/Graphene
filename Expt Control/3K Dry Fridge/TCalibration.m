%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using LakeShore 335 Temperature Controller
% Created in May 2014 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CoolLogData = TCalibration()
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
figure; pause on;
while j < 60*24
    %TController370 = deviceDrivers.Lakeshore370();
    TController335 = deviceDrivers.Lakeshore335();
    %TController370.connect('12');
    TController335.connect('2');
    CoolLogData.time(j) = etime(clock, StartTime);
    %CoolLogData.TBlueFor(j) = TControllerLakeShore.get_temperature('A');
    %CoolLogData.RLakeShore(j) = TController.get_temperature(8);
    %CoolLogData.TBlueFor(j) = TController370.get_temperature(8);
    CoolLogData.RLakeShore(j) = TController335.get_resistance('A');
    %TController370.disconnect();
    TController335.disconnect();
    save(FileName);
    clf; plot(CoolLogData.time/60, CoolLogData.RLakeShore, '.-'); grid on; xlabel('Time (min)'); ylabel('R (\Omega)'); title(strcat('Cooling for Tc, start date and time: ', datestr(StartTime)));
    %clf; plot(CoolLogData.time/60, CoolLogData.TBlueFor, '.-'); grid on; xlabel('Time (min)'); ylabel('Temperature (K)'); title(strcat('Cooling for Tc, start date and time: ', datestr(StartTime)));
    pause(DataInterval);
    j = j+1;
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear TController;