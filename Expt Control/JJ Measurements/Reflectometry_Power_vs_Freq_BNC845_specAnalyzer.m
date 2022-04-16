%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
% Updated October 2021 by Bevin Huang
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = Reflectometry_Power_vs_Freq_BNC845_specAnalyzer(ProbeFreqList, InitialWaitTime, MeasurementWaitTime)
pause on;
ProbeSource = deviceDrivers.BNC845();
%ProbeSource.connect('128.33.89.198'); %probe RF source
ProbeSource.connect('128.33.89.51') %input BNC RF source

%%%%%%%%%%%%%%%%%%%%%%        PLOT DATA         %%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_data()
    figure(237); clf;
    plot(1e-9*ProbeFreqList(1:k), 10*log(1e3*data.Spec(1:k,round(length(result.Spec)/2))))
    xlabel('Frequency (GHz)'); ylabel('P_{input, refl} (dBm)')
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
ProbeSource.output=1;
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
ProbeSource.output=0;
ProbeSource.disconnect();
pause off; clear result ProbeSource;
end