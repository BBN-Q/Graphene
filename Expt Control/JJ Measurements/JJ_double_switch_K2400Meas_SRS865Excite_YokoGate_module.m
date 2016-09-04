%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Provides bias current for JJ. Resets current when JJ switches from
% superconducting state to resistive state. Outputs JJ voltage as a
% function of time. Yokogawa GS200 provides bias current. Keithley 2400
% measures JJ voltage. Keithley 2400 provides gate voltage.
% 
% Evan Walsh, January 2016 (evanwalsh@seas.harvard.edu)

function JJ_switch_data=JJ_double_switch_K2400Meas_SRS865Excite_YokoGate_module(LoadResistor0,LoadResistor1,Vb,WaitTime,RunTime,Vthresh0,Vthresh1,Vreset,ResetTime,VG,tag)

% temp = instrfind;
% if ~isempty(temp)
%     fclose(temp)
%     delete(temp)
% end
clear JJ_switch_data;
%close all;
% fclose all;

% Connect to Instruments
Yoko=deviceDrivers.YokoGS200();
Yoko.connect('2');
KMeasJJ0=deviceDrivers.Keithley2400();
KMeasJJ0.connect('23');
KMeasJJ1=deviceDrivers.Keithley2400();
KMeasJJ1.connect('24');
Lockin=deviceDrivers.SRS865;
Lockin.connect('9');

StartTime = clock;
FileName = strcat('VJJ_vs_Time_with_Switch_', datestr(StartTime, 'yyyymmdd_HHMMSS_'), tag,'.mat');

JJ_switch_data = struct('VG',VG,'Time',[],'VJJ0',[],'VJJ1',[],'Clicks0',0,'Ib0',Vb/LoadResistor0,'Ireset0',Vreset/LoadResistor0,'Vthresh0',Vthresh0,'Clicks1',0,'Ib1',Vb/LoadResistor1,'Ireset1',Vreset/LoadResistor1,'Vthresh1',Vthresh1,'Coincidences',0);

figure;
pause on
save_flag=0;
i=1;
Lockin.DC=Vb;
JJ_switch_data.Time(1)=0;
JJ_switch_data.VJJ0(1)=KMeasJJ0.value;
JJ_switch_data.VJJ1(1)=KMeasJJ1.value;
tic
temp_time=toc;
while temp_time<RunTime
    coincidence_flag=0;
    pause(WaitTime)
    drawnow;
    i=i+1;
    VJJ_temp0=KMeasJJ0.value;
    VJJ_temp1=KMeasJJ1.value;    
    temp_time = toc;
    JJ_switch_data.Time(i)=temp_time;
    JJ_switch_data.VJJ0(i)=VJJ_temp0;
    JJ_switch_data.VJJ1(i)=VJJ_temp1;    
    if VJJ_temp0>Vthresh0 || VJJ_temp1>Vthresh1
        Lockin.DC=Vreset;
        pause(ResetTime);
        Lockin.DC=Vb;
        if VJJ_temp0>Vthresh0
            JJ_switch_data.Clicks0=JJ_switch_data.Clicks0+1;
            coincidence_flag=1;
        end
        if VJJ_temp1>Vthresh1
            JJ_switch_data.Clicks1=JJ_switch_data.Clicks1+1;
            if coincidence_flag==1
                JJ_switch_data.Coincidences=JJ_switch_data.Coincidences+1;
            end
        end
    end
    subplot(2,1,1)
    plot(JJ_switch_data.Time/60,JJ_switch_data.VJJ0/10^-3); grid on; xlabel('Time (min)'); ylabel('JJ Voltage (mV)');
    subplot(2,1,2)
    plot(JJ_switch_data.Time/60,JJ_switch_data.VJJ1/10^-3); grid on; xlabel('Time (min)'); ylabel('JJ Voltage (mV)');
    %Save every 10 mins
    if save_flag+toc>600
        save(FileName,'JJ_switch_data')
        save_flag=save_flag-600;
    end
end
%Final Save
save(FileName,'JJ_switch_data')

%Disconnect from instruments
KMeasJJ0.disconnect();
KMeasJJ1.disconnect();
Yoko.disconnect();
Lockin.disconnect();
clear KMeasJJ0
clear KMeasJJ1
clear KGate
clear Lockin
end
    
    


