%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Controlling the magnetic field using a small, accurate current supply
% version 1.0 in Dec 2017 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ReachingTarget = SmallBFieldController(field)  % in Gauss, persistent heat switch ON
    % MAKE SURE to measure current and source current up to 1 Ampere
    % AMI magnet spec:
    % 421 Gauss/A
    % Charging voltage = 1.0 Volt
    % Charging rate = 0.064 A/sec
    % Measured inductance = 15.7 Henrys
    % Persistent switch heater current = 0.021 A
    % Persistent switch heater resistance = 83 Ohms
    MagController = deviceDrivers.Keithley2400();
    MagController.connect('24');
    
    TargetCurrent = field/421;  % current in Ampere
    InitialCurrent = MagController.value;
    Totaltime = abs(TargetCurrent-InitialCurrent)/0.064;    % total (min) ramp time in second at (max) charging rate
    CurrentList = linspace(InitialCurrent, TargetCurrent, floor(Totaltime*10)+2)
    for k = 1:length(CurrentList)-1
        eval(sprintf('MagController.value = %.4f;',CurrentList(k+1))); %MagController.value = CurrentList(k+1)
        pause on;
        pause(1);
        pause off;
    end
    ReachingTarget = 0;
    pause on; pause(3); pause off; % arbitarily chosen settling time
    if abs(MagController.value - TargetCurrent) < 0.000237*5 % corresponding to 0.5 Gauss
        ReachingTarget = 1;
    else sprintf('Error in setting magnetic field')
    end
    MagController.value
    MagController.disconnect();
end