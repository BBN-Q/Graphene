%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DiffIV_vs_Vbias_evaporative(RampVBias, InitialWaitTime, measurementWaitTime)
pause on;
Lockin = deviceDrivers.SRS865();
Lockin.connect('9');


% GateSource = deviceDrivers.Keithley2400();
% GateSource.connect('23');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); clf; plot(RampVBias(1:k), data.X, '.-'); grid on;
    xlabel('V_{gate} (V)'); ylabel('Lockin X (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%


GateSource.value = RampVBias(1);
pause(InitialWaitTime);
for k=1:length(RampVBias)
    GateSource.value = RampVBias(k);
    pause(measurementWaitTime);
    data.X(k) = Lockin.X; data.Y(k) = Lockin.Y;
    save('backup.mat')
    plot_data()
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
clear k
Lockin.disconnect(); GateSource.disconnect();

pause off; clear Lockin GateSource;
end