%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Monitors trigger voltage measured by Keithley 2400 for JJ switching
% experiments.
% 
% Evan Walsh, January 2016 (evanwalsh@seas.harvard.edu)

function Trig_monitor_data=Trig_monitor()

temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear Trig_monitor_data;
%close all;
fclose all;

% Connect to Instruments
KMeas=deviceDrivers.Keithley2400();
KMeas.connect('23');

StartTime = clock;
FileName = strcat('VTrig_vs_Time_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');

% User Inputs
prompt = 'What is the additional time per measurement (s)? ';
WaitTime = input(prompt);
prompt = 'What is the total run time (s)? ';
RunTime = input(prompt);
prompt = 'What is the (negative slope) threshold voltage (V)? ';
Vthresh = input(prompt);
prompt = 'What is the bias voltage (V)? ';
Vb = input(prompt);
prompt = 'What is the reset voltage (V)? ';
Vreset = input(prompt);
prompt='What is the load resistor (ohm)? ';
LoadResistor = input(prompt);
prompt = 'What is the gate voltage (V)? ';
VG = input(prompt);

Trig_monitor_data = struct('Time',[],'VJJ',[],'Clicks',0,'VG',VG,'Ib',Vb/LoadResistor,'Ireset',Vreset/LoadResistor,'Vthresh',Vthresh);

figure;
pause on
save_flag=0;
i=1;
Trig_monitor_data.Time(i)=0;
Trig_monitor_data.VJJ(i)=KMeas.value;
tic
temp_time=toc;
while temp_time<RunTime
    pause(WaitTime);
    drawnow;
    i=i+1;
    VJJ_temp=KMeas.value;
    temp_time = toc;
    Trig_monitor_data.Time(i)=temp_time;
    Trig_monitor_data.VJJ(i)=VJJ_temp;
    if VJJ_temp<Vthresh
        Trig_monitor_data.Clicks=Trig_monitor_data.Clicks+1;
    end
    plot(Trig_monitor_data.Time/60,Trig_monitor_data.VJJ); grid on; xlabel('Time (min)'); ylabel('Trigger Voltage (V)');
    %Save every 10 mins
    if save_flag+toc>600
        save(FileName,'Trig_monitor_data')
        save_flag=save_flag-600;
    end
end
%Final Save
save(FileName,'Trig_monitor_data')

%Disconnect from instruments
KMeas.disconnect();
clear KMeas
end