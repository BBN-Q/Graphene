%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = VNA_vs_JPAParameters_TestPower(TestPowerList, AveragingNumberList, JPAPumpPowerList, JPAPumpFreqList, JPAFluxBiasList, InitialWaitTime)
pause on;
PumpSource = deviceDrivers.AgilentN5183A();
PumpSource.connect('19');
Yoko = deviceDrivers.YokoGS200();
Yoko.connect('2');

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:length(JPAPumpPowerList)
    sprintf('Set to %e A, and pump frequency and power at %e GHz and %e dBm, respectively', JPAFluxBiasList(k), JPAPumpFreqList(k)*1e-9, JPAPumpPowerList(k))
    PumpSource.frequency = JPAPumpFreqList(k)*1e-9;
    PumpSource.power = JPAPumpPowerList(k);
    Yoko.value = JPAFluxBiasList(k);
    result = VNA_vs_TestPower(TestPowerList, AveragingNumberList, InitialWaitTime);
    data.S(k,:,:) = result.S;
    PumpSource.output = '0';
    pause on; 
    pause(InitialWaitTime);
    result = GetVNASpec_VNA();
    data.S0(k,:) = result.S;
    PumpSource.output = '1';
end
data.Freq = result.Freq;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
pause off;
PumpSource.disconnect(); Yoko.disconnect();
clear PumpSource total_num k Yoko
end