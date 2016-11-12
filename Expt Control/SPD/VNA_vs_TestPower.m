%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = VNA_vs_TestPower(PowerList, InitialWaitTime, measurementWaitTime)
pause on;
VNA = deviceDrivers.AgilentE8363C();
VNA.connect('192.168.5.101')

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
VNA.power = PowerList(1); % Power in dBm
pause(InitialWaitTime);
for k=1:length(PowerList)
    k
    VNA.power = PowerList(k);
    pause(measurementWaitTime);
    [spec.Freq spec.S] = VNA.getTrace();
    data.S(k,:) = spec.S;
end
data.Freq = spec.Freq;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
pause off;
VNA.disconnect();
clear VNA;
end