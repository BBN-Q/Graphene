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
function XCNoiseData = Spectrum_vs_T_auto_v1(SetTArray, inst)
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
SA = deviceDrivers.HP71000();
SA.connect('18');

% Initialize variables
TWaitTime = input('Enter waiting time for temperature stabilizing to new set point in seconds: ');
allowableError = input('What is maximum acceptable normalized stdev (Stdev/mean) (default=0.01): ');
SAWaitTime = input('Enter waiting time for spectrum averaging in seconds: ');
start_dir = 'C:\Users\qlab\Documents\Graphene Data\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('Spectum_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Spectrum using HP7100 vs. Temperature using CryoCon\r\n'));

%create column headers
fprintf(FilePtr,'Set_T(K)\tMean_T(K)\tStdev_T(K)\tmeanAmp_V^2');

%get frequency range for x axis
[freq,amp]=SA.downloadTrace();
for i=1:length(freq)
    fprintf(FilePtr,srtjoin({'\t',num2str(freq(i))},''));
end
fprintf(FilePtr,'\r\n');
fclose(FilePtr);

%create data array to save along with .dat (inialized to pi to make sure
%everything goes right)
data=pi*ones(length(SetTArray)+1,length(freq)+3);
data(1,4:end)=freq;

% temperature log loop
pause on; %pause(WaitTime*1.5);
for m = 1:length(SetTArray)
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    sprintf(strcat('Taking data at set T = ', num2str(SetTArray(m)), ', progress = ', num2str(100*m/length(SetTArray)), '%%'))
    TC.loopTemperature = SetTArray(m);
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
    
    flag = 0;
    temperature=zeros([1,30]);
    i=0;
    while flag == 0
        temperature(i+1) = TC.temperatureA();
        error= std(temperature)/mean(temperature);
        if error<allowableError && min(T)~=0
            flag=1;
        end
        i=mod(i+1,30);
        pause(1)
    end
    
    pause(SAWaitTime);
    amp=SA.downloadTrace();
    amp=amp.*amp; %square the voltage
    fprintf(FilePtr,strjoin({num2str(SetTArray(m)),num2str(mean(temperature)),num2str(std(temperature)),num2str(mean(amp))},'\t'));
    
    for i=1:length(amp)
        fprintf(FilePtr,srtjoin({'\t',num2str(freq(i))},''));
    end
    fprintf(FilePtr,'\r\n');
    fclose(FilePtr);
    
    data(k+1,1)=SetTArray(m);
    data(k+1,2)=mean(temperature);
    data(k+1,3)=std(temperature);
    data(k+1,4:end)=amp;
    
    
    figure(1);clf;
    plot(data(2:end,2), data(2:end,4)); grid on; xlabel('mean T (K)'); ylabel('mean spectrum amplitude (V^2)'); title(strcat('mean spectrum power vs T ', pwd));
end
TC.loopTemperature = 0.001; TC.range='LOW'; TC.pGain=1; TC.iGain=1;
TC.disconnect();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear TC;