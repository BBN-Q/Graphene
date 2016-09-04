%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DiffIV_vs_IBias_Vgate(BiasList, VgateList, dcAmplification, InitialWaitTime, measurementWaitTime)
pause on;
GateCtrller = deviceDrivers.Keithley2400();
GateCtrller.connect('23');
DVM=deviceDrivers.Keithley2400();
DVM.connect('13');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
%Thermometer = deviceDrivers.Lakeshore335();
%Thermometer.connect('12');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(899);
    clf; plot(BiasList(1:k), data.dcV(j,1:k), '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('dc V_{JJ} (V)');
    if k == length(BiasList) && j>1
        figure(898);
        clf; imagesc(data.dcV); grid on;
        xlabel('I_{bias} (A)'); ylabel('V_{gate} (V)');
    end
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:length(VgateList)
    GateCtrller.value = VgateList(j);
    Lockin.DC = BiasList(1);
    pause(InitialWaitTime);
    for k=1:length(BiasList)
        Lockin.DC = BiasList(k);
        pause(measurementWaitTime);
        data.dcV(j, k) = DVM.value;   
        plot_data()
    end
    save('backup.mat')
end
data.dcV = data.dcV/dcAmplification;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = 0;
Lockin.DC = 0; GateCtrller.value = 0;
Lockin.disconnect(); GateCtrller.disconnect(); DVM.disconnect(); %Thermometer.disconnect();
pause off; clear Lockin GateCtrller DVM;
end