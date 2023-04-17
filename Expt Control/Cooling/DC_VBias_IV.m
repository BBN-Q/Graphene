%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DC_VBias_IV(VBiasList, InitialWaitTime, measurementWaitTime)
pause on;
VoltageSource = deviceDrivers.Keithley2400();
VoltageSource.connect('24');
CurrentMeas = deviceDrivers.Keysight34410A();
CurrentMeas.connect('22');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); clf; plot(VBiasList(1:k), data.DMM, '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('V_{DMM} (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
VoltageSource.value = VBiasList(1);
pause(InitialWaitTime);
for k=1:length(VBiasList)
    VoltageSource.value = VBiasList(k);
    pause(measurementWaitTime);
    data.DMM(k) = CurrentMeas.value;
    %save('backup.mat')
    plot_data()
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
VoltageSource.disconnect(); CurrentMeas.disconnect();
pause off;
end