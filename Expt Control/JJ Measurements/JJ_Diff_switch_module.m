%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Provides bias current for JJ. Resets current when JJ switches from
% superconducting state to resistive state. Outputs differential JJ voltage as a
% function of time. SRS865 provides bias current and measures differential 
% JJ voltage. Keithley 2400 provides gate voltage.
% 
% Evan Walsh, January 2016 (evanwalsh@seas.harvard.edu)

function JJ_switch_data=JJ_Diff_switch_module(LoadResistor,Vb,WaitTime,RunTime,Vthresh,Vreset,ResetTime,VG,tag)
%For differential measurement, reset time occurs twice - once upon setting
%Vreset, once upon setting Vbias (so actual time for one reset cycle =
%2*ResetTime)


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
Lockin = deviceDrivers.SRS865();
Lockin.connect('9');

StartTime = clock;
FileName = strcat('VJJ_vs_Time_with_Switch_', datestr(StartTime, 'yyyymmdd_HHMMSS_'), tag,'.mat');

JJ_switch_data = struct('Time',[],'VJJ',[],'Clicks',0,'VG',VG,'Ib',Vb/LoadResistor,'Ireset',Vreset/LoadResistor,'Vthresh',Vthresh);

figure;
pause on
save_flag=0;
i=1;
Lockin.DC=Vb;
JJ_switch_data.Time(1)=0;
%Reset JJ if already switched
JJ_switch_data.VJJ(1)=Lockin.R;
    if JJ_switch_data.VJJ(1)>Vthresh
        Lockin.DC=Vreset;
        pause(ResetTime);
        Lockin.DC=Vb;
        pause(ResetTime);
    end
JJ_switch_data.VJJ(1)=Lockin.R;

tic
temp_time=toc;
while temp_time<RunTime
    pause(WaitTime)
    drawnow;
    i=i+1;
    VJJ_temp=Lockin.R;
    temp_time = toc;
    JJ_switch_data.Time(i)=temp_time;
    JJ_switch_data.VJJ(i)=VJJ_temp;
    if VJJ_temp>Vthresh
        Lockin.DC=Vreset;
        pause(ResetTime);
        Lockin.DC=Vb;
        pause(ResetTime);
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
KGate.disconnect();
Lockin.disconnect();
clear KGate
clear Lockin
end
    
    


