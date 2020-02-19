%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = VNA_vs_PumpPower_PumpFreq(PowerList, FreqList, InitialWaitTime, measurementWaitTime)
pause on;
PumpSource = deviceDrivers.AgilentN5183A();
PumpSource.connect('19');
FreqList = FreqList*1e-9;

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
PumpSource.frequency = FreqList(1); 
PumpSource.power = PowerList(1); % Power in dBm
for k=1:length(FreqList)
    PumpSource.frequency = FreqList(k);
    %pause(InitialWaitTime);
    for j = 1:length(PowerList)
        datetime('now')
        sprintf('The %dth outer loop with freq at %f GHz and the %dth inner loop with power at %f dBm', k, FreqList(k), j, PowerList(j))
        PumpSource.power = PowerList(j);
        %pause(measurementWaitTime);
        result = GetVNASpec_VNA();
        data.S(k,j,:) = result.S;
    end
end
data.Freq = result.Freq;
PumpSource.output = '0';
result = GetVNASpec_VNA();
data.S0 = result.S;
PumpSource.output = '1';

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
pause off;
PumpSource.power = min(PowerList);
PumpSource.disconnect();
clear VNA k j PumpSource result;
end