%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = VNA_vs_FluxBias_PumpFreq(FluxBiasList, FreqList_Hz, InitialWaitTime)
pause on;
PumpSource = deviceDrivers.AgilentN5183A();
PumpSource.connect('19');
BiasSource = deviceDrivers.Keithley2400();
BiasSource.connect('24');
%BiasSource = deviceDrivers.YokoGS200();
%BiasSource.connect('2');
FreqList = FreqList_Hz*1e-9;

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
BiasSource.value = FluxBiasList(1);
PumpSource.frequency = FreqList(1); 
PumpSource.output = '1';
pause(InitialWaitTime);
for k=1:length(FluxBiasList)
    BiasSource.value = FluxBiasList(k);
    pause(InitialWaitTime);
    for j = 1:length(FreqList)
        disp(datetime('now'))
        sprintf('The %dth outer loop with flux bias at %e A and the %dth inner loop with freq at %e GHz', k, FluxBiasList(k), j, FreqList(j))
        PumpSource.frequency = FreqList(j);
        result = GetVNASpec_VNA();
        data.S(k,j,:) = result.S;
    end
    data.Freq = result.Freq;
    PumpSource.output = '0';
    result = GetVNASpec_VNA();
    data.S0(k,:) = result.S;
    PumpSource.output = '1';
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
pause off;
BiasSource.value = min(abs(FluxBiasList));
PumpSource.disconnect(); BiasSource.disconnect();
clear k j PumpSource result Yoko;
end