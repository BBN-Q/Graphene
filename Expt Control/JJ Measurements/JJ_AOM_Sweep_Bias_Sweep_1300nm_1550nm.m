function Power_sweep_data = JJ_AOM_Sweep_Bias_Sweep_1300nm_1550nm
%Sweeps RF Power input to AOM, takes switching data from JJ with NIDAQ

%Last File
lastfile=938;

%Gate Voltage (Just a Label, Not a Setter)
VG=20;

%Bias Sweep
% VbStart=3.00;
% VbEnd=2.80;
% VbStep=0.05;
% Vb=V_Array(VbStart,VbEnd,VbStep,0);
Vb=[3, 2.90, 2.85, 2.80];

%NIDAQ Parameters
sampling_rate=50000;
time_total=1200;
time_plot=10;
Vthresh=0.065;

%Start Time and File Name
StartTime = clock;
FileName1 = strcat('Power_Sweep_Data_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'.mat');

%Connect to RF Source and Laser
RFsource=deviceDrivers.AgilentN5183A;
RFsource.connect('19');
Laser=deviceDrivers.HP8153A;
Laser.connect('20');
Lockin=deviceDrivers.SRS865;
Lockin.connect('9');

RFPower1300 = [-20, -10.24, -3.50, -0.95, 0.62, 1.77, 2.68, 3.43, 4.04, 4.59, 5.10, 5.53, 5.91, 6.30, 6.64, 6.95, 7.25, 7.50, 7.77, 8.04, 8.38]; 
RFPower1550 = [-20, -15.23, -12.10, -10.30, -9.04, -8.05, -7.26, -6.59, -6.00, -5.49, -5.02, -4.61, -4.23, -3.87, -3.56, -3.26, -2.97, -2.70, -2.45, -2.22, -1.99];
LaserPower = (0:100:2000)*1e-12;

Power_sweep_data=struct('Power',LaserPower,'Rate1300',[],'Rate1550',[],'Ib',Vb*1e-6,'VG',VG);




for i=1:length(Vb)
    Lockin.DC=Vb(i);
    Ibstring=strrep(num2str(Vb(i)),'.','p');
    
    for j=1:length(LaserPower)
        powerstring=num2str(LaserPower(j)/1e-12);
        tag=strcat('BGB38_',powerstring,'pW_VG_20V_Ib_',Ibstring,'uA');

        
        %Switching Rate for 1300 nm
        Laser.SourceWavelength=1300;
        RFsource.power=RFPower1300(j);

        FileName2 = strcat('VJJ_vs_Time_with_Switch_', datestr(clock, 'yyyymmdd_HHMMSS_'), tag,'_1323nm_File',num2str(lastfile+2*(i-1)*length(LaserPower)+(2*j)-1),'.mat');
        VJJvsTime=NIDAQ_ai0(sampling_rate,time_total,time_plot);
        num_peaks=CountPeaks2(VJJvsTime.Voltage_V,Vthresh,sampling_rate*160e-6);
        save(FileName2,'VJJvsTime')
        Power_sweep_data.Rate1300(i,j)=num_peaks/time_total;
        
        %Switching Rate for 1550 nm
        Laser.SourceWavelength=1550;
        RFsource.power=RFPower1550(j);

        FileName2 = strcat('VJJ_vs_Time_with_Switch_', datestr(clock, 'yyyymmdd_HHMMSS_'), tag,'_1545nm_File',num2str(lastfile+2*(i-1)*length(LaserPower)+2*j),'.mat');
        VJJvsTime=NIDAQ_ai0(sampling_rate,time_total,time_plot);
        num_peaks=CountPeaks2(VJJvsTime.Voltage_V,Vthresh,sampling_rate*160e-6);
        save(FileName2,'VJJvsTime')
        Power_sweep_data.Rate1545(i,j)=num_peaks/time_total;
    end
    save(FileName1,'Power_sweep_data')
    close all
end

RFsource.disconnect();
clear RFsource;
Laser.disconnect();
clear Laser;
Lockin.disconnect();
clear Lockin;

end