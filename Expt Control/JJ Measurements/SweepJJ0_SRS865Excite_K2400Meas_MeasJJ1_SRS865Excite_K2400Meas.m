function CrossTalk_data = SweepJJ0_SRS865Excite_K2400Meas_MeasJJ1_SRS865Excite_K2400Meas(RunTime,LoadResistor0, Vstart0, Vend0, Vstep0, RampTime0, Vreset0, LoadResistor1, Vb1, Vthresh1, Vreset1, ResetTime1, VG, tag)
%UNTITLED2 Summary of this function goes here
%   Sweeps JJ1 looking for switching as a function of time in JJ0.

% Connect to Instruments
KMeasJJ0=deviceDrivers.Keithley2400();
KMeasJJ0.connect('23');
KMeasJJ1=deviceDrivers.Keithley2400();
KMeasJJ1.connect('24');
LockinJJ0=deviceDrivers.SRS865;
LockinJJ0.connect('10');
LockinJJ1=deviceDrivers.SRS865;
LockinJJ1.connect('9');

StartTime = clock;
FileName = strcat('VJJ_vs_Time_with_Switch_', datestr(StartTime, 'yyyymmdd_HHMMSS_'), tag,'.mat');

[JJ0_V_Array, JJ0_steps]=V_Array(Vstart0,Vend0,Vstep0,0);

CrossTalk_data = struct('VG',VG,'Time',[],'VJJ0',[],'VJJ1',[],'Clicks1',0,'Ib1',Vb1/LoadResistor0,'Ireset1',Vreset1/LoadResistor1,'Vthresh1',Vthresh1,'JJ0_V_Array',JJ0_V_Array,'Ireset0',Vreset0/LoadResistor0,'Ramps',0);

figure;
pause on
save_flag=0;

LockinJJ1.DC=Vb1;
LockinJJ0.DC=JJ0_V_Array(1);
CrossTalk_data.Time(1)=0;
CrossTalk_data.VJJ0(1)=KMeasJJ0.value;
CrossTalk_data.VJJ1(1)=KMeasJJ1.value;
tic

i=0;
temp_time=toc;
while temp_time<RunTime
    i=i+1;
    for j=1:JJ0_steps
        LockinJJ0.DC=JJ0_V_Array(j);
        pause(RampTime0)
        drawnow;

        VJJ_temp0=KMeasJJ0.value;
        VJJ_temp1=KMeasJJ1.value;    
        temp_time = toc;
        
        CrossTalk_data.Time((i-1)*JJ0_steps+j+1)=temp_time;
        CrossTalk_data.VJJ0((i-1)*JJ0_steps+j+1)=VJJ_temp0;
        CrossTalk_data.VJJ1((i-1)*JJ0_steps+j+1)=VJJ_temp1;
        
        if VJJ_temp1>Vthresh1
            LockinJJ1.DC=Vreset1;
            pause(ResetTime1);
            LockinJJ1.DC=Vb1;
            CrossTalk_data.Clicks1=CrossTalk_data.Clicks1+1;
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
    LockinJJ0.DC=Vreset0;
    pause(ResetTime1);
    LockinJJ0.DC=Vstart0;
end
%Final Save
save(FileName,'CrossTalk_data')

%Disconnect from instruments
KMeasJJ0.disconnect();
KMeasJJ1.disconnect();
LockinJJ0.disconnect();
LockinJJ1.disconnect();
clear KMeasJJ0
clear KMeasJJ1
clear LockinJJ0
clear LockinJJ1

end

