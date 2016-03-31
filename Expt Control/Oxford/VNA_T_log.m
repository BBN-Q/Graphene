%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using LakeShore Temperature Controller while taking VNA data
% in Oxford fridge at KimLab
% Created in Mar 2014 by Jesse Crossno and KC Fong and Evan Walsh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = VNA_T_log()

clear temp StartTime start_dir CoolLogData;
close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.Lakeshore335();
TC.connect('12');

% Connect to the VNA
VNA = deviceDrivers.AgilentE8363C();
VNA.connect('140.247.189.97')

%connect lockin amplifier
LA = deviceDrivers.SRS830();
LA.connect('8')

% Initialize variables
VNAInterval = input('Temperature interval between VNA measurements (in K) = ');
TempInterval = input('Time interval between temperature measurements (in second) = ');
UniqueName = input('Enter uniquie file identifier: ','s');
start_dir = 'C:\Crossno\data\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('VNAlog_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');


% Initialize VNA Data
data.VNA=struct('time',[],'tempVapor',[],'tempProbe',[],'traces',[],'LA_X',[],'LA_Y',[],'R',[]);

% Log Loop
figure(991);hold all;
data.VNA.freq = VNA.getX();
T_n = 1;
VNA_n = 1;
pause on;
figure(991); clf; xlabel('Frequency (MHz)');ylabel('S11^2'); hold all; grid on;
VNA_meas_temp=TC.get_temperature('B');
while true
    data.time(T_n) = etime(clock, StartTime);
    data.tempVapor(T_n) = TC.get_temperature('A');
    data.tempProbe(T_n) = TC.get_temperature('B');
    data.LA_X(T_n) = LA.X();
    data.LA_Y(T_n) = LA.Y();
    data.R(T_n) = data.LA_X(T_n)*1E7;
    
    if abs(data.tempProbe(T_n)-VNA_meas_temp) > VNAInterval;
        data.VNA.time(VNA_n) = data.time(T_n);
        data.VNA.tempVapor(VNA_n) = data.tempVapor(T_n);
        data.VNA.tempProbe(VNA_n) = data.tempVapor(T_n);
        data.VNA.traces(VNA_n,:) = VNA.getSingleTrace();
        
        
        plot(data.VNA.freq*1E-6,20*log10(abs(data.VNA.traces(VNA_n,:))));
        
        VNA_n = VNA_n + 1;
        VNA_meas_temp = data.tempProbe(T_n);
    end
    
    save(fullfile(start_dir, FileName),'data')

    figure(992); clf; xlabel('time (min)');ylabel('Temperature (K)'); 
    grid on; hold on;
    plot(data.time/60,data.tempVapor,'r')
    plot(data.time/60,data.tempProbe,'b')
    legend('Vapor','Probe')
    
    figure(993); clf; xlabel('Probe Temperature (K)');ylabel('Resistance (\Omega)'); 
    grid on; hold on;
    plot(data.tempProbe,data.R,'b')
    
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