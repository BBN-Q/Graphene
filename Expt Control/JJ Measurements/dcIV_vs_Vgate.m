%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = dcIV_vs_Vgate(VgateList, dcAmplification, InitialWaitTime, measurementWaitTime)
pause on;
DVM = deviceDrivers.Keysight34410A();
DVM.connect('22');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
GateController = deviceDrivers.Keithley2400();
GateController.connect('23');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
figure(799); 
function plot_data()
    clf; plot(VgateList(1:k), data.dcV, '.-'); grid on;
    xlabel('V_{gate} (V)'); ylabel('dc V_{JJ} (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
GateController.value = VgateList(1);
pause(InitialWaitTime);
for k=1:length(VgateList)
    GateController.value = VgateList(k);
    pause(measurementWaitTime);
    data.dcV(k) = DVM.value;
    save('backup.mat')
    plot_data()
end
data.dcV = data.dcV/dcAmplification;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = 0;
GateController.value = 0;
Lockin.disconnect(); DVM.disconnect(); GateController.disconnect();
pause off; clear Lockin DVM GateController;
end