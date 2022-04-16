%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
% modified by Mary for three probe measurement with DMM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = DC_IV_DMMmeasure_Keithley2400VBias(VbiasList, InitialWaitTime, measurementWaitTime)
pause on;
VSource = deviceDrivers.Keithley2400();
VSource.connect('24');
VoltMeas = deviceDrivers.Keysight34410A();
VoltMeas.connect('22');
CurrMeas = deviceDrivers.Keysight34410A();
CurrMeas.connect('17');

% GateSource = deviceDrivers.Keithley2400();
% GateSource.connect('23');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%

function plot_data()
    figure(338); clf; plot(VbiasList(1:k), 1e3*data.DMM(1:k), '.-'); grid on;
    ylabel('V_{DMM} (mV)'); xlabel('Current (A)');
end



VSource.value = VbiasList(1); %keithley sets voltage
pause(InitialWaitTime);

for k = 1:length(VbiasList)
    VSource.value = VbiasList(k);
    pause(measurementWaitTime);
    %pause(round(RampTime/length(VList),1)+0.1);
%     pause(0.5);
    data.DMM(k) = VoltMeas.value; % measure DMM voltage
    data.SourceCurrent(k) = VSource.value;
    data.MeasCurrent(k) = CurrMeas.value;
    plot_data()
    
   
end


%pause off;
VSource.disconnect(); VoltMeas.disconnect(); CurrMeas.disconnect();

clear RampVBias k GateController InitialWaitTime measurementWaitTime StartTime
end
