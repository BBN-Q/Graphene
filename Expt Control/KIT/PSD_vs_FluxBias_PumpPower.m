%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = PSD_vs_FluxBias_PumpPower(FluxBiasList,  PowerList, InitialWaitTime)
pause on;
PumpSource = deviceDrivers.AgilentN5183A();
PumpSource.connect('19');
Yoko = deviceDrivers.YokoGS200();
Yoko.connect('2');

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
Yoko.value = FluxBiasList(1);
PumpSource.power = PowerList(1); % Power in dBm
PumpSource.output = '1';
pause(InitialWaitTime);
for k=1:length(FluxBiasList)
    Yoko.value = FluxBiasList(k);
    for j = 1:length(PowerList)
        disp(datetime('now'))
        sprintf('The %dth outer loop with flux bias at %e A and the %dth inner loop with power at %e dBm', k, FluxBiasList(k), j, PowerList(j))
        PumpSource.power = PowerList(j);
        pause(InitialWaitTime);
        result = GetPSD_SpecAnalyzer();
        data.S(k,j,:) = result.PSD;
    end
    data.Freq = result.Freq;
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
pause off;
Yoko.value = min(abs(FluxBiasList));
PumpSource.power = min(PowerList);
PumpSource.disconnect(); Yoko.disconnect();
clear k j PumpSource result Yoko;
end