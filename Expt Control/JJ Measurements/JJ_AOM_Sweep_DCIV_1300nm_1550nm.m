function Power_sweep_data = JJ_AOM_Sweep_DCIV_1300nm_1550nm
%Sweeps RF Power input to AOM, takes switching data from JJ with NIDAQ

%Last File
lastfile=1190;

%Fixed Attenuation before Fridge in dB
dB=10;

%Gate Voltage (Just a Label, Not a Setter)
VG=20;

%Bias Current
Ib=2.95e-6;

%Comparator plus switch thresholds
highthresh=0.49; %Use for critical current measurement
lowthresh=0.09; %Use for switching measurements

%NIDAQ Parameters
sampling_rate=50000;
time_total=1200;
time_plot=10;
Vthresh=0.065;

%Start Time and File Name
StartTime = clock;
FileName1 = strcat('Power_Sweep_Data_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'.mat');

%Connect to RF Source, Laser, Yoko (comparator threshold), Lockin (bias
%current)
RFsource=deviceDrivers.AgilentN5183A;
RFsource.connect('19');
Laser=deviceDrivers.HP8153A;
Laser.connect('20');
Yoko=deviceDrivers.YokoGS200;
Yoko.connect('2');
Lockin=deviceDrivers.SRS865;


% RFPower1300 = [-20, -10.24, -3.50, -0.95, 0.62, 1.77, 2.68, 3.43, 4.04, 4.59, 5.10, 5.53, 5.91, 6.30, 6.64, 6.95, 7.25, 7.50, 7.77, 8.04, 8.38]; 
% RFPower1550 = [-20, -15.23, -12.10, -10.30, -9.04, -8.05, -7.26, -6.59, -6.00, -5.49, -5.02, -4.61, -4.23, -3.87, -3.56, -3.26, -2.97, -2.70, -2.45, -2.22, -1.99];
% LaserPower = (0:100:2000)*1e-12*10^(-dB/10);

RFPower1300 = [8.38, 10.13, 11.38, 12.37, 13.17, 13.82, 14.42, 14.94, 15.39, 18.45, 20.21, 21.49];
RFPower1550 = [-1.99, -.024, 1.01, 1.98, 2.77, 3.44, 4.02, 4.54, 4.99, 8.02, 9.79, 11.04];
LaserPower = [2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40]*1e-9*10^(-dB/10);

Power_sweep_data=struct('Power',LaserPower,'Rate1300',[],'Rate1550',[],'Ic1300',[],'Ic1550',[],'Ib',Ib,'VG',VG);




Ibstring=strrep(num2str(Ib/10^-6),'.','p');
    
    for j=1:length(LaserPower)
        powerstring=num2str(LaserPower(j)/1e-12);
        tag=strcat('BGB38_',powerstring,'pW_VG_20V_Ib_',Ibstring,'uA');

        
    %Switching Rate for 1300 nm
        %Set laser power
        Laser.SourceWavelength=1300;
        RFsource.power=RFPower1300(j);

        %Determine critical current
        FileName3 = strcat('Sweep4Ic', datestr(clock, 'yyyymmdd_HHMMSS_'), powerstring,'pW_1323nm_VG_20V_File',num2str(lastfile+4*j-3),'.mat');
        Yoko.value=highthresh; %Set comparator to not reset
        IcfromSweep=SweepIb4Ic_NIDAQ(1e6,2.7,3.1,.01,.1,1.5,.1,.05,100,10000,500000,VG);
        Power_sweep_data.Ic1300(j)=IcfromSweep.IcAvg;
        save(FileName3,'IcfromSweep')
        
        %Take switching data
        Yoko.value=lowthresh; %Set comparator to reset
        Lockin.connect('9');
        Lockin.DC=Ib*10^6;
        Lockin.disconnect();
        FileName2 = strcat('VJJ_vs_Time_with_Switch_', datestr(clock, 'yyyymmdd_HHMMSS_'), tag,'_1323nm_File',num2str(lastfile+4*j-2),'.mat');
        VJJvsTime=NIDAQ_ai0(sampling_rate,time_total,time_plot);
        num_peaks=CountPeaks2(VJJvsTime.Voltage_V,Vthresh,sampling_rate*160e-6);
        save(FileName2,'VJJvsTime')
        Power_sweep_data.Rate1300(j)=num_peaks/time_total;
        
    %Switching Rate for 1550 nm
        %Set Laser Power
        Laser.SourceWavelength=1550;
        RFsource.power=RFPower1550(j);

        %Determine critical current
        FileName3 = strcat('Sweep4Ic', datestr(clock, 'yyyymmdd_HHMMSS_'), powerstring,'pW_1545nm_VG_20V_File',num2str(lastfile+4*j-1),'.mat');
        Yoko.value=highthresh; %Set comparator to not reset
        IcfromSweep=SweepIb4Ic_NIDAQ(1e6,2.70,3.1,.01,.1,1.5,.1,.05,100,10000,500000,VG);
        Power_sweep_data.Ic1550(j)=IcfromSweep.IcAvg;
        save(FileName3,'IcfromSweep')
        
        %Take switching data
        Yoko.value=lowthresh; %Set comparator to reset
        Lockin.connect('9');
        Lockin.DC=Ib*10^6;
        Lockin.disconnect;
        FileName2 = strcat('VJJ_vs_Time_with_Switch_', datestr(clock, 'yyyymmdd_HHMMSS_'), tag,'_1545nm_File',num2str(lastfile+4*j),'.mat');
        VJJvsTime=NIDAQ_ai0(sampling_rate,time_total,time_plot);
        num_peaks=CountPeaks2(VJJvsTime.Voltage_V,Vthresh,sampling_rate*160e-6);
        save(FileName2,'VJJvsTime')
        Power_sweep_data.Rate1550(j)=num_peaks/time_total;
        
        close all
    end
    save(FileName1,'Power_sweep_data')
    close all


RFsource.disconnect();
clear RFsource;
Laser.disconnect();
clear Laser;
Lockin.disconnect();
clear Lockin;
Yoko.disconnect();
clear Yoko;

end