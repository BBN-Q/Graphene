%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Manual Cross-Correlation Noise Testing
% version 2.0
% Created in May 2014 by KC Fong
% Using ALAZAR TECH
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [XCNoiseData, XCNoiseStatistics] = XCNoise_vs_T_Auto_v2(SetTArray)
% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.CryoCon22();

% Initialize variables
TWaitTime = input('Enter waiting time for temperature stabilizing to new set point in seconds: ');
start_dir = pwd;
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('XCNoise_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Cross Correlation Noise vs. Temperature using CryoCon\r\n'));
fprintf(FilePtr,'CryoConT_K\tCrossCorrelatedV_V\r\n');
fclose(FilePtr);

% temperature log loop
j=1;
figure; pause on; %pause(WaitTime*1.5);
for m = 1:length(SetTArray)
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    TC.connect('12');
    sprintf(strcat('Taking data at set T = ', num2str(SetTArray(m)), ', progress = ', num2str(100*m/length(SetTArray)), '%%'))
    for k=1:10
        DoubleTraces = GetAlazarTraces(0.04, 500e6, 20E6, 'False');
        XCNoiseStatistics.ChAMean(j) = mean(DoubleTraces(:,2));
        XCNoiseStatistics.ChBMean(j) = mean(DoubleTraces(:,3));
        XCNoiseStatistics.ChAStd(j) = std(DoubleTraces(:,2));
        XCNoiseStatistics.ChBStd(j) = std(DoubleTraces(:,3));
        XCNoiseStatistics.Temperature(j) = TC.temperatureA();
        DoubleTraces(:,2) = DoubleTraces(:,2) - XCNoiseStatistics.ChAMean(j);
        DoubleTraces(:,3) = DoubleTraces(:,3) - XCNoiseStatistics.ChBMean(j);
        XCNoiseData(j,:) = [XCNoiseStatistics.Temperature(j) dot(DoubleTraces(:,2), DoubleTraces(:,3))/length(DoubleTraces)];
        fprintf(FilePtr,'%f\t%e\r\n', XCNoiseData(j,:));
        j = j+1;
    end    
    fclose(FilePtr);
    %AllDoubleTraces(:,j) = DoubleTraces(:,2);
    if m < length(SetTArray)
        TC.loopTemperature = SetTArray(m+1);
        if SetTArray(m) < 21
            TC.range='MID'; TC.pGain=1; TC.iGain=10;
        elseif SetTArray(m) < 30
            TC.range='MID'; TC.pGain=10; TC.iGain=70;
        elseif SetTArray(m) < 45
            TC.range='MID'; TC.pGain=50; TC.iGain=70;
        elseif SetTArray(m) < 100
            TC.range='HI'; TC.pGain=50; TC.iGain=70;
        else
            TC.range='HI'; TC.pGain=50; TC.iGain=70;
        end
    else
        TC.loopTemperature = 0.001; TC.range='LOW'; TC.pGain=1; TC.iGain=1;
    end
    TC.disconnect();
    plot(XCNoiseData(:,1), XCNoiseData(:,2)); grid on; xlabel('T_{CryoCon} (K)'); ylabel('V_{xc} (V)'); title(strcat('XC Noise ', pwd));
    if m < length(SetTArray)
        sprintf(strcat('Waiting to new set T = ', num2str(SetTArray(m+1)), '...'))
        pause(TWaitTime);
    end
end
pause off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear TC;