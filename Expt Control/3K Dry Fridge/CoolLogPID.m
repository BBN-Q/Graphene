%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Monitoring PID and Temperature
% Created in May 2014 by KC Fong
% Adapted April 2021 - Caleb Fried
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CoolLogData1 = CoolLogPID()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear temp StartTime start_dir CoolLogData;
close all;
fclose all;

% Initialize variables
DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = 'C:\Users\qlab\Documents\data\CoolLog\';
start_dir = uigetdir(start_dir);
cd(start_dir);
StartTime = clock;
FileName = strcat('CoolLogPID_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');

% temperature log loop
j=1;
figure; pause on;
while j < 36000*10/10
    TController = deviceDrivers.Lakeshore335();
    TController.connect('2');
    CoolLogData1.time(j) = etime(clock, StartTime);
    CoolLogData1.T(j) = TController.get_temperature('A');
    CoolLogData1.PID(j,:) = str2num(TController.get_pid(2));
    TController.disconnect();
    save(FileName);
    figure(1); clf; 
    subplot(3,2,[1,3,5]);
    plot(CoolLogData1.time/60, CoolLogData1.T, '.-'); grid on; xlabel('Time (min)'); ylabel('Temperature (K)'); title(strcat('Cooling for Tc, ', datestr(StartTime)));
    subplot(3,2,2);
    plot(CoolLogData1.time/60, CoolLogData1.PID(:,1), '.-'); grid on; xlabel('Time (min)'); ylabel('P (W/K)'); title('Proportional term (P)');
    subplot(3,2,4);
    plot(CoolLogData1.time/60, CoolLogData1.PID(:,2), '.-'); grid on; xlabel('Time (min)'); ylabel('I (1/s)'); title('Integral term (I)');
    subplot(3,2,6);
    plot(CoolLogData1.time/60, CoolLogData1.PID(:,3), '.-'); grid on; xlabel('Time (min)'); ylabel('D (s)'); title('Derivative term (D)');
    pause(DataInterval);
    j = j+1;
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear TController;