%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
% Updated October 2021 by Bevin Huang
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = Reflectometry_ReflPower_vs_InputFreq_BNC845_specAnalyzer(InputFreq, InitialWaitTime, MeasurementWaitTime)
pause on;
inputSource = deviceDrivers.BNC845();
inputSource.connect('128.33.89.51');

%%%%%%%%%%%%%%%%%%%%%%        PLOT DATA         %%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_data()
    figure(237); clf;
    semilogy(1e-9*InputFreq(1:k), 10*log10(1e3*data.Spec(1:k,round(length(result.Spec)/2))),'.-','markersize',8)
    xlabel('Input Frequency (GHz)'); ylabel('P_{probe, refl} (dBm)'); grid on; box on;
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
inputSource.output=1;
pause(InitialWaitTime);
for k=1:length(InputFreq)
    inputSource.frequency=InputFreq(k)*1e-9;
    datetime('now')
    sprintf(['Data point #' num2str(k)])
    pause(MeasurementWaitTime)
    result = GetPower_SpecAnalyzer();
    data.Spec(k,:) = result.Spec;
    plot_data();
end
data.Freq = result.Freq;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
inputSource.output=0;
inputSource.disconnect;
pause off; clear inputSource result;
end