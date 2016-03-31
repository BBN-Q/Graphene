%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using LakeShore Temperature Controller while taking VNA data
% in Oxford fridge at KimLab
% Created in Mar 2014 by Jesse Crossno and KC Fong and Evan Walsh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function VNA_log = VNA_log()

clear temp StartTime start_dir CoolLogData;
close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.Lakeshore335();
TC.connect('12');

% Connect to the VNA
VNA = deviceDrivers.AgilentE8363C();
VNA.connect('140.247.189.60')

% Initialize variables
VNAInterval = input('Time interval between VNA measurements (in second) = ');
TempInterval = input('Time interval between temperature measurements (in second) = ');
UniqueName = input('Enter uniquie file identifier: ','s');
start_dir = 'C:\Crossno\data\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('VNAlog_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');


% Initialize VNA Data
data.VNA=struct('time',[],'tempVapor',[],'tempProbe',[],'traces',[]);

% Log Loop
T_n = 1;
VNA_n = 1;
pause on;
figure(991); clf; xlabel('Frequency (MHz)');ylabel('S11^2'); hold all; grid on;
VNA_timer=clock;
while true
    data.time(T_n) = etime(clock, StartTime);
    data.tempVapor(T_n) = TC.get_temperature('A');
    data.tempProbe(T_n) = TC.get_temperature('B');
    
    if etime(clock, VNA_timer) > VNAInterval;
        data.VNA.time(VNA_n) = data.time(T_n);
        data.VNA.tempVapor(VNA_n) = data.tempVapor(T_n);
        data.VNA.tempProbe(VNA_n) = data.tempVapor(T_n);
        data.VNA.traces(VNA_n,:,:) = VNA.getAllTraces();
        
        figure(991);
        plot(data.VNA.traces(VNA_n,:,1)*1E-6,20*log10(abs(data.VNA.traces(VNA_n,:,2))));
        plot(data.VNA.traces(VNA_n,:,1)*1E-6,20*log10(abs(data.VNA.traces(VNA_n,:,3))));
        
        VNA_n = VNA_n + 1;
        VNA_timer = clock;
    end
    
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
VNA.disconnect();
clear TC;
clear VNA;