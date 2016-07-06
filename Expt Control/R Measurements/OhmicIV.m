%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%     CLEAR      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
% clear temp sigGen spec
% close all
% fclose all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%     INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%base_path = pwd;
cd(pwd);
% addpath([ base_path,'data'],'-END');
StartTime = clock;
FileName = strcat('RvsVgate_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
%data = fopen(filename,'w');
pause on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%     INITIALIZE  EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Connect to Lockin
Keithley=deviceDrivers.Keithley2400();
Keithley.connect('23');
%Yoko = deviceDrivers.YokoGS200();
%Yoko.connect('2');
Lockin = deviceDrivers.SRS865();
Lockin.connect('4');

% Initialize variables
%DataInterval = input('Time interval in temperature readout (in second) = ');
%start_dir = 'C:\Users\qlab\Documents\data\KIT\Thermometer Calibration 2016-06\';
%start_dir = pwd;
%FilePtr = fopen(fullfile(start_dir, FileName), 'w');
%fprintf(FilePtr, strcat(datestr(StartTime), ' CoolLog using CryoCon\r\n'));
%fprintf(FilePtr,'Temperature_K\tLockinX\tLockinY\r\n');
%fclose(FilePtr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
StartVexcit = -4;
StopVexcit = 4;
StepVexcit = 0.2;
[VexcitArray, NumSteps] = ScanArrayGenerator(StartVexcit, StopVexcit, StepVexcit, 0);

clear  DataArray;
Keithley.value = VexcitArray(1);
pause(3);
for k=1:NumSteps
    Keithley.value = VexcitArray(k);
    pause(1.5);
    DataArray(k, :) = [VexcitArray(k) Lockin.X Lockin.Y];
end
save(FileName)
Keithley.value = 0;
figure; plot(DataArray(:,1), DataArray(:,2)); grid on;
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       PLOT AND SAVE DATA     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Lockin.disconnect(); Keithley.disconnect();
clear Lockin, Keithley;
