%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sweeps bias current and takes switching statistics of
% JJ using JJ_Diff_switch_module.
% Evan Walsh, March 2016 (evanwalsh@seas.harvard.edu)

function Ib_sweep_data=JJ_Diff_Ib_sweep
StartTime = clock;
FileName = strcat('Ib_Sweep_Data_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'.mat');

temp = instrfind;
if ~isempty(temp)
    fclose(temp);
    delete(temp);
end

Vb=V_Array(-1.70,-1.40,.01,0);
Ib_sweep_data=struct('Ib_Array',Vb,'Rate',[],'Std',[]);

for i=1:length(Vb)
    Ibstring=strrep(num2str(Vb(i)),'.','p');
    filestring=num2str(135+i); %CHANGE FILE # HERE (# should be last saved File #)
    tag=strcat('1000pW_VG_25p3V_Ib_',Ibstring,'uA_File',filestring); %CHANGE POWER LABEL HERE
    
    Ib_switch_data=JJ_Diff_switch_module(1e6,Vb(i),0,60,4.5e-6,-1.25,.1,25.3,tag);

    Ibstats=GetStatsFromJJSwitch(Ib_switch_data,1);
    Ib_sweep_data.Rate(i)=Ibstats.avg_countsperbin;
    Ib_sweep_data.Std(i)=Ibstats.std_countsperbin;
    save(FileName,'Ib_sweep_data')
    close all
end
end