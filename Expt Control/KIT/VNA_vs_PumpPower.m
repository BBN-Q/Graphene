%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = VNA_vs_PumpPower(PowerList, InitialWaitTime)
pause on;
PumpSource = deviceDrivers.AgilentN5183A();
PumpSource.connect('19');

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
PumpSource.power = PowerList(1); % Power in dBm
pause(InitialWaitTime);
for k=1:length(PowerList)
    datetime('now')
    sprintf('The %dth data point with power %d', k, PowerList(k))
    PumpSource.power = PowerList(k);
    result = GetVNASpec_VNA();
    data.S(k,:) = result.S;
end
data.Freq = result.Freq;
PumpSource.output = '0';
pause(InitialWaitTime);
result = GetVNASpec_VNA();
data.S0 = result.S;
PumpSource.output = '1';

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
pause off;
PumpSource.power = min(PowerList);
PumpSource.disconnect();
clear VNA;
end