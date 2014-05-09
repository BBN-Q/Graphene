%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using CryoCon Temperature Controller
% Created in May 2014 by Jesse Crossno and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CoolLogData = LoggingFluctuation()
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
DVM = deviceDrivers.Keithley197();


% Initialize variables
DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = 'C:\Users\qlab\Documents\Graphene Data\3K Fridge CoolLog Repository\';
start_dir = uigetdir(start_dir)
StartTime = clock;
FileName = strcat('LogFluctuation_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' CoolLog using CryoCon\r\n'));
fprintf(FilePtr,'Time_s\tTemperature_K\tMultiplierV_V\r\n');
fclose(FilePtr);

% temperature log loop
j=1;
figure;
while true
    TC.connect('12'); DVM.connect('19');
    CoolLogData(j,:) = [etime(clock, StartTime) TC.temperatureA() str2num(DVM.value())];
    TC.disconnect(); DVM.disconnect();
    pause(DataInterval);
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    fprintf(FilePtr,'%0.3f\t%f\t%f\r\n',CoolLogData(j,:));
    fclose(FilePtr);
    plotyy(CoolLogData(:,1)/60, CoolLogData(:,2), CoolLogData(:,1)/60, CoolLogData(:,3)); grid on; xlabel('Time (min.)'); ylabel('Temperature (K)'); title(strcat('Tracking fluctuation using CryoCon and DVM, start date and time: ', datestr(StartTime)));
    j = j+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear TC;