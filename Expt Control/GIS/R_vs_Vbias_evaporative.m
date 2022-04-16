%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = R_vs_Vbias_evaporative(VbiasList, InitialWaitTime, measurementWaitTime)
pause on;
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
VoltageSource = deviceDrivers.Keithley2400();
VoltageSource.connect('24');


% GateSource = deviceDrivers.Keithley2400(); RampVBias function will do
% this instead
% GateSource.connect('23');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%

%plot lockin x vs Vbias
    function plot_data()
    figure(799); clf; plot(VbiasList(1:k), data.X, '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('Lockin X (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
VoltageSource.value = VbiasList(1);
pause(InitialWaitTime);
for k=1:length(VbiasList)
    VoltageSource.value = VbiasList(k);
    pause(measurementWaitTime);
    data.X(k) = Lockin.X; data.Y(k) = Lockin.Y;
    %data.DMM(k) = CurrentMeas.value;
    %save('backup.mat')
    plot_data()
end



%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
clear k
Lockin.disconnect(); 
VoltageSource.disconnect(); 
pause off; clear Lockin VoltageSource;
end