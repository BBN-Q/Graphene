%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% March 2020 Sean Cheng
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = Spec_vs_Vgate(VgateList, InitialWaitTime, MeasurementWaitTime)
pause on;
GateController = deviceDrivers.Keithley2400();
GateController.connect('23');
SA = deviceDrivers.AgilentN9020A();
SA.connect('128.33.89.87');

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
GateController.value = VgateList(1);
pause(InitialWaitTime);
for k=1:length(VgateList)
    GateController.value = VgateList(k);
    pause(MeasurementWaitTime);
    [freq,ampdBm] = SA.SAGetTrace();
    data.ampdBm(:,k)=ampdBm;
    plot(freq'*1e-6,data.ampdBm)
end
data.freq = freq;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
GateController.value = 0;
GateController.disconnect()
SA.disconnect()
pause off; clear result;
end