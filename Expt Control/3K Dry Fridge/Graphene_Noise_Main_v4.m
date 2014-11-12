%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Noise Measurment Sweeping Software
% version 1.0
% Created in August 2014 by Jess Crossno
% Using:
%   CryoCon22 as Temperature Tontrol (TC)
%   Yoko GS200 as Gate Voltage Source (VG)
%   SRS830 #1 as excitation current and resistance monitor (LA1)
%   SRS830 #2 as Noise/Temperature monitor at 2f (LA2)
%
%function takes in a temperature array (K), gate voltage array (V), and excitation
%voltage array (V) then sweeps them. Basic structure is:
%Set T, wait some time, set VG, set Vex, record R and Noise
%includes Spectrum Analyzer and VNA
%
%For each T, sweep VG. For each VG, sweep Vex
%
%Vsd is the volatage drop measured across the graphene
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = Graphene_Noise_Main_v4(T_Array,Vg_Array,Vex_Array)

% Initialize the path and create the data file with header
Nmeasurements = input('How many measurements per parameter point? ');
TWaitTime = input('Enter temperature equilibration time: ');
VWaitTime1 = input('Enter initial Vg equilibration time: ');
VWaitTime2 = input('Enter Vg equilibration time for each step: ');
MeasurementWaitTime = input('Enter time between lockin measurents: ');
UniqueName = input('Enter uniquie file identifier: ','s');
AddInfo = input('Enter any additional info to include in file header: ','s');
start_dir = 'C:\Users\qlab\Documents\data\Graphene Data';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('GrapheneNoise_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName, '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
%create header string
HeaderStr=strcat(datestr(StartTime), ' Noise sweep using Graphene_Noise_Main_v1\r\nTemp stabilization time = ',...
    num2str(TWaitTime),'s\tFile number:',UniqueName,'\r\n',AddInfo,...
    '\r\nTime   \tCryoConT_(K)\tVg_(V)\tVex_(V)\tVsdX_(V)\tVsdY_(V)\tVnoiseX_(V)\tVnoiseY_(V)\r\n');
fprintf(FilePtr, HeaderStr);
fclose(FilePtr);

%Set figure output properties
figure(993);hold all;grid on;
xlabel('Frequency (MHz)');ylabel('PSD (W)');

figure(994);hold all;grid on;
xlabel('Frequency (MHz)');ylabel('S21 (dB)');

% Ending values
EndingTemperature = 0;
EndingVg = 0;
EndingVex = 1;

% Connect to the all the various devices
TC = deviceDrivers.CryoCon22();
VG = deviceDrivers.YokoGS200();
LA1 = deviceDrivers.SRS830();
LA2 = deviceDrivers.SRS830();
SA = deviceDrivers.HP71000();
VNA = deviceDrivers.AgilentE8363C();

TC.connect('12');
VG.connect('1');
LA1.connect('7');
LA2.connect('8');
SA.connect('18');
VNA.connect('128.33.89.127');

%saftey checks
T_max = 300; %max T
Vg_max = 32; %max absolute gate voltage
Vex_max = 5; %max excitation voltage

if max(T_Array)>T_max
    error('Temperature is set above T_max')
end
if max(abs(Vg_Array))>Vg_max
    error('Gate voltage is set above Vg_max')
end
if max(abs(Vex_Array))>Vex_max
    error('Excitation voltage is set above Vex_max')
end

%Save SA freq and VNA freq
[freq, amp]=SA.downloadTrace();
data.SA.freq=freq;
VNA.output='on'; VNA.reaverage();
[freq,S11]=VNA.getTrace();
VNA.output='off';
data.VNA.freq=freq;


CurrentMeasurementNumber=1; %keeps track of which measurment you are on
CurrentParameterSet=1; %keeps track of the unique parameter configs
CurrentSpectrumSet=1; %keeps track of what spectrum number you are on
pause on;

%Enter Tmperature Sweep
for T_n = 1:length(T_Array)
    
    %set Temperature and PID settings, ramps at 10Sec per Kelvin
    TC.loopTemperature = T_Array(T_n);
    if T_Array(T_n) < 5
        TC.range='LOW'; TC.pGain=10; TC.iGain=10;
    elseif T_Array(T_n) < 21
        TC.range='MID'; TC.pGain=1; TC.iGain=10;
    elseif T_Array(T_n) < 30
        TC.range='MID'; TC.pGain=10; TC.iGain=70;
    elseif T_Array(T_n) < 45
        TC.range='MID'; TC.pGain=50; TC.iGain=70;
    else
        TC.range='HI'; TC.pGain=50; TC.iGain=70;
    end
    
    %wait for temperature to stabilize
    disp(strcat('Equilibrating at T = ', num2str(T_Array(T_n)), '...'))
    pause(TWaitTime);
    
    %enter Gate Voltage Sweep
    for Vg_n = 1:length(Vg_Array)
        CurrentVg=Vg_Array(Vg_n);
        tic;
        flag=VG.ramp2V(CurrentVg);
        toc;toc;
        
        %if first Vg, pause some time
        if Vg_n==1
            pause(VWaitTime1);
        else
            pause(VWaitTime2);
        end
        
        %enter Xxcitation Voltage sweep
        for Vex_n=1:length(Vex_Array)
            CurrentVex=Vex_Array(Vex_n);
            LA1.sineAmp=CurrentVex;
            
            %comment this line out if you dont want auto gain/phase
            pause(5)
            LA1.auto_gain;%LA1.auto_phase;
            %LA2.auto_gain;%LA2.auto_phase;
            pause(30);
            
            %take "Nmeasurement" measurements
            
            for n=1:Nmeasurements
                
                %wait MeasurmentWaitTime and find average Temperature
                %if Measurment Wait Time < 100ms, record average T Cryostat
                CurrentTemp=0;
                
                for j=1:max(floor(MeasurementWaitTime*10),1)
                    CurrentTemp=CurrentTemp+TC.temperatureA();
                    pause(0.1);
                end
                
                CurrentTemp=CurrentTemp/max(floor(MeasurementWaitTime*10),1);
                
                %Record current Source-Drain Voltage across graphene
                [VsdX,VsdY,VsdR,VsdTH]=LA1.get_signal();
                
                %Record current noise voltage
                [VnX,VnY,VnR,VnTH]=LA2.get_signal();
                
                %Recond the time
                CurrentTime=clock;
                
                %add results into "data"
                data.raw.time(CurrentMeasurementNumber)=round(etime(CurrentTime,StartTime)*100)/100;
                data.raw.CryoT(CurrentMeasurementNumber)=CurrentTemp;
                data.raw.Vg(CurrentMeasurementNumber)=CurrentVg;
                data.raw.Vex(CurrentMeasurementNumber)=CurrentVex;
                data.raw.VsdX(CurrentMeasurementNumber)=VsdX;
                data.raw.VsdY(CurrentMeasurementNumber)=VsdY;
                data.raw.VsdR(CurrentMeasurementNumber)=VsdR;
                data.raw.VsdTH(CurrentMeasurementNumber)=VsdTH;
                data.raw.VnX(CurrentMeasurementNumber)=VnX;
                data.raw.VnY(CurrentMeasurementNumber)=VnY;
                data.raw.VnR(CurrentMeasurementNumber)=VnR;
                data.raw.VnTH(CurrentMeasurementNumber)=VnTH;
                
                %save results to file
                tmp=[CurrentTemp,CurrentVg,CurrentVex,VsdX,VsdY,VnX,VnY];
                FilePtr = fopen(fullfile(start_dir, FileName), 'a');
                fprintf(FilePtr,'%s\t',datestr(CurrentTime,'HH:MM:SS'));
                fprintf(FilePtr,'%g\t%g\t%g\t%g\t%g\t%g\t%g\r\n',tmp);
                fclose(FilePtr);
                
                %increment the measurement number
                CurrentMeasurementNumber=CurrentMeasurementNumber+1;
            end
            
            
            
            %calculate averages and standard deviation for parameter set
            data.time(CurrentParameterSet,:)=[data.raw.time(end-Nmeasurements+1),data.raw.time(end)];
            data.CryoT(CurrentParameterSet)=mean(data.raw.CryoT(end-Nmeasurements+1:end));
            data.std.CryoT(CurrentParameterSet)=std(data.raw.CryoT(end-Nmeasurements+1:end));
            data.Vg(CurrentParameterSet)=mean(data.raw.Vg(end-Nmeasurements+1:end));
            data.Vex(CurrentParameterSet)=mean(data.raw.Vex(end-Nmeasurements+1:end));
            
            data.VsdX(CurrentParameterSet)=mean(data.raw.VsdX(end-Nmeasurements+1:end));
            data.std.VsdX(CurrentParameterSet)=std(data.raw.VsdX(end-Nmeasurements+1:end));
            data.VsdY(CurrentParameterSet)=mean(data.raw.VsdY(end-Nmeasurements+1:end));
            data.std.VsdY(CurrentParameterSet)=std(data.raw.VsdY(end-Nmeasurements+1:end));
            data.VsdR(CurrentParameterSet)=mean(data.raw.VsdR(end-Nmeasurements+1:end));
            data.std.VsdR(CurrentParameterSet)=std(data.raw.VsdR(end-Nmeasurements+1:end));
            data.VsdTH(CurrentParameterSet)=mean(data.raw.VsdTH(end-Nmeasurements+1:end));
            data.std.VsdTH(CurrentParameterSet)=std(data.raw.VsdTH(end-Nmeasurements+1:end));
            
            data.VnX(CurrentParameterSet)=mean(data.raw.VnX(end-Nmeasurements+1:end));
            data.std.VnX(CurrentParameterSet)=std(data.raw.VnX(end-Nmeasurements+1:end));
            data.VnY(CurrentParameterSet)=mean(data.raw.VnY(end-Nmeasurements+1:end));
            data.std.VnY(CurrentParameterSet)=std(data.raw.VnY(end-Nmeasurements+1:end));
            data.VnR(CurrentParameterSet)=mean(data.raw.VnR(end-Nmeasurements+1:end));
            data.std.VnR(CurrentParameterSet)=std(data.raw.VnR(end-Nmeasurements+1:end));
            data.VnTH(CurrentParameterSet)=mean(data.raw.VnTH(end-Nmeasurements+1:end));
            data.std.VnTH(CurrentParameterSet)=std(data.raw.VnTH(end-Nmeasurements+1:end));
            CurrentParameterSet=CurrentParameterSet+1;
            
            %plot
            %figure(991);xlabel('CryoCon Temperature (K)');ylabel('Noise Voltage (uV)');
            %plot(data.CryoT,data.VnoiseX);
            %figure(992);xlabel('Gate Voltage (V)+100*T(K)');ylabel('Resistance (Ohm)');
            %plot(data.Vg+100*data.CryoT,1E7*data.VsdX./data.Vex);
        end
        
        %Record Spectrum
        [freq, amp]=SA.downloadTrace();
        data.SA.spectrum(CurrentSpectrumSet,:)=amp;
        
        %Record VNA
        VNA.output='on'; VNA.reaverage();
        [freq,S11]=VNA.getTrace();
        VNA.output='off';
        data.VNA.S11(CurrentSpectrumSet,:)=S11;
        pause(60);
        
        CurrentSpectrumSet=CurrentSpectrumSet+1;
        
        figure(993);
        plot(data.SA.freq/1E6,data.SA.spectrum(CurrentSpectrumSet-1,:));
        figure(994);
        plot(data.VNA.freq/1E6,10*log10(abs(data.VNA.S11(CurrentSpectrumSet-1,:)).^2));
        
    end
end

VG.ramp2V(EndingVg);
LA1.sineAmp=EndingVex;
TC.loopTemperature = EndingTemperature;
TC.range='LOW'; TC.pGain=1; TC.iGain=1;

%clean things up
TC.disconnect();
VG.disconnect();
LA1.disconnect();
LA2.disconnect();
SA.disconnect();
VNA.disconnect();
pause off;