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
FileName = strcat('Tlog_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');


% Initialize VNA Data
data=struct('time',[],'T_A',[],'T_B',[]);

% Log Loop

T_n = 1;
pause on;


data.time(T_n) = etime(clock, StartTime);
data.T_A(T_n) = TC.temperatureA();
data.T_B(T_n) = TC.temperatureB();

save(fullfile(start_dir, FileName),'data')

figure(992); clf; xlabel('time (min)');ylabel('Temperature (K)'); 
grid on; hold on;
myplot=plot(data.time/60,data.T_A,data.time/60,data.T_B);
plot1=myplot(1);
plot2=myplot(2);

T_n = T_n+1;
pause(TempInterval);



while true
    data.time(T_n) = etime(clock, StartTime);
    data.T_A(T_n) = TC.temperatureA();
    data.T_B(T_n) = TC.temperatureB();
    
    save(fullfile(start_dir, FileName),'data')

    %figure(992); clf; xlabel('time (min)');ylabel('Temperature (K)'); 
    %grid on; hold on;1
    set(plot1,'XData',data.time/60,'YData',data.T_A);
    set(plot2,'XData',data.time/60,'YData',data.T_B);
   % plot(,,data.time/60,data.T_B)
    
    T_n = T_n+1;
    pause(TempInterval);
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TC.disconnect();
clear TC;