%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = DiffIV_vs_IBias_MWFreq(BiasList, FreqList, InitialWaitTime, measurementWaitTime)
StartTime = clock;
FileName = strcat('Backup', '.mat');
pause on;
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');
MicrowaveSource = deviceDrivers.AgilentN5183A();
MicrowaveSource.connect('19');
TotalTime = length(BiasList)*length(FreqList)*measurementWaitTime;

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data() 
    figure(899);
    clf; plot(BiasList(1:k), data.X(j,1:k),'.-'); grid on;
    xlabel('V_{bias} (V)'); ylabel('dV/dI (\Omega)');
    if k == length(BiasList) && j>1
        figure(898);
        clf; imagesc(data.X); grid on;
        xlabel('I_{bias} (A)'); ylabel('V_{gate} (V)');
    end
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
for j=1:length(FreqList)
    MicrowaveSource.frequency = FreqList(j)*1e-9;
    Lockin.DC = BiasList(1);
    pause on;
    disp(['Microwave Frequency = ' num2str(FreqList(j)*1e-9) ' GHz'])
    disp(['Time now is ' datestr(clock) ' Start time was ' datestr(StartTime) '; Collecting data for ' num2str(TotalTime/60) ' mins'] )
    pause(InitialWaitTime);
    %MicrowaveSource.output = 1;
    for k=1:length(BiasList)
        Lockin.DC = BiasList(k);
        pause(measurementWaitTime);
        data.X(j, k) = Lockin.X; data.Y(j, k) = Lockin.Y;
        %data.T(j, k) = str2num(Thermometer.query('RDGK? 5'));
        save(FileName)
        plot_data()
    end
    %MicrowaveSource.output = 0;
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = 0;
Lockin.DC = 0;
Lockin.disconnect(); MicrowaveSource.disconnect();
pause off; clear Lockin FileName StartTime Thermometer;
end