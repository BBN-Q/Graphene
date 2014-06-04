%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Gathers Statistics on XC data via analog multiplier and lockin
% version 1.0
% Created in June 2014 by Jess Crossno
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [XCNoiseStatistics] = XCNoise_statistics_A1(T,n,inst)
temp = instrfind;
if ~isempty(temp)
    fclose(temp);
    delete(temp);
end
clear temp StartTime start_dir XCNoiseData j;
close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.CryoCon22();
switch inst
    case 'DVM'
        DVM = deviceDrivers.Keithley197();
    case 'lockin'
        Lockin = deviceDrivers.SRS830();
    otherwise
        warning('Instruments to measure cross-correlation voltage: DVM or lockin');
        XCNoiseStatistics = [];
end

% Initialize variables
TWaitTime = input('Enter waiting time for temperature stabilizing to new set point in seconds: ');
LockinTime = input('Enter Integration time in seconds: ');
start_dir = pwd;
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('XCNoise_Stat_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Cross Correlation Noise statistics\r\n'));
switch inst
    case 'DVM'
        fprintf(FilePtr,'CryoConT_K\tMultiplier_V\r\n');
    case 'lockin'
        fprintf(FilePtr,'CryoConT_K\tLockin_R\tLockin_theta\r\n');
end
fclose(FilePtr);

%Set Temperature
TC.connect('12');
TC.loopTemperature = T;
if T < 21
    TC.range='MID'; TC.pGain=1; TC.iGain=10;
elseif T < 30
    TC.range='MID'; TC.pGain=10; TC.iGain=70;
elseif T < 45
    TC.range='MID'; TC.pGain=50; TC.iGain=70;
elseif T < 100
    TC.range='HI'; TC.pGain=50; TC.iGain=70;
else
    TC.range='HI'; TC.pGain=50; TC.iGain=70;
end
pause on;
Pause(TWaitTime);

% temperature log loop
j=1;
figure;
for k=1:n
    meanTemp=0;
    pause(0.5);
    for i=1:10*LockinTime
        meanTemp=meanTemp+TC.temperatureA();
        pause(0.1);
    end
    meanTemp=meanTemp/(10*LockinTime);
    
    switch inst
        case 'DVM'
            DVM.connect('19');
            XCNoiseData(j,:) = [meanTemp str2num(DVM.value())];
            fprintf(FilePtr,'%f\t%e\r\n', XCNoiseData(j,:));
            DVM.disconnect();
        case 'lockin'
            Lockin.connect('8');
            XCNoiseData(j,:) = [meanTemp Lockin.R Lockin.theta];
            fprintf(FilePtr,'%f\t%e\t%e\r\n', XCNoiseData(j,:));
            Lockin.disconnect();
        otherwise
            XCNoiseData(j,:) = [meanTemp 0];
            fprintf(FilePtr,'%f\t%e\r\n', XCNoiseData(j,:));
    end
    j = j+1;
end
fclose(FilePtr);
TC.loopTemperature = 0; TC.range='LOW'; TC.pGain=1; TC.iGain=1;
TC.disconnect();

XCNoiseStatistics(1,:)=[mean(XCNoiseData(:,1)), std(XCNoiseData(:,1))];
XCNoiseStatistics(2,:)=[mean(XCNoiseData(:,2)), std(XCNoiseData(:,2))];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear TC;