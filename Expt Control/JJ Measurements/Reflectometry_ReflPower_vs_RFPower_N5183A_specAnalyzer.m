%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
% Updated October 2021 by Bevin Huang
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = Reflectometry_ReflPower_vs_RFPower_N5183A_specAnalyzer(ProbePowerList, InitialWaitTime, MeasurementWaitTime)
pause on;
ProbeSource = deviceDrivers.AgilentN5183A();
ProbeSource.connect('128.33.89.198'); %probe RF source
%ProbeSource.connect('128.33.89.6') %input RF source

%%%%%%%%%%%%%%%%%%%%%%        PLOT DATA         %%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_data()
    figure(237); clf;
    semilogy(ProbePowerList(1:k), 10*log10(1e3*data.Spec(1:k,round(length(result.Spec)/2))),'o-')
    xlabel('Probe Tone Power (dBm)'); ylabel('P_{probe, refl} (dBm)')
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
ProbeSource.power = ProbePowerList(1);
pause(InitialWaitTime);
for k=1:length(ProbePowerList)
    ProbeSource.power = ProbePowerList(k);
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