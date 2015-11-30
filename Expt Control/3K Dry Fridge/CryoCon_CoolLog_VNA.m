%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using CryoCon Temperature Controller while taking VNA data
% Edited in September 2015 by Evan Walsh
% Created in May 2014 by Jesse Crossno and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CoolLogData = CryoCon_CoolLog_VNA()
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

% Connect to the VNA
VNA = deviceDrivers.AgilentE8363C();
VNA.connect('192.168.5.101')

% Initialize variables
DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = 'C:\Users\qlab\Documents\Graphene Data\3K Fridge CoolLog Repository\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('CoolLog_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' CoolLog using CryoCon\r\n'));
fprintf(FilePtr,'Time_s\tTemperature_K\r\n');
fclose(FilePtr);

% Initialize VNA Data
VNA_Data=struct('temp',[],'freq',[],'trace',[]);

% Temperature Log Loop
j=1;
figure; pause on;
while true
    CoolLogData(j,:) = [etime(clock, StartTime) TC.temperatureA()];
    [VNA_Data.freq, VNA_Data.trace(j,:)]=VNA.getTrace();
    VNA_Data.temp(j)=TC.temperatureA();
    FileName2 = strcat('VNA_Temp_Log_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
    save(FileName2,'VNA_Data')
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    fprintf(FilePtr,'%0.3f\t%f\r\n',CoolLogData(j,:));
    fclose(FilePtr);
    plot(CoolLogData(:,1)/60, CoolLogData(:,2)); grid on; xlabel('Time (min.)'); ylabel('Temperature (K)'); title(strcat('CoolLog using CryoCon, start date and time: ', datestr(StartTime)));
    j = j+1;
    pause(DataInterval);
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TC.disconnect();
VNA.disconnect();
clear TC;
clear VNA;