%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect mean Signal Analyzer values for a temperature sweep
% Intended for 3K Dry Fridge
% Created in May 2014 by KC Fong and Jesse Crossno

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%     CLEAR      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
clear temp CoolLogData;
% close all
% fclose all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%     INITIALIZE PATH and Experiment     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
startTemp = input('Starting Temp? ');
endTemp = input('Final Temp? ');
points = input('Number of Temperature Points? ');
input('make sure the spectrum analyzer trace is in volts and covers the proper range');
logsteps = 1;
TC = deviceDrivers.CryoCon22();
TC.connect('12');
SA = deviceDrivers.HP71000();
SA.connect('18');
base_path = 'C:\Users\qlab\Documents\Graphene Data\50Ohm_Johnson_Noise\';
%cd(base_path)
% addpath([ base_path,'data'],'-END');
filename='R50spec_vs_T_';
filename = strjoin({'R50spec_vs_T_',datestr(now, 'yyyymmdd_HHMMSS'),'.txt'},'');
FilePtr = fopen(fullfile(base_path, filename),'w');
StartTime = clock;
fprintf(FilePtr, strcat(datestr(StartTime), ' Mean power in Volts^2 from DC to 1GHz\r\nSingle Miteq+minicircuit amplifier chain\r\nvidave=100 resBW=3MHz\r\n\r\n'));
fprintf(FilePtr,'Time_s\tTemperature_K\tmean V^2\r\n');


%how long to wait between checking the temperature during ramping
rampPauseTime = 5;
%take measurement once temperature is within a factor +/- this value
temperatureDeviation = 0.01;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%setup the PID loop
pause on

TC.loopTemperature = startTemp;
pause(1);
TC.loopStart();
pause(10);

figure;hold;
for i=0:points-1
    
    %set the next temperature setpoint
    if logsteps==1
        temp=startTemp*(endTemp/startTemp)^(i/max(1,points-1));
    else
        temp=startTemp+(endTemp/startTemp)*(i/max(1,points-1));
    end
    TC.loopTemperature = temp;
    
    %wait for the temperature to ramp
    while abs(1-TC.temperatureA()/temp)>temperatureDeviation
        pause(rampPauseTime);
    end
    pause(60);
    
    %wait 40s for n=100 spectra to be averaged while averageing temperature
    aveTemp=0;
    for j=1:40
        currentTemp = TC.temperatureA();
        aveTemp=aveTemp+currentTemp;
        pause(1)
    end
    aveTemp=aveTemp/40;
    
    %get the sprectrum analyzer trace in |volts| and square it
    [freq,tmp] = SA.downloadTrace();
    tmp=tmp.^2;
    
    %set the first point on the trace to be the ave temperature
    tmp(1)=aveTemp;
    
    %if this is the first point, initialize the data array
    if i==0
        s=size(tmp);
        data=zeros(s(1),points+1);
        %set the first column to be the frequencies
        freq(1)=0;
        data(:,1)=freq;
    end
    data(:,i+2)=tmp;
    plot(freq,tmp);
    xlabel('Freq (Hz'); ylabel('Power (volts^2)'); title('Power spectrums vs temperature'); grid on;
end

%turn off the heater
TC.loopStop();

%create format string
str='';
for i=0:points
    str=strjoin({str,'%G\t'},'');
end
str=strjoin({str,'\r\n'},'');

fprintf(FilePtr,s,data);







