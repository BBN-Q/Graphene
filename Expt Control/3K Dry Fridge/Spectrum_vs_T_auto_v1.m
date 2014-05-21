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
function data = Spectrum_vs_T_auto_v1(SetTArray)
temp = instrfind;
if ~isempty(temp)
    fclose(temp);
    delete(temp);
end
clear temp StartTime start_dir XCNoiseData j;
close all;
fclose all;

figure(1);clf;hold all;grid on; xlabel('Frequency Hz');ylabel('Power V^2');title('Power spectrums');
figure(2);clf;

% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.CryoCon22();
TC.connect('12');
SA = deviceDrivers.HP71000();
SA.connect('18');

% Initialize variables
descriptiveName = input('Give a keyword for the file name (as string): ');
allowableStdError = input('What is maximum acceptable stdev (in K): ');
allowableMeanError = input('What is maximum acceptable error in setpoint (in K): ');
SAWaitTime = input('Enter waiting time for spectrum averaging in seconds: ');
start_dir = 'C:\Users\qlab\Documents\Graphene Data\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('Spectum_', descriptiveName,'_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
fprintf(FilePtr, strcat(datestr(StartTime), ' Spectrum using HP7100 vs. Temperature using CryoCon\r\n'));

%create column headers
fprintf(FilePtr,'Set_T(K)\tMean_T(K)\tStdev_T(K)\tmeanAmp_V^2');

%get frequency range for x axis
[freq,amp]=SA.downloadTrace();
for i=1:length(freq)
    fprintf(FilePtr,strjoin({'\t',num2str(freq(i))},''));
end
fprintf(FilePtr,'\r\n');
fclose(FilePtr);

%create data array to save along with .dat (inialized to pi to make sure
%everything goes right)
data=pi*ones(length(SetTArray)+1,length(freq)+4);
data(1,5:end)=freq;

% temperature log loop
pause on;
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
    temperature=zeros([1,4*SAWaitTime]);
    i=0;
    
    %use 0 to signify, take point at base T
    if SetTArray(m)==0
        flag=1;
    end
    
    while flag == 0
        temperature(i+1) = TC.temperatureA();
        errorStd = std(temperature);
        errorMean = abs(SetTArray(m) - mean(temperature));
        if errorStd < allowableStdError && errorMean < allowableMeanError && min(temperature)~=0
            flag=1;
        end
        i=mod(i+1,120);
        pause(0.25)
    end
    pause(30);
    %record T while averaging (every 250ms)
    SA.clear_trace();
    temperature=zeros([1,4*SAWaitTime]);
    tic
    for p=1:4*SAWaitTime;
        temperature(p)=TC.temperatureA();
        pause(0.25);
    end
    toc
    
    [freq,amp]=SA.downloadTrace();
    amp=amp.*amp; %square the voltage
    fprintf(FilePtr,strjoin({num2str(SetTArray(m)),num2str(mean(temperature)),num2str(std(temperature)),num2str(mean(amp))},'\t'));
    
    for i=1:length(amp)
        fprintf(FilePtr,strjoin({'\t',num2str(amp(i))},''));
    end
    fprintf(FilePtr,'\r\n');
    fclose(FilePtr);
    
    data(m+1,1)=SetTArray(m);
    data(m+1,2)=mean(temperature);
    data(m+1,3)=std(temperature);
    data(m+1,4)=mean(amp);
    data(m+1,5:end)=amp;
    
    
    figure(1);
    semilogy(data(1,5:end),data(m+1,5:end));
    figure(2);clf;
    scatter(data(2:m+1,2), data(2:m+1,4)); grid on; xlabel('mean T (K)'); ylabel('mean spectrum amplitude (V^2)'); title('mean spectrum power vs T');
end
TC.loopTemperature = 0; TC.range='LOW'; TC.pGain=1; TC.iGain=1;
TC.disconnect();
SA.disconnect();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear TC SA;