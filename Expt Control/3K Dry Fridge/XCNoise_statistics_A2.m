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
function [XCNoiseData, XCNoiseStatistics] = XCNoise_statistics_A2(n,SetTimeArray)
temp = instrfind;
if ~isempty(temp)
    fclose(temp);
    delete(temp);
end
clear temp StartTime start_dir XCNoiseData j;
close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
Lockin = deviceDrivers.SRS830();
TC=deviceDrivers.CryoCon22();

% Initialize variables
filenumber=input('Input unique file number : ','s');
start_dir = 'C:\Users\qlab\Documents\data';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('XCNoise_Stat_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',filenumber, '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Cross Correlation Noise statistics\r\n'));
fprintf(FilePtr,'LockinTime_s\tCryoConT_K\tLockin_X\tLockin_Y\r\n');
fclose(FilePtr);

pause on;
TC.connect('12');
FilePtr = fopen(fullfile(start_dir, FileName), 'a');
Lockin.connect('8');
tic;
for m=1:length(SetTimeArray)
    LockinTime=SetTimeArray(m);
    Lockin.timeConstant=LockinTime;
disp(strcat('Current Lockin Time constant = ',num2str(LockinTime),'s'))
    pause(10);
    for k=1:n
        meanTemp=0;
        pause(LockinTime/2);
        if LockinTime>0.1
            for i=1:round(10*LockinTime)
                meanTemp=meanTemp+TC.temperatureA();
                pause(0.1);
            end
                meanTemp=meanTemp/round(10*LockinTime);
        else
            pause(max(LockinTime,0.01));
            meanTemp=TC.temperatureA();
        end        
        XCNoiseData(m,k,:) = [LockinTime meanTemp Lockin.X Lockin.Y];
        fprintf(FilePtr,'%f\t%f\t%E\t%E\r\n', XCNoiseData(m,k,:));
        if mod(k,100)==0
            toc;
            disp(strcat('completed ',num2str(k),' measurements out of ',num2str(n)))
        end
    end
    XCNoiseStatistics(m,:)=[LockinTime, mean(XCNoiseData(m,:,2)), std(XCNoiseData(m,:,2)),mean(XCNoiseData(m,:,3)), std(XCNoiseData(m,:,3)),mean(XCNoiseData(m,:,4)), std(XCNoiseData(m,:,4))];
    XCerror=abs(XCNoiseStatistics(m,5)/XCNoiseStatistics(m,4));
    disp(strcat('Percent error = ',num2str(XCerror*100),'%'))
%    figure;
%    hist(XCNoiseData(m,1:n,3),max(n/10,10));
%    title(strcat('Histogram of XC data from file:  ',filenumber,'      Lockin Time = ', num2str(LockinTime),'s'));
end

fclose(FilePtr);
TC.disconnect();
Lockin.disconnect();
toc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear TC Lockin;