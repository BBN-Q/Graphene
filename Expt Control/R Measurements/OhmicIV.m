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

base_path = 'C:\Documents and Settings\qlab\My Documents\data\Graphene\';
cd(base_path)
% addpath([ base_path,'data'],'-END');
filename = '20140327_mixer_2f_power.txt';
data = fopen(filename,'w');
pause on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%     INITIALIZE  EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pauseTime = 8;

% Connect to Lockin
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
StartVexcit = 0.01;
StepVexcit = 0.01;
StopVexcit = 1;
[VexcitArray, NumSteps] = ScanArrayGenerator(StartVexcit, StopVexcit, StepVexcit, 0);

for k=1:NumSteps
    Lockin.write('
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       PLOT AND SAVE DATA     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Lockin.disconnect();
clear Lakeshore, Lockin;
