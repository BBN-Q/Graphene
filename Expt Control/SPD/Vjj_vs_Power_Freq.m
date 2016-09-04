%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Characterizing SPD as function of power and frequency
% version 1.0
% Created in July 2016 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = Vjj_vs_Power_Freq(Vset, Vreset, SourcePowerList, SourceFreqList, dcAmplification, InitialWaitTime, measurementWaitTime)
pause on;
DVM = deviceDrivers.Keithley2400();
DVM.connect('13');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
mwSource = deviceDrivers.AgilentN5183A();
mwSource.connect('192.168.5.102');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(899);
    clf; plot(SourcePowerList(1:k), data.dcV(j,1:k), '.-'); grid on;
    xlabel('Source Power (dBm)'); ylabel('dc V_{JJ} (V)');
    if k == length(SourcePowerList) && j>1
        figure(898);
        clf; imagesc(data.dcV); grid on;
        xlabel('Source Power (dBm)'); ylabel('Source Freq. (GHz)');
    end
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:length(SourceFreqList)
    mwSource.frequency =  SourceFreqList(j);
    mwSource.power = SourcePowerList(1);
    Lockin.DC = Vreset;
    pause(InitialWaitTime);
    Lockin.DC = Vset
    for k=1:length(SourcePowerList)
        mwSource.power = SourcePowerList(k);
        pause(measurementWaitTime);
        data.dcV(j, k) = DVM.value;   
        plot_data()
    end
    save('backup.mat')
end
mwSource.power = SourcePowerList(1);
data.dcV = data.dcV/dcAmplification;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
pause off;
DVM.disconnect(); Lockin.disconnect(); mwSource.disconnect();
clear DVM Lockin mwSource DVM;
end