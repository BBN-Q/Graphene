%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sweeps RF source in power and frequency and takes switching statistics of
% JJ using JJ_switch_module.
% Evan Walsh, January 2016 (evanwalsh@seas.harvard.edu)

function RF_sweep_data=JJ_RF_sweep
StartTime = clock;
FileName = strcat('RF_Sweep_Data_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'.mat');

temp = instrfind;
if ~isempty(temp)
    fclose(temp);
    delete(temp);
end

RFfreq=; %frequency in GHz
RFpow=13; %power in dBm

RF_sweep_data=struct('RFfreq_Array',RFfreq,'RFpow_Array',RFpow,'Rate',[],'Std',[]);

RFsource=deviceDrivers.AgilentN5183A;
RFsource.connect('19');

for i=1:length(RFfreq)
    RFsource.frequency=RFfreq(i);
    freqstring=strrep(num2str(RFfreq(i)),'.','p');        
    for j=1:length(RFpow)
        powstring=strrep(num2str(RFpow(j)),'-','n');
        filestring=num2str(249+(i-1)*length(RFpow)+j); %Replace number with desired file number
        
        tag=strcat('RF_',freqstring,'GHz_',powstring,'dBm_File',filestring);
        RFsource.power=RFpow(j);
        RF_switch_data=JJ_switch_module(1e6,2.80,0,600,0.18e-3,1.70,0.01,20,tag);

        RFstats=GetStatsFromJJSwitch(RF_switch_data,1);
        RF_sweep_data.Rate(i,j)=RFstats.avg_countsperbin;
        RF_sweep_data.Std(i,j)=RFstats.std_countsperbin;
        save(FileName,'RF_sweep_data')
        close all
    end
end
% end
