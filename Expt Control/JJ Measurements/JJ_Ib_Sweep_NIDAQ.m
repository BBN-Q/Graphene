function Ib_sweep_data = JJ_Ib_Sweep_NIDAQ(Power,Gate,VbStart,VbEnd,VbStep,Vthresh,sampling_rate, time_total, time_plot,FileStart)
%Sweeps bias current

% temp = instrfind;
% if ~isempty(temp)
%     fclose(temp);
%     delete(temp);
% end

%Connect to Lockin for Bias Current
Lockin=deviceDrivers.SRS865;
Lockin.connect('9');

StartTime = clock;
FileName1 = strcat('Ib_Sweep_Data_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'.mat');



Vb=V_Array(VbStart,VbEnd,VbStep,0);
Ib_sweep_data=struct('Ib_Array',Vb,'Rate',[],'Power',Power,'VG',Gate);

powerstring=num2str(Power/10^-12);
gatestring=num2str(Gate);
for i=1:length(Vb)
    Lockin.DC=Vb(i);
    Ibstring=strrep(num2str(Vb(i)),'.','p');
    filestring=num2str(FileStart+i);
    tag=strcat('BGB38_',powerstring,'pW_VG_',gatestring,'V_Ib_',Ibstring,'uA_File',filestring);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CHANGE MODULE FOR APPROPRIATE INSTRUMENTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FileName2 = strcat('Peaks_vs_Time_', datestr(clock, 'yyyymmdd_HHMMSS_'), tag,'.mat');
    VJJvsTime=NIDAQ_ai0(sampling_rate,time_total,time_plot);

    Peak_data=ExtractPeaks(VJJvsTime.Time_s,VJJvsTime.Voltage_V,Vthresh,sampling_rate*60e-6,sampling_rate*160e-6);
    %num_peaks=CountPeaks2(VJJvsTime.Voltage_V,Vthresh,sampling_rate*160e-6);
    Ib_sweep_data.Rate(i)=Peak_data.num_peaks/time_total;
    save(FileName1,'Ib_sweep_data')
    save(FileName2,'Peak_data')
    close all
end

%Disconnect
Lockin.disconnect();
clear Lockin

end
