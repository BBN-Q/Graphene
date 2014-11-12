%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Manual Cross-Correlation Noise Testing
% version 1.0
% Created in May 2014 by KC Fong and Jess Crossno
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [XCNoiseData, spec] = XCNoise_vs_T_Analog_v2(SetTArray, inst)
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
switch inst
    case 'DVM'
        DVM = deviceDrivers.Keithley197();
    case 'lockin'
        Lockin = deviceDrivers.SRS830();
    otherwise
        warning('Instruments to measure cross-correlation voltage: DVM or lockin');
        SetTArray = [];
end

% Initialize variables
TWaitTime = input('Enter waiting time for temperature stabilizing to new set point in seconds: ');
LockinWaitTime = input('Enter waiting time for new cross-correlation voltage data point in seconds: ');
autoGain=input('Autogain Lockin after each temperature change? (0 or 1)');
filenumber=input('Input unique file number : ','s');
additionalHeader=input('anything else to include in the header? ','s');
start_dir = 'C:\Users\qlab\Documents\data\Graphene Data';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('XCNoise_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',filenumber,  '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Cross Correlation Noise vs. Temperature using CryoCon\r\n',additionalHeader,'\r\n'));
switch inst
    case 'DVM'
        fprintf(FilePtr,'CryoConT_K\tMultiplier_V\r\n');
    case 'lockin'
        fprintf(FilePtr,'CryoConT_K\tLockin_X\tLockin_Y\r\n');
end
fclose(FilePtr);

SA = deviceDrivers.HP71000();
SA.connect('18');
[freq, amp]=SA.downloadTrace();
spec.freq=freq;
SA.disconnect();


% temperature log loop
j=1;
figure; pause on;
TC.connect('12');
pause(0);
for m = 1:length(SetTArray)
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');

    TC.loopTemperature = SetTArray(m);
    if SetTArray(m) < 5
        TC.range='LOW'; TC.pGain=10; TC.iGain=10;
    elseif SetTArray(m) < 21
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
    disp(strcat('Waiting to new set T = ', num2str(SetTArray(m)), '...'))
    disp(datestr(clock,'HH:MM:SS'));
    %if SetTArray(m)~=0
        pause(TWaitTime);
    %end
    if autoGain==1
        Lockin.connect('8');
        Lockin.auto_gain();
        pause(20);
        Lockin.disconnect();
    end
    disp(strcat('Taking data at set T = ', num2str(SetTArray(m)), ', progress = ', num2str(100*m/length(SetTArray)), '%'));
    disp(datestr(clock,'HH:MM:SS'));
    tic
    for k=1:100
        switch inst
            case 'DVM'
                DVM.connect('19');
                XCNoiseData(j,:) = [TC.temperatureA() str2num(DVM.value())];
                fprintf(FilePtr,'%f\t%e\r\n', XCNoiseData(j,:));
                DVM.disconnect();
            case 'lockin'
                Lockin.connect('8');
                XCNoiseData(j,:) = [TC.temperatureA() Lockin.X Lockin.Y];
                fprintf(FilePtr,'%f\t%e\t%e\r\n', XCNoiseData(j,:));
                Lockin.disconnect();
            otherwise
                XCNoiseData(j,:) = [TC.temperatureA() 0];
                fprintf(FilePtr,'%f\t%e\r\n', XCNoiseData(j,:));
        end
        j = j+1;
        pause(LockinWaitTime);
    end
    
    SA.connect('18');
    [freq, amp]=SA.downloadTrace();
    SA.disconnect();
    spec.T(m)= TC.temperatureA();
    spec.Amp(m,:)=amp;
    
    
    toc
    fclose(FilePtr);
    scatter(XCNoiseData(:,1), XCNoiseData(:,2)); grid on; xlabel('T_{CryoCon} (K)'); ylabel('XC Voltage (V)'); title(strcat('XC Noise ', pwd));

end

TC.loopTemperature =0; TC.range='LOW'; TC.pGain=10; TC.iGain=10;
TC.disconnect();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear TC;