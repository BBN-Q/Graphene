%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using CryoCon Temperature Controller
% Created in May 2014 by Jesse Crossno and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function spec = CryoCon_XC_Spec_CoolLog()
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear temp StartTime start_dir CoolLogData;
close all;
fclose all;

% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.CryoCon22();
SA = deviceDrivers.HP71000();

%Connect to Lockin
Lockin = deviceDrivers.SRS830();

% Initialize variables
DataInterval = input('Time interval in temperature readout (in second) = ');
start_dir = 'C:\Users\qlab\Documents\data\3K_CoolLogs';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('CoolLog_and_XC_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' CoolLog using CryoCon and XC @ 1s\r\n'));
fprintf(FilePtr,'Time_s\tTemperature_K\tLockinX_V\tLockinY_V\r\n');
fclose(FilePtr);

global spec;
% temperature log loop
j=1;
figure; pause on;
SA.connect('18');
[freq, amp]=SA.downloadTrace();
spec.freq=freq;
SA.disconnect();
T=300;
while true
    TC.connect('12');
    Lockin.connect('8');
    T =TC.temperatureA();
    X=Lockin.X;
    Y=Lockin.Y;
    CoolLogData(j,:) = [etime(clock, StartTime) T X Y];
    TC.disconnect();
    Lockin.disconnect();
    pause(DataInterval);
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    fprintf(FilePtr,'%0.3f\t%f\t%E\t%E\r\n',CoolLogData(j,:));
    fclose(FilePtr);
    [hAx,hLine1,hLine2] = plotyy(CoolLogData(:,1)/60, CoolLogData(:,2), CoolLogData(:,1)/60, CoolLogData(:,3)); 
    grid on; xlabel('Time (min.)'); title(strcat('CoolLog using CryoCon, start date and time: ', datestr(StartTime)));
    ylabel(hAx(1),'Temperature (K)');
    ylabel(hAx(2),'Lockin XC (V)');
    j = j+1;
    if mod(j,10)==0
        n=j/10;
        SA.connect('18');
        [freq, amp]=SA.downloadTrace();
        SA.disconnect();
        spec.T(n)= T;
        spec.X(n)=X;
        spec.Y(n)=Y;
        spec.Amp(n,:)=amp;
    end
   
        
        
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear TC Lockin;