%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = VNA_vs_Vgate(VgateList, InitialWaitTime, measurementWaitTime)
pause on;
clear data Lockin
GateCtrller = deviceDrivers.Keithley2400();
GateCtrller.connect('23');
%Lockin = deviceDrivers.SRS865();
%Lockin.connect('4');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(737); clf; mesh(1e-6*data.Freq,VgateList,20*log10(abs(data.S))); %view(2); xlabel('Frequency (MHz)'); ylabel('V_{gate} (V)');
    %figure(738); clf; plot(VgateList(1:k),data.X,'.-'); xlabel('V_{gate} (V)'); ylabel('Lockin X (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%data.S = zeros(length(VgateList),2048);
%RampGateVoltage(VgateList(1), 10*InitialWaitTime)
pause(InitialWaitTime);
for k = 1:length(VgateList)
    if k ~= 1
        GateCtrller.value = VgateList(k);
        %RampGateVoltage(VgateList(k),10*measurementWaitTime);
        %RampGateVoltage(VgateList(k),5)
    end
    pause(measurementWaitTime);
    result = GetVNASpec_VNA();
    %data.X(k) = Lockin.X; data.Y(k) = Lockin.Y;
    data.S(k,:) = result.S;
    data.Freq = result.Freq;
    %plot_data()
    save('backup.mat');
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Lockin.disconnect();
%RampGateVoltage(0, 60);
pause off; clear result Lockin GateController;
end