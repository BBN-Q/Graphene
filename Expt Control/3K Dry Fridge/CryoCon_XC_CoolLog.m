%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using CryoCon Temperature Controller
% Created in May 2014 by Jesse Crossno and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CoolLogData = CryoCon_XC_CoolLog()
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

%Connect to Lockin
Lockin = deviceDrivers.SRS830();

% Initialize variables
DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = 'C:\Users\qlab\Documents\data\3K_CoolLogs';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('CoolLog_and_XC_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' CoolLog using CryoCon and XC @ 1s\r\n'));
fprintf(FilePtr,'Time_s\tTemperature_K\tLockinX_V\tLockinY_V\r\n');
fclose(FilePtr);

% temperature log loop
j=1;
figure; pause on;
while true
    TC.connect('12');
    Lockin.connect('8');
    CoolLogData(j,:) = [etime(clock, StartTime) TC.temperatureA() Lockin.X Lockin.Y];
    TC.disconnect();
    Lockin.disconnect();
    pause(DataInterval);
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    fprintf(FilePtr,'%0.3f\t%f\t%E\t%E\r\n',CoolLogData(j,:));
    fclose(FilePtr);
    [hAx,hLine1,hLine2] = plotyy(CoolLogData(:,1)/60, CoolLogData(:,2), CoolLogData(:,1)/60, CoolLogData(:,3)); 
    grid on; xlabel('Time (min.)'); title(strcat('CoolLog using CryoCon, start date and time: ', datestr(StartTime)));
    ylabel(hAx(1),'Temperature (K)');
    ylabel(hAx(2),'Lockin XC (V)');
    j = j+1;
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear TC Lockin;