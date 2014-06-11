%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Manual Cross-Correlation Noise Testing
% version 2.0
% Created in May 2014 by KC Fong
% Using ALAZAR TECH and FFT
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%     CLEAR  and INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function XCNoiseData = XCNoise_vs_T_Auto_v7(SetTArray)
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
TraceLength = 2^27; Freq_MHz = 1e-6*linspace(0, 100e6, TraceLength); AnalyzingBandwidth_MHz = [19 24];
BWIndex = round(interp1(Freq_MHz, linspace(1,TraceLength, TraceLength), AnalyzingBandwidth_MHz));
figure; pause on; %pause(WaitTime*1.5);
for m = 1:length(SetTArray)
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    TC.connect('12');
    sprintf(strcat('Taking data at set T = ', num2str(SetTArray(m)), ', progress = ', num2str(100*m/length(SetTArray)), '%%'))
    for k=1:20
        DoubleTraces = GetAlazarTraces(.2, 100e6, TraceLength, 'False');
        FFT1stTrace = fft(DoubleTraces(:,2)); FFT2ndTrace = fft(DoubleTraces(:,3));
        AvgXCPSD = dot(conj(FFT1stTrace(BWIndex(1):BWIndex(2))), FFT2ndTrace(BWIndex(1):BWIndex(2)))/(BWIndex(2)-BWIndex(1)+1);     
        XCNoiseData(j,:) = [TC.temperatureA() AvgXCPSD];
        fprintf(FilePtr,'%f\t%e\t%e\r\n', [XCNoiseData(j,1)  real(XCNoiseData(j,2)) imag(XCNoiseData(j,2))]);
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
    plot(XCNoiseData(:,1), real(XCNoiseData(:,2)), XCNoiseData(:,1), imag(XCNoiseData(:,2)), 'r'); grid on; xlabel('T_{CryoCon} (K)'); ylabel('PSD_{xc}'); title(strcat('XC Noise ', pwd));
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