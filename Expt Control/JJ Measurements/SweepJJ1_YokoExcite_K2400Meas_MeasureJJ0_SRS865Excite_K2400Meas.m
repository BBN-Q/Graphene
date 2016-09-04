function CrossTalk_data = SweepJJ1_YokoExcite_K2400Meas_MeasureJJ0_SRS865Excite_K2400Meas(RunTime,LoadResistor0, Vb0, Vthresh0, Vreset0, ResetTime0, LoadResistor1, Vstart1, Vend1, Vstep1, RampTime1, Vreset1, ResetTime1, VG, tag)
%UNTITLED2 Summary of this function goes here
%   Sweeps JJ1 looking for switching as a function of time in JJ0.

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

[JJ1_V_Array, JJ1_steps]=V_Array(Vstart1,Vend1,Vstep1,0);

CrossTalk_data = struct('VG',VG,'Time',[],'VJJ0',[],'VJJ1',[],'Clicks0',0,'Ib0',Vb0/LoadResistor0,'Ireset0',Vreset0/LoadResistor0,'Vthresh0',Vthresh0,'JJ1_V_Array',JJ1_V_Array,'Ireset1',Vreset1/LoadResistor1,'Ramps',0);

figure;
pause on
save_flag=0;

Lockin.DC=Vb0;
Yoko.value=JJ1_V_Array(1);
CrossTalk_data.Time(1)=0;
CrossTalk_data.VJJ0(1)=KMeasJJ0.value;
CrossTalk_data.VJJ1(1)=KMeasJJ1.value;
tic

i=0;
temp_time=toc;
while temp_time<RunTime
    i=i+1;
    for j=1:JJ1_steps
        Yoko.value=JJ1_V_Array(j);
        pause(RampTime1)
        drawnow;

        VJJ_temp0=KMeasJJ0.value;
        VJJ_temp1=KMeasJJ1.value;    
        temp_time = toc;
        
        CrossTalk_data.Time((i-1)*JJ1_steps+j+1)=temp_time;
        CrossTalk_data.VJJ0((i-1)*JJ1_steps+j+1)=VJJ_temp0;
        CrossTalk_data.VJJ1((i-1)*JJ1_steps+j+1)=VJJ_temp1;
        
        if VJJ_temp0>Vthresh0
            Lockin.DC=Vreset0;
            pause(ResetTime0);
            Lockin.DC=Vb0;
            CrossTalk_data.Clicks0=CrossTalk_data.Clicks0+1;
        end
        subplot(2,1,1)
        plot(CrossTalk_data.Time/60,CrossTalk_data.VJJ0/10^-3); grid on; xlabel('Time (min)'); ylabel('JJ Voltage (mV)');
        subplot(2,1,2)
        plot(CrossTalk_data.Time/60,CrossTalk_data.VJJ1/10^-3); grid on; xlabel('Time (min)'); ylabel('JJ Voltage (mV)');
    end
    %Save every 10 mins
    if save_flag+toc>600
        save(FileName,'CrossTalk_data')
        save_flag=save_flag-600;
    end
    CrossTalk_data.Ramps=i;
    Yoko.value=Vreset1;
    pause(ResetTime1);
    Yoko.value=Vstart1;
end
%Final Save
save(FileName,'CrossTalk_data')

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

