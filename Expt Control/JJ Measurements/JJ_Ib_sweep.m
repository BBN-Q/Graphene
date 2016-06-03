%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sweeps RF source in power and frequency and takes switching statistics of
% JJ using JJ_switch_module.
% Evan Walsh, January 2016 (evanwalsh@seas.harvard.edu)

function Ib_sweep_data=JJ_Ib_sweep
StartTime = clock;
FileName = strcat('Ib_Sweep_Data_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'.mat');

temp = instrfind;
if ~isempty(temp)
    fclose(temp);
    delete(temp);
end

Vb=V_Array(3.05,2.80,.01,0);
Ib_sweep_data=struct('Ib_Array',Vb,'Rate',[],'Std',[]);

for i=1:length(Vb)
    Ibstring=strrep(num2str(Vb(i)),'.','p');
    filestring=num2str(271+i); %CHANGE FILE # HERE (# should be last saved File #)
    tag=strcat('BGB38_00000pW_VG_20V_Ib_',Ibstring,'uA_File',filestring); %CHANGE POWER LABEL HERE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %CHANGE MODULE FOR APPROPRIATE INSTRUMENTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Ib_switch_data=JJ_switch_K2400Meas_SRS865Excite_K2400Gate_module(1e6,Vb(i),0,60,.1,1.30,0.01,20,tag);

    Ibstats=GetStatsFromJJSwitch(Ib_switch_data,1);
    Ib_sweep_data.Rate(i)=Ibstats.avg_countsperbin;
    Ib_sweep_data.Std(i)=Ibstats.std_countsperbin;
    save(FileName,'Ib_sweep_data')
    close all
end
end