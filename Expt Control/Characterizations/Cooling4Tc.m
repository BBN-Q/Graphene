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
function CoolLogData = Cooling4Tc()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear temp StartTime start_dir CoolLogData;
close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.CryoCon22();
TC.connect('12');
Lockin = deviceDrivers.SRS830();
Lockin.connect('9');

% Initialize variables
DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = 'C:\Users\qlab\Documents\Graphene Data\';
start_dir = pwd;
StartTime = clock;
FileName = strcat('Cool4Tc_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
%FilePtr = fopen(fullfile(start_dir, FileName), 'w');
%fprintf(FilePtr, strcat(datestr(StartTime), ' CoolLog using CryoCon\r\n'));
%fprintf(FilePtr,'Time_s\tTemperature_K\tLockinX\tLockinY\r\n');
%fclose(FilePtr);

% temperature log loop
j=1;
pause on;
figure(234);
while true
    CoolLogData.time(j) = etime(clock, StartTime);
    CoolLogData.T(j) = TC.temperatureA(); %QueryT_CryoCon();
    %LockinV = QueryXY_Lockin(9);
    CoolLogData.X(j) = Lockin.X; CoolLogData.Y(j) = Lockin.Y;
    %CoolLogData(j,:) = [etime(clock, StartTime) TC.temperatureA() Lockin.X() Lockin.Y()];
    pause(DataInterval);
    save(FileName);
    clf; plot(CoolLogData.T, CoolLogData.X, '.-'); grid on; ylabel('Lockin X (V)'); xlabel('Temperature (K)'); title(strcat('Cooling for Tc, start date and time: ', datestr(StartTime)));
    %figure(233); clf; plot(CoolLogData.time, CoolLogData.T, '.-'); grid on; xlabel('time (s)'); ylabel('T (K)');
    j = j+1;
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TC.disconnect(); Lockin.disconnect();
clear Lockin TC;
end