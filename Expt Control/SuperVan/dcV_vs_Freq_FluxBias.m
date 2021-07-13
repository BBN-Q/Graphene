%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = dcV_vs_Freq_FluxBias(FreqList, BiasList, dcAmplification, InitialWaitTime, measurementWaitTime)
pause on;
DVM=deviceDrivers.Keysight34410A();
DVM.connect('22');
MicrowaveSource = deviceDrivers.AgilentN5183A();
MicrowaveSource.connect('19');
MicrowaveSource.output = 1;
FluxCtrl = deviceDrivers.Keithley2400();
FluxCtrl.connect('24');
FreqList = FreqList*1e-9; % input command line unit is GHz

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
figure(799); 
function plot_data()
    clf; figure(799); plot(FreqList(1:k), dcV, '.-'); grid on;
    xlabel('Freq. (Hz)'); ylabel('dc V_{JJ} (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
MicrowaveSource.frequency = FreqList(1);
FluxCtrl.value = BiasList(1);
for j = 1:length(BiasList)
    FluxCtrl.value = BiasList(j);
    disp(['taking j = ', num2str(j)])
    pause(InitialWaitTime);
    for k=1:length(FreqList)
        MicrowaveSource.frequency = FreqList(k);
        pause(measurementWaitTime);
        dcV(k) = DVM.value;
        data.dcV(j, k) = dcV(k);
        %save('backup.mat')
    end
    plot_data()
end
data.dcV = data.dcV/dcAmplification;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = 0;


MicrowaveSource.disconnect();
DVM.disconnect(); FluxCtrl.disconnect();
pause off; clear MicrowaveSource DVM FluxCtrl;
end