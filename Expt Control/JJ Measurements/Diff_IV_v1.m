%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Differential resistance measurement for Josephson junction
% with Lockin measuring resistance and Yoko providing dc bias
% Created in June 2015 by KC Fong and Evan
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Diff_IV_data = Diff_IV_v1()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear Diff_IV_data;
%close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
Yoko = deviceDrivers.YokoGS200();
Yoko.connect('2');
Lockin = deviceDrivers.SRS830();
Lockin.connect('9');

% Initialize variables
% DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = pwd;
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('Diff_IV_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Differential IV using Yoko and SR830 \r\n'));
fprintf(FilePtr,'Yoko_DC_V\tLockinX\tLockinY\r\n');
fclose(FilePtr);

% temperature log loop
LockinExcitVolt = .1/100;
LoadResistor = 1e3;
prompt = 'What is the start dc voltage (V)? ';
StartDCVoltage = input(prompt);
prompt = 'What is the step dc voltage (V)? ';
StepDCVoltage = input(prompt);
prompt = 'How many steps in total? ';
TotalStep = input(prompt);
WaitTime = 3*Lockin.timeConstant();

figure; pause on;
for j = 1:TotalStep
    SetVolt = (j-1)*abs(StepDCVoltage) - abs(StartDCVoltage);
    Yoko.value = SetVolt;
    if j == 1
        pause(WaitTime + 10);
    else pause(WaitTime);
    end
    Diff_IV_data(j,:) = [SetVolt Lockin.X() Lockin.Y()];
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    fprintf(FilePtr,'%e\t%e\t%e\r\n',Diff_IV_data(j,:));
    fclose(FilePtr);
    clf; plot(Diff_IV_data(:,1)/LoadResistor, Diff_IV_data(:,2)/(LockinExcitVolt/LoadResistor)); grid on; xlabel('Current (A)'); ylabel('dV/dI (Ohm)'); title(strcat('Diff IV measurement for Josephson junction, start date and time: ', datestr(StartTime)));
end
Yoko.value = 0;
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Yoko.disconnect(); Lockin.disconnect();
clear SetVolt, Yoko, Lockin;