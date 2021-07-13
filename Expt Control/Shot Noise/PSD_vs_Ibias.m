%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = PSD_vs_Ibias(IBiasList, InitialWaitTime, MeasurementWaitTime)
pause on;
SpecAnalyzer = deviceDrivers.AgilentN9020A();
BiasSource = deviceDrivers.Keithley2400();
BiasSource.connect('23');

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
BiasSource.value = IBiasList(1);
pause(InitialWaitTime);
for k=1:length(IBiasList)
    BiasSource.value = IBiasList(k);
    datetime('now')
    sprintf('The %dth data point', k)
    SpecAnalyzer.connect('128.33.89.34');    % last '128.33.89.217'
    SpecAnalyzer.SAAvgRestart;
    SpecAnalyzer.disconnect();
    pause(MeasurementWaitTime)
    result = GetPSD_SpecAnalyzer();
    data.PSD(k,:) = result.PSD;
end
data.Freq = result.Freq;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
BiasSource.value = 0;
BiasSource.disconnect();
pause off; clear result BiasSource;
end