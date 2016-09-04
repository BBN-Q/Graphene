%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KIT Sweeping Software
% version 1.0 in July 2016 by Leonardo Ranzani and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = S21_vs_Ibias_Pumpfreq_PumpPow(BiasList, PumpFreqList, PumpPowerList, InitialWaitTime, measurementWaitTime)
StarTime = clock;
pause on;
IBiasSource = deviceDrivers.Keithley2400();
IBiasSource.connect('23');
PumpSource = deviceDrivers.AgilentN5183A();
PumpSource.connect('19');%PumpSource.connect('192.168.5.102');
VNA = deviceDrivers.AgilentE8363C;
VNA.connect('16');%VNA.connect('192.168.5.101');

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
%%% Taking reference trace %%%
PumpSource.output = 0;
IBiasSource.value = mean(BiasList);
pause(InitialWaitTime);
[FreqList, Sparameters] = VNA.getTrace();
data.Freq = FreqList;
data.refS21 = Sparameters;
PumpSource.output = 1;
data.PumpFreq = PumpFreqList;
data.PumpPower = PumpPowerList;
data.VBias = BiasList;

for j=1:length(BiasList)
    IBiasSource.value = BiasList(j);
    for m=1:length(PumpFreqList)
        PumpSource.frequency = PumpFreqList(m);
        disp(['Current sweep at: V_bias = ' num2str(BiasList(j)) ' and f_pump = ' num2str(PumpFreqList(m))]);
        for k=1:length(PumpPowerList)
            PumpSource.power = PumpPowerList(k);
            pause(measurementWaitTime);
            VNA.connect('16');%VNA.connect('192.168.5.101');
            [FreqList, Sparameters] = VNA.getTrace();
            data.S21(j, m, k, :) = Sparameters;
            VNA.disconnect();
            %plot_data()
        end
        save('Backup.mat')
    end
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
PumpSource.disconnect(); IBiasSource.disconnect(); VNA.disconnect();
pause off; clear Lockin FileName StarTime GateCtrller VNA FreqList;
end