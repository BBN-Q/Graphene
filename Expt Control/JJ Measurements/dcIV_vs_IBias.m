%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = dcIV_vs_IBias(BiasList, dcAmplification, InitialWaitTime, measurementWaitTime)
pause on;
DVM=deviceDrivers.Keithley2400();
DVM.connect('13');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
figure(799); 
function plot_data()
    clf; plot(BiasList(1:k), data.dcV, '.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('dc V_{JJ} (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
Lockin.DC = BiasList(1);
pause(InitialWaitTime);
for k=1:length(BiasList)
    Lockin.DC = BiasList(k);
    pause(measurementWaitTime);
    data.dcV(k) = DVM.value;
    save('backup.mat')
    plot_data()
end
data.dcV = data.dcV/dcAmplification;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = 0;
Lockin.DC = 0;
%Lockin.disconnect();
DVM.disconnect();
pause off; clear Lockin DVM;
end