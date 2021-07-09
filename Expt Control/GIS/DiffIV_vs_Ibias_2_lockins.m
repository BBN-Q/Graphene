%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
% adapted by Caleb Fried and Bevin Huang May 2021
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DiffIV_vs_Ibias_2_lockins(BiasList, InitialWaitTime, measurementWaitTime)
pause on;
Lockin1 = deviceDrivers.SRS865();
Lockin1.connect('4');
Lockin2 = deviceDrivers.SRS865();
Lockin2.connect('9');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); clf; plot(BiasList(1:k), data.X, '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('Lockin1 X (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
Lockin1.DC = BiasList(1);
pause(InitialWaitTime);
for k=1:length(BiasList)
    Lockin1.DC = BiasList(k);
    pause(measurementWaitTime);
    data.X(k) = Lockin1.X; data.Y(k) = Lockin1.Y;
    data.ExcitMonitor_X(k) = Lockin2.X; data.ExcitMonitor_Y(k) = Lockin2.Y;
    save('backup.mat')
    plot_data()
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
Lockin1.DC = 0;
Lockin1.disconnect(); 
pause off; clear Lockin1;
end