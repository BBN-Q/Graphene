%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
% Updated October 2021 by Bevin Huang
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = Reflectometry_Power_vs_Freq_N5183A_specAnalyzer(ProbeFreqList, InitialWaitTime, MeasurementWaitTime)
pause on;
ProbeSource = deviceDrivers.AgilentN5183A();
%ProbeSource.connect('128.33.89.198'); %probe RF source
ProbeSource.connect('128.33.89.6') %input RF source

%%%%%%%%%%%%%%%%%%%%%%        PLOT DATA         %%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_data()
    figure(237); clf;
    plot(1e-9*ProbeFreqList(1:k), 1e12*data.Spec(1:k,round(length(result.Spec)/2)))
    xlabel('Frequency (GHz)'); ylabel('Power (pW)')
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
ProbeSource.frequency = ProbeFreqList(1);
pause(InitialWaitTime);
for k=1:length(ProbeFreqList)
    ProbeSource.frequency = ProbeFreqList(k)/1e9;
    SpecAnalyzer = deviceDrivers.AgilentN9020A();
    SpecAnalyzer.connect('128.33.89.213');
    SpecAnalyzer.SASetCenterFreq(ProbeFreqList(k));
    SpecAnalyzer.disconnect;
    clear SpecAnalyzer
    datetime('now')
    sprintf(['Data point #' num2str(k)])
    pause(MeasurementWaitTime)
    result = GetPower_SpecAnalyzer();
    data.Spec(k,:) = result.Spec;
    plot_data();
end
data.Freq = result.Freq;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
ProbeSource.disconnect();
pause off; clear result ProbeSource;
end