%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaporation cooling
% version 1.0 in August 2021 by BBN Cool Team: Mary, Caleb, Bevin, and KC
%
% Set temperature, then monitor for a duration before quitting
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [Tdata] = SetHelmholtzT(SetT, MonitorTime_s, ChannelNum)
TController = deviceDrivers.Lakeshore370();
TController.connect('12');  
if ~exist('ChannelNum', 'var') ChannelNum = 6; end
if MonitorTime_s < 10
    MonitorTime_s = 10;
end

% Set temperature, then monitor for a duration before quitting
% Use ZONE setting

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(333); clf; plot(Tdata.time, 1e3*Tdata.T, '.-'); grid on;
    xlabel('time (s)'); ylabel('T (mK)');
    title(strcat('Set to ', num2str(SetT), ' K starting at ', datestr(StartTime)));
end

%%%%%%%%%%%%%%%%%%%%%       Set Temperature and take DATA     %%%%%%%%%%%%%%%%%%%%%%%%
pause on;
TotalTime = 1; k = 1;
StartTime = clock;
TController.set_setpoint(ChannelNum, SetT);
Tdata.StartTime = StartTime;
while TotalTime < MonitorTime_s
    TotalTime = etime(clock, StartTime);
    Tdata.time(k) = TotalTime;
    Tdata.T(k) = TController.get_temperature(ChannelNum);
    TController.disconnect();
    [htr_curr, htr_power, curr_range] = HeaterCurrQuery_LakeShore();
    TController.connect('12');  
    Tdata.HtrCurr(k) = htr_curr;
    Tdata.HtrPower(k) = htr_power;
    k = k+1;
    plot_data()
    pause(1);
end
Tdata.HtrCurrRange = curr_range;

pause off;
TController.disconnect();
disp([datestr(now), ': Completed and the average temperature of last 10 data points is ', num2str(mean(Tdata.T(end-9:end))), ' K'])
end