%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
% Updated October 2021 by Bevin Huang
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = Reflectometry_getSNRHistogram_specAnalyzer(NumAvg, InputFreq, InitialWaitTime, MeasurementWaitTime)
pause on;
inputSource = deviceDrivers.BNC845();
inputSource.connect('128.33.89.51');

%%%%%%%%%%%%%%%%%%%%%%        PLOT DATA         %%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_data()
    figure(237); clf;
    histogram(1e6*data.Spec(1:k,round(length(result.Spec)/2)),50);
    xlabel('P_{probe, refl} (uW)')
    ylabel('# of occurences')
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
inputSource.output=1;
inputSource.frequency=InputFreq/1e9;
pause(InitialWaitTime);
for k=1:NumAvg
    datetime('now')
    sprintf(['Data point #' num2str(k)])
    pause(MeasurementWaitTime+rand)
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