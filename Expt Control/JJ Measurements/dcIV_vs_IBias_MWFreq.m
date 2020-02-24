%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = dcIV_vs_IBias_MWFreq(BiasList, FreqList, dcAmplification, InitialWaitTime, measurementWaitTime)
%GateCtrller = deviceDrivers.Keithley2400();
%GateCtrller.connect('23');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
DVM=deviceDrivers.Keysight34410A();
DVM.connect('22');
MicrowaveSource = deviceDrivers.AgilentN5183A();
MicrowaveSource.connect('19');

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
StartTime = clock;
TotalTime = length(BiasList)*length(FreqList)*measurementWaitTime;
for j=1:length(FreqList)
    MicrowaveSource.frequency = FreqList(j)*1e-9;
    Lockin.DC = BiasList(1);
    disp(['Magnetic field value = ' num2str(FreqList(j)*1e-9) ' GHz'])
    disp(['Time now is ' datestr(clock) ' Start time was ' datestr(StartTime) '; Collecting data for ' num2str(TotalTime/60) ' mins'] )
    pause on;
    pause(InitialWaitTime);
    for k=1:length(BiasList)
        Lockin.DC = BiasList(k);
        pause on;
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
Lockin.disconnect(); MicrowaveSource.disconnect(); DVM.disconnect(); %Thermometer.disconnect();  GateCtrller.disconnect(); 
pause off; clear Lockin MicrowaveSource DVM StartTime;
end