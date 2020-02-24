%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using CryoCon Temperature Controller
% Created in May 2014 by Jesse Crossno and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CoolLogData = LakeShore335_CoolLog()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear temp StartTime start_dir CoolLogData;
close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.Lakeshore335();

% Initialize variables
DataInterval = input('Time interval in temperature readout (in second) = ');
TimeLimit = input('Running time limit (in hour) = ');
start_dir = 'C:\Users\qlab\Documents\Data\HydroTwist\CoolLog';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat(start_dir, '\CoolLog_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
%FilePtr = fopen(fullfile(start_dir, FileName), 'w');
%fprintf(FilePtr, strcat(datestr(StartTime), ' CoolLog using LakeShore\r\n'));
%fprintf(FilePtr,'Time_s\tTemperature_K\r\n');
%fclose(FilePtr);

% temperature log loop
j=1;
figure; pause on;
CoolLogData.time(1) = 0;
while TimeLimit > CoolLogData.time(end)/3600
    TC.connect('2');
    CoolLogData.time(j) = etime(clock, StartTime);
    CoolLogData.T(j) = TC.get_temperature('A');
    TC.disconnect();
    pause(DataInterval);
    %FilePtr = fopen(fullfile(start_dir,  FileName), 'a');
    %fprintf(FilePtr,'%0.3f\t%f\r\n',CoolLogData(j,:));
    %fclose(FilePtr);
    save(FileName);
    plot(CoolLogData.time/60, CoolLogData.T); grid on; xlabel('Time (min.)'); ylabel('Temperature (K)'); title(strcat('CoolLog using LakeShore335, start date and time: ', datestr(StartTime)));
    j = j+1;
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear TC;