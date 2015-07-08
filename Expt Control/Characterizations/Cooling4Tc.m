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
Lockin.connect('7');

% Initialize variables
DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = 'C:\Users\qlab\Documents\Graphene Data\3K Fridge CoolLog Repository\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('CoolLog_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' CoolLog using CryoCon\r\n'));
fprintf(FilePtr,'Time_s\tTemperature_K\tLockinX\tLockinY\r\n');
fclose(FilePtr);

% temperature log loop
j=1;
figure; pause on;
while true
    CoolLogData(j,:) = [etime(clock, StartTime) TC.temperatureA() Lockin.X() Lockin.Y()];
    pause(DataInterval);
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    fprintf(FilePtr,'%0.3f\t%e\t%e\t%e\r\n',CoolLogData(j,:));
    fclose(FilePtr);
    clf; plot(CoolLogData(:,2), CoolLogData(:,3)); grid on; ylabel('Lockin X (V)'); xlabel('Temperature (K)'); title(strcat('Cooling for Tc, start date and time: ', datestr(StartTime)));
    j = j+1;
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TC.disconnect(); Lockin.disconnect();
clear TC, Lockin;