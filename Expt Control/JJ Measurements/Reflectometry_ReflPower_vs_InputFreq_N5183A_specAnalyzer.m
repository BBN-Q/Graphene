%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
% Updated October 2021 by Bevin Huang
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = Reflectometry_ReflPower_vs_InputFreq_N5183A_specAnalyzer(InputFreq, InitialWaitTime, MeasurementWaitTime)
pause on;

%%%%%%%%%%%%%%%%%%%%%%        PLOT DATA         %%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_data()
    figure(237); clf;
    semilogy(1e-9*InputFreq(1:k), 10*log10(1e3*data.Spec(1:k,round(length(result.Spec)/2))),'o-')
    xlabel('Input Frequency (GHz)'); ylabel('P_{probe, refl} (dBm)')
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
pause(InitialWaitTime);
for k=1:length(InputFreq)
    datetime('now')
    sprintf(['Data point #' num2str(k)])
    pause(MeasurementWaitTime)
    result = GetPower_SpecAnalyzer();
    data.Spec(k,:) = result.Spec;
    plot_data();
end
data.Freq = result.Freq;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
pause off; clear result;
end