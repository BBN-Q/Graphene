%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using LakeShore Temperature Controller while taking VNA data
% in Oxford fridge at KimLab
% Created in Mar 2014 by Jesse Crossno and KC Fong and Evan Walsh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = Lakeshore_T_log()

clear temp StartTime start_dir CoolLogData;
close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.Lakeshore335();
TC.connect('12');


% Initialize variables
TempInterval = input('Time interval between temperature measurements (in second) = ');
UniqueName = input('Enter uniquie file identifier: ','s');
start_dir = 'C:\Crossno\data\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('VNAlog_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');


% Initialize VNA Data
data.VNA=struct('time',[],'tempVapor',[],'tempProbe',[]);

% Log Loop

T_n = 1;
pause on;
while true
    data.time(T_n) = etime(clock, StartTime);
    data.tempVapor(T_n) = TC.get_temperature('A');
    data.tempProbe(T_n) = TC.get_temperature('B');
    
    save(fullfile(start_dir, FileName),'data')

    figure(992); clf; xlabel('time (min)');ylabel('Temperature (K)'); 
    grid on; hold on;
    plot(data.time/60,data.tempVapor,'r')
    plot(data.time/60,data.tempProbe,'b')
    legend('Vapor','Probe')
    
    T_n = T_n+1;
    pause(TempInterval);
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TC.disconnect();
clear TC;