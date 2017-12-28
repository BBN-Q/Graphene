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
    
    pause on;
    TargetCurrent = field/421;  % current in Ampere
    InitialCurrent = MagController.value;
    Totaltime = abs(TargetCurrent-InitialCurrent)/0.064;    % total (min) ramp time in second at (max) charging rate
    CurrentList = linspace(InitialCurrent, TargetCurrent, floor(Totaltime*10)+2);
    for k = 1:length(CurrentList)-1
        eval(sprintf('MagController.value = %.4f;',CurrentList(k+1))); %MagController.value = CurrentList(k+1)
        pause(0.1);
    end
    pause off;
    ReachingTarget = 0;
    if abs(MagController.value - TargetCurrent) < 0.0001
        ReachingTarget = 1;
    else sprintf('Error in setting magnetic field');
    end
    MagController.disconnect();
end