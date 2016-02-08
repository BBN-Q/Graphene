%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Provides bias current for JJ. Resets current when JJ switches from
% superconducting state to resistive state. Outputs JJ voltage as a
% function of time. Yokogawa GS200 provides bias current. Keithley 2400
% measures JJ voltage. Keithley 2400 provides gate voltage.
% 
% Evan Walsh, January 2016 (evanwalsh@seas.harvard.edu)

function JJ_switch_data=JJ_switch_module(LoadResistor,Vb,WaitTime,RunTime,Vthresh,Vreset,ResetTime,VG,tag)

% temp = instrfind;
% if ~isempty(temp)
%     fclose(temp)
%     delete(temp)
% end
clear JJ_switch_data;
%close all;
% fclose all;

% Connect to Instruments
KGate=deviceDrivers.Keithley2400();
KGate.connect('24');
KMeas=deviceDrivers.Keithley2400();
KMeas.connect('23');
Yoko=deviceDrivers.YokoGS200;
Yoko.connect('2');

StartTime = clock;
FileName = strcat('VJJ_vs_Time_with_Switch_', datestr(StartTime, 'yyyymmdd_HHMMSS_'), tag,'.mat');

JJ_switch_data = struct('Time',[],'VJJ',[],'Clicks',0,'VG',VG,'Ib',Vb/LoadResistor,'Ireset',Vreset/LoadResistor,'Vthresh',Vthresh);

figure;
pause on
save_flag=0;
i=1;
Yoko.value=Vb;
JJ_switch_data.Time(1)=0;
JJ_switch_data.VJJ(1)=KMeas.value;
tic
temp_time=toc;
while temp_time<RunTime
    pause(WaitTime)
    drawnow;
    i=i+1;
    VJJ_temp=KMeas.value;
    temp_time = toc;
    JJ_switch_data.Time(i)=temp_time;
    JJ_switch_data.VJJ(i)=VJJ_temp;
    if VJJ_temp>Vthresh
        Yoko.value=Vreset;
        pause(ResetTime);
        Yoko.value=Vb;
        JJ_switch_data.Clicks=JJ_switch_data.Clicks+1;
    end
    plot(JJ_switch_data.Time/60,JJ_switch_data.VJJ/10^-3); grid on; xlabel('Time (min)'); ylabel('JJ Voltage (mV)');
    %Save every 10 mins
    if save_flag+toc>600
        save(FileName,'JJ_switch_data')
        save_flag=save_flag-600;
    end
end
%Final Save
save(FileName,'JJ_switch_data')

%Disconnect from instruments
KMeas.disconnect();
KGate.disconnect();
Yoko.disconnect();
clear KMeas
clear KGate
clear Yoko
end
    
    


