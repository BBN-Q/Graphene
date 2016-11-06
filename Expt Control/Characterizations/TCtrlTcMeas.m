%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Temperature Controlled Tc Measurement Software
% version 3.0 in Nov 2016 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = TCtrlTcMeas(TList, InitialWaitTime, TSettlingWaitTime)
pause on;
TController = deviceDrivers.Lakeshore335();
TController.connect('2');
Lockin = deviceDrivers.SRS830();
Lockin.connect('9');

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); clf; plot(data.T(1:k), data.X, '.-'); grid on;
    xlabel('Temperature (K)'); ylabel('Lockin X (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
TController.set_setpoint(1, TList(1))
pause(InitialWaitTime);
for k=1:length(TList)
    if k~=1
        pause(TSettlingWaitTime);
        disp(['Temperature sets to ' num2str(TList(k)) ' K'])
        disp(['Time now is ' datestr(clock) '; collecting data after ' num2str(TSettlingWaitTime/60) ' mins'] )
    end
    data.X(k) = Lockin.X; data.Y(k) = Lockin.Y;
    data.T(k) = TController.get_temperature('A');
    if k<length(TList)
        TController.set_setpoint(1, TList(k+1));
    else
        TController.set_setpoint(1, 0.001);
    end
    plot_data()
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = 0;
Lockin.disconnect(); TController.disconnect();
%Lockin.disconnect();
pause off; clear Lockin TController;
end