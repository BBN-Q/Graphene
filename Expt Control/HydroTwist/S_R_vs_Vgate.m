%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = S_R_vs_Vgate(VgateList, InitialWaitTime, MeasurementWaitTime)
pause on;
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
GateController = deviceDrivers.Keithley2400();
GateController.connect('23');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); clf; plot(VgateList(1:k), data.X, '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('Lockin X (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
GateController.value = VgateList(1);
pause(InitialWaitTime);
for k=1:length(VgateList)
    GateController.value = VgateList(k);
    pause(MeasurementWaitTime);
    result = GetVNASpec_VNA();
    data.S(k,:) = result.S;
    data.X(k) = Lockin.X; data.Y(k) = Lockin.Y;
    plot_data()
end
data.Freq = result.Freq;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
GateController.value = 0;
Lockin.disconnect();
pause off; clear result Lockin result2;
end