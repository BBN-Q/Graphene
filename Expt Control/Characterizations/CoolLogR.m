%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using CryoCon Temperature Controller
% with Lockin measuring resistance
% Created in June 2014 by KC Fong
% Testing
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CoolLogData = CoolLogR()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear temp StartTime start_dir CoolLogData;
close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');

% Initialize variables
DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = 'C:\Users\qlab\Documents\data\';
start_dir = pwd;
StartTime = clock;
FileName = strcat('CoolLogR_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
%FilePtr = fopen(fullfile(start_dir, FileName), 'w');
%fprintf(FilePtr, strcat(datestr(StartTime), ' CoolLog using CryoCon\r\n'));
%fprintf(FilePtr,'Time_s\tTemperature_K\tLockinX\tLockinY\r\n');
%fclose(FilePtr);

% temperature log loop
j=1;
pause on;
figure(234);
while j < 12*360
    CoolLogData.time(j) = etime(clock, StartTime);
    %CoolLogData.T(j) = TController.get_temperature('A');
    %LockinV = QueryXY_Lockin(9);
    CoolLogData.X(j) = Lockin.X; CoolLogData.Y(j) = Lockin.Y;
    %CoolLogData(j,:) = [etime(clock, StartTime) TC.temperatureA() Lockin.X() Lockin.Y()];
    pause(DataInterval);
    save(FileName);
    clf; plot(CoolLogData.time/3600, CoolLogData.X, '.-'); grid on; ylabel('Lockin X (V)'); xlabel('Time (hours)'); title(strcat('CoolLog for Resistance, start date and time: ', datestr(StartTime)));
    %figure(233); clf; plot(CoolLogData.time, CoolLogData.T, '.-'); grid on; xlabel('time (s)'); ylabel('T (K)');
    j = j+1;
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TController.disconnect(); Lockin.disconnect();
clear Lockin TController;
end