%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DiffIV_vs_VBias_SR865MeasAndAC_K2400DC_evaporative(BiasList, ExcitVolt, InitialWaitTime, measurementWaitTime)
pause on;
Lockin = deviceDrivers.SRS865();
Lockin.connect('9');
Keithley = deviceDrivers.Keithley2400();
Keithley.connect('23');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(899); clf; plot(BiasList(1:k), data.R, '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('Lockin R (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
Lockin.sineAmp = ExcitVolt;
Keithley.value = BiasList(1);
pause(InitialWaitTime);
for k=1:length(BiasList)
    Keithley.value = BiasList(k);
    pause(measurementWaitTime);
    data.R(k) = Lockin.R; data.theta(k) = Lockin.theta;
    save('backup.mat')
    plot_data()
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
Keithley.value = 0;
Keithley.disconnect();
Lockin.disconnect(); 
pause off; clear Lockin; clear Keithley;
end