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
Yoko = deviceDrivers.YokoGS200();
Yoko.connect('2');

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
Yoko.value = BiasList(1);
pause(InitialWaitTime); pause(measurementWaitTime);
for k=1:length(BiasList)
    disp(['Time now is ' datestr(clock)])
    sprintf('The %d data point with current bias = %e A', k, BiasList(k))
    Yoko.value = BiasList(k);
    result = GetVNASpec_VNA();
    data.S(k,:) = result.S;
    save('backup.mat')
end
data.Freq = result.Freq;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
Yoko.value = 0;
Yoko.disconnect();
pause off; clear result Yoko;
end