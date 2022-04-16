%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = DC_IV_DMMmeasure_Keithley2400excite(IbiasList, InitialWaitTime, measurementWaitTime)
pause on;
CurrSource = deviceDrivers.Keithley2400();
CurrSource.connect('24');
VoltMeas = deviceDrivers.Keysight34410A();
VoltMeas.connect('22');
CurrMeas = deviceDrivers.Keysight34410A();
CurrMeas.connect('17');

% GateSource = deviceDrivers.Keithley2400();
% GateSource.connect('23');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%

function plot_data()
    figure(338); clf; plot(IbiasList(1:k), 1e3*data.DMM(1:k), '.-'); grid on;
    ylabel('V_{DMM} (mV)'); xlabel('Current (A)');
end



CurrSource.value = IbiasList(1);
pause(InitialWaitTime);

for k = 1:length(IbiasList)
    CurrSource.value = IbiasList(k);
    pause(measurementWaitTime);
    %pause(round(RampTime/length(VList),1)+0.1);
%     pause(0.5);
    data.DMM(k) = VoltMeas.value;
    data.SourceCurrent(k) = CurrSource.value;
    data.Current(k) = CurrMeas.value;
    plot_data()
    
   
end


%pause off;
CurrSource.disconnect(); VoltMeas.disconnect();

clear RampVBias k GateController InitialWaitTime measurementWaitTime StartTime
end
