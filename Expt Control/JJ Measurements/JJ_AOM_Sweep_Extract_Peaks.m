function Power_sweep_data = JJ_AOM_Sweep_Extract_Peaks
%Sweeps RF Power input to AOM, takes switching data from JJ with NIDAQ,
%only keeps data surrounding peaks. Collects data until both mintime and
%minpeaks are reached

%Experiment Parameters
Ib=3.00e-6;
VG=20;
Pol=130;

%NIDAQ Parameters
sampling_rate=50000;
time_plot=10;
Vthresh=0.065;

%Minimum time/peaks
minpeaks=100;
mintime=1000;

%File Zero (last file # to be saved)
filezero=2879;

%Start Time and File Name
StartTime = clock;
FileName1 = strcat('Power_Sweep_Data_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'.mat');

%Connect to RF Source
RFsource=deviceDrivers.AgilentN5183A;
RFsource.connect('19');

%RF Power in dBm
%RFpower=[6.51, 6.40, 6.31, 6.19, 6.08, 6.01, 5.91, 5.86, 5.76, 5.65, 5.53, 5.40, 5.32, 5.20, 5.06, 4.95, 4.85, 4.74, 4.60, 4.44, 4.27, 4.12, 4.00, 3.84, 3.69, 3.51, 3.33, 3.12, 2.92, 2.72, 2.55, 2.32, 2.07, 1.79, 1.52, 1.27, 0.97, 0.64, 0.31, -0.08, -0.51, -0.97, -1.47, -2.04, -2.71, -3.49, -4.50, -5.77, -7.56, -10.62];
RFpower=[6.51, 6.40, 6.31, 5.91, 5.32, 5.2, 5.06, 4.95, 4.85, 4.74, 4.12, 4.00, 3.84];
%Laser Power in pW
%LaserPower=510-(10:10:500);
LaserPower=[500, 490, 480, 440, 380, 370, 360, 350, 340, 330, 290, 280, 270];
Power_sweep_data=struct('Power_pW',LaserPower,'Rate',zeros(1,length(LaserPower)),'Ib',Ib,'VG',VG,'Polarization',Pol);


for i=1:length(RFpower)
	RFsource.power=RFpower(i);
    powerstring=num2str(LaserPower(i));
    tag=strcat('BGB38_VG_',num2str(VG),'V_Ib_',num2str(Ib*1e6),'uA_Pol',num2str(Pol),'deg_',powerstring,'pW');
    
    %Initialize while loop
    loops=0;
    Peak_data=struct('num_peaks',0,'Time',[],'Voltage',[]);
    FileName2 = strcat('Peaks_vs_Time_', datestr(clock, 'yyyymmdd_HHMMSS_'), tag,'_File',num2str(filezero+i),'.mat');

    while Peak_data.num_peaks<minpeaks
        loops=loops+1;
        %Take complete voltage vs time data
        VJJvsTime=NIDAQ_ai0(sampling_rate,mintime,time_plot);
        %Extract Peaks vs Time data
        Peak_data_new=ExtractPeaks(VJJvsTime.Time_s,VJJvsTime.Voltage_V,Vthresh,sampling_rate*60e-6,sampling_rate*160e-6);
        %Number of new peaks and old peaks
        new_peaks=Peak_data_new.num_peaks;
        old_peaks=Peak_data.num_peaks;
        %Add new peaks to old peaks
        Peak_data.num_peaks=old_peaks+new_peaks;
        %Add new peak data to old peak data
        Peak_data.Time((old_peaks+1):(old_peaks+new_peaks),:)=Peak_data_new.Time+(loops-1)*mintime;
        Peak_data.Voltage((old_peaks+1):(old_peaks+new_peaks),:)=Peak_data_new.Voltage;
    end
    save(FileName2,'Peak_data')
    Power_sweep_data.Rate(i)=Peak_data.num_peaks/(loops*mintime);
    Power_sweep_data.PoissStats(i)=GetPoissStats(Peak_data.Time(:,1),loops*mintime,1);
    save(FileName1,'Power_sweep_data')
    close all
end

RFsource.disconnect();
clear RFsource;

end