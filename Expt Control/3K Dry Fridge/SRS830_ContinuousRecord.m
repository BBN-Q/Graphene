%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using CryoCon Temperature Controller
% Created in May 2014 by Jesse Crossno and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CoolLogData = SRS830_ContinuousRecord()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear temp StartTime start_dir CoolLogData;
close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
SRS = deviceDrivers.SRS830();
SRS.connect('8');

% Initialize variables
DataInterval = input('Time interval between measurment (in second) = ');
FileNumber = input('file nnumber used as suffix = ','s');
start_dir = 'C:\Users\qlab\Documents\data\Graphene Data';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('SRS830_', datestr(StartTime, 'yyyymmdd_HHMMSS'),FileNumber, '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Lockin Values using SRS830\r\n'));
fprintf(FilePtr,'Time_s\tX\tY\tR\tTheta\r\n');
fclose(FilePtr);

% temperature log loop
j=1;
figure; pause on;
while true
    SRSData(j,:) = [etime(clock, StartTime) SRS.X() SRS.Y() SRS.R() SRS.theta()];
    pause(DataInterval);
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    fprintf(FilePtr,'%0.3f\t%f\t%f\t%f\t%f\r\n',SRSData(j,:));
    fclose(FilePtr);
    clf
    plot(SRSData(:,1)/60, SRSData(:,2)); grid on; xlabel('Time (min.)'); ylabel('X & Y (V)'); title(strcat('SRS830 Lockin Monitor, start date and time: ', datestr(StartTime)));
    hold all
    plot(SRSData(:,1)/60, SRSData(:,2));
    j = j+1;
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SRS.disconnect();
clear TC;