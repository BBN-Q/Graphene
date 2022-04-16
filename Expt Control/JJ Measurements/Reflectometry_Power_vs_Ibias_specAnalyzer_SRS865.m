%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
% Updated October 2021 by Bevin Huang
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = Reflectometry_Power_vs_Ibias_specAnalyzer_SRS865(IBiasList, InitialWaitTime, MeasurementWaitTime)
pause on;
BiasSource = deviceDrivers.SRS865();
BiasSource.connect('4');

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
BiasSource.DC = IBiasList(1);
pause(InitialWaitTime);
for k=1:length(IBiasList)
    BiasSource.DC = IBiasList(k);
    datetime('now')
    sprintf('The %dth data point', k)
    pause(MeasurementWaitTime)
    result = GetPower_SpecAnalyzer();
    data.Spec(k,:) = result.Spec;
end
data.Freq = result.Freq;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
BiasSource.DC = 0;
BiasSource.disconnect();
pause off; clear result BiasSource;
end