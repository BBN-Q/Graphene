%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = VNA_vs_FluxBias(BiasList, InitialWaitTime, measurementWaitTime)
pause on;
%Yoko = deviceDrivers.YokoGS200();
%Yoko.connect('2');
BiasSource = deviceDrivers.Keithley2400();
BiasSource.connect('24');

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
BiasSource.value = BiasList(1);
pause(InitialWaitTime);
for k=1:length(BiasList)
    disp(['Time now is ' datestr(clock)])
    sprintf('The %d data point with current bias = %e A', k, BiasList(k))
    BiasSource.value = BiasList(k);
    pause(measurementWaitTime);
    result = GetVNASpec_VNA();
    data.S(k,:) = result.S;
    save('backup.mat')
end
data.Freq = result.Freq;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
BiasSource.value = 0;
BiasSource.disconnect();
pause off; clear result Yoko BiasSource;
end