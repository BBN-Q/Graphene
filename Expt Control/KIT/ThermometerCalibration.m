%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thermometer calibration for KIT program
% with Lockin measuring resistance
% Lakeshore AC resistance measuring temperature
% Created in June 2016 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CalibrationData = ThermometerCalibration()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear temp StartTime start_dir CoolLogData;
close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
Lakeshore = deviceDrivers.Lakeshore335();
Lakeshore.connect('12');
Lockin = deviceDrivers.SRS830();
Lockin.connect('9');

% Initialize variables
DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = 'C:\Users\qlab\Documents\data\KIT\Thermometer Calibration 2016-06\';
%start_dir = pwd;
StartTime = clock;
FileName = strcat('Calibration_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
%FilePtr = fopen(fullfile(start_dir, FileName), 'w');
%fprintf(FilePtr, strcat(datestr(StartTime), ' CoolLog using CryoCon\r\n'));
%fprintf(FilePtr,'Temperature_K\tLockinX\tLockinY\r\n');
%fclose(FilePtr);

% temperature log loop
j=1;
figure; pause on;
while true
    TValue = str2num(Lakeshore.query('RDGK? 6'));
    CalibrationData(j,:) = [etime(clock, StartTime) TValue Lockin.X() Lockin.Y()];
    pause(DataInterval);
%    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
%    fprintf(FilePtr,'%e\t%e\t%e\r\n', CalibrationData(j,:));
%    fclose(FilePtr);
    save(FileName);
    clf; plot(CalibrationData(:,2), CalibrationData(:,3)); grid on; ylabel('Lockin X (V)'); xlabel('Temperature (K)'); title(strcat('Thermometer calibration, start date and time: ', datestr(StartTime)));
    j = j+1;
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Lakeshore.disconnect(); Lockin.disconnect();
clear Lakeshore, Lockin;