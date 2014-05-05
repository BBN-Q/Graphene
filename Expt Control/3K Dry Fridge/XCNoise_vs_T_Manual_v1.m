%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Manual Cross-Correlation Noise Testing
% version 1.0
% Created in May 2014 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function XCNoiseData = XCNoise_vs_T_Manual_v1()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear temp StartTime start_dir XCNoiseData j;
close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.CryoCon22();
TC.connect('12');
DVM = deviceDrivers.Keithley197();
DVM.connect('19');

% Initialize variables
start_dir = 'C:\Users\qlab\Documents\Graphene Data\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('XCNoise_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Cross Correlation Noise vs. Temperature using CryoCon\r\n'));
fprintf(FilePtr,'CryoConT_K\tMultiplier_V\r\n');
fclose(FilePtr);

% temperature log loop
j=1; ContinueFlag = true;
figure;
while ContinueFlag
    XCNoiseData(j,:) = [TC.temperatureA() str2num(DVM.value())];
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    fprintf(FilePtr,'%f\t%f\r\n',XCNoiseData(j,:));
    fclose(FilePtr);
    plot(XCNoiseData(:,1), XCNoiseData(:,2)); grid on; xlabel('T_{CryoCon} (K)'); ylabel('V_{Cross-Correlation} (V)'); title(strcat('XC Noise ', pwd));
    ContinueFlag = input('Continue? ')
    TC.loopTemperature = ContinueFlag;
    j = j+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TC.disconnect(); DVM.disconnect();
clear TC DVM;