%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DiffIV_vs_IBias_Vgate(BiasList, VgateList, InitialWaitTime, measurementWaitTime)
StarTime = clock;
FileName = strcat('Backup', '.mat');
pause on;
GateCtrller = deviceDrivers.Keithley2400();
GateCtrller.connect('23');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(899);
    clf; plot(BiasList(1:k), data.X(j,1:k)); grid on;
    xlabel('V_{bias} (V)'); ylabel('dV/dI (\Omega)');
    if k == length(BiasList) && j>1
        figure(898);
        clf; imagesc(data.X); grid on;
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
        data.X(j, k) = Lockin.X; data.Y(j, k) = Lockin.Y;
        save(FileName)
        plot_data()
    end
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = 0;
Lockin.DC = 0;
Lockin.disconnect(); GateCtrller.disconnect();
pause off; clear Lockin FileName StarTime GateCtrller;
end