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
%includes VNA
%
%For each T, sweep VG. For each VG, sweep Vex
%
%Vsd is the volatage drop across the graphene
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = Graphene_Noise_Main_v1(T_Array,Vg_Array,Vex_Array)

% Initialize the path and create the data file with header
Nmeasurements = input('How many measurements per parameter point? ');
TWaitTime = input('Enter temperature equilibration time: ');
VWaitTime = input('Enter initial Vg equilibration time: ');
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
figure(91);hold all;grid on;
xlabel('Excitation voltage (V)');ylabel('Noise Voltage (V)');

figure(92);hold all;grid on;
xlabel('Frequency (MHz)');ylabel('S11 dB');

% Ending values
EndingTemperature = 294; 
EndingVg = 0; 
EndingVex = 1; 

% Connect to the all the various devices
TC = deviceDrivers.CryoCon22();
VG = deviceDrivers.YokoGS200();
LA1 = deviceDrivers.SRS830();
LA2 = deviceDrivers.SRS830();
VNA = deviceDrivers.AgilentE8363C();

TC.connect('12');
VG.connect('1');
LA1.connect('7');
LA2.connect('8');
VNA.connect('128.33.89.127');

%saftey checks
T_max = 300; %max T
Vg_max = 25; %max absolute gate voltage
Vex_max = 2; %max excitation voltage

if max(T_Array)>T_max
    error('Temperature is set above T_max')
end
if max(abs(Vg_Array))>Vg_max
    error('Gate voltage is set above Vg_max')
end
if max(abs(Vex_Array))>Vex_max
    error('Excitation voltage is set above Vex_max')
end

%Save VNA freq
[freq,S11]=VNA.getTrace();
data.VNA.freq=freq;

CurrentMeasurementNumber=1; %keeps track of which measurment you are on
CurrentParameterSet=1; %keeps track of the unique parameter configs
pause on;

%Enter Tmperature Sweep
for T_n = 1:length(T_Array)
    
    %set Temperature and PID settings, ramps at 10Sec per Kelvin
    %%%%%%TC.ramp2T(T_Array(T_n),1);
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
        Vgflag = VG.ramp2V(CurrentVg);
        
        %if first Vg, pause some time
        if Vg_n==1
           pause(VWaitTime); 
        end
        
        %enter Xxcitation Voltage sweep
        for Vex_n=1:length(Vex_Array)
            CurrentVex=Vex_Array(Vex_n);
            LA1.sineAmp=CurrentVex;
            
            %comment this line out if you dont want auto gain/phase
            %LA1.auto_gain;%LA1.auto_phase;
            %LA2.auto_gain;%LA2.auto_phase;
            %pause(10);
            
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
                CurrentVsd=[LA1.X,LA1.Y];
                
                %Recond the time
                CurrentTime=clock;
                
                %add results into "data"
                data.time(CurrentMeasurementNumber)=round(etime(CurrentTime,StartTime)*100)/100;
                data.CryoT(CurrentMeasurementNumber)=CurrentTemp;
                data.Vg(CurrentMeasurementNumber)=CurrentVg;
                data.Vex(CurrentMeasurementNumber)=CurrentVex;
                data.VsdX(CurrentMeasurementNumber)=CurrentVsd(1);
                data.VsdY(CurrentMeasurementNumber)=CurrentVsd(2);
                
                %save results to file
                tmp=[CurrentTemp,CurrentVg,CurrentVex,CurrentVsd(1)...
                    ,CurrentVsd(2)];
                FilePtr = fopen(fullfile(start_dir, FileName), 'a');
                fprintf(FilePtr,'%s\t',datestr(CurrentTime,'HH:MM:SS'));
                fprintf(FilePtr,'%g\t%g\t%g\t%g\t%g\r\n',tmp);
                fclose(FilePtr);
                
                %increment the measurement number
                CurrentMeasurementNumber=CurrentMeasurementNumber+1;
            end
            
            %Record VNA
            [freq,S11]=VNA.getTrace();
            data.VNA.S11(CurrentParameterSet,:)=S11;
            
            %calculate averages and standard deviation for parameter set
            data.AveCryoT(CurrentParameterSet)=mean(data.CryoT(end-Nmeasurements+1:end));
            data.StdCryoT(CurrentParameterSet)=std(data.CryoT(end-Nmeasurements+1:end));
            data.AveVg(CurrentParameterSet)=mean(data.Vg(end-Nmeasurements+1:end));
            data.AveVex(CurrentParameterSet)=mean(data.Vex(end-Nmeasurements+1:end));
            data.AveVsdX(CurrentParameterSet)=mean(data.VsdX(end-Nmeasurements+1:end));
            data.StdVsdX(CurrentParameterSet)=std(data.VsdX(end-Nmeasurements+1:end));
            data.AveVsdY(CurrentParameterSet)=mean(data.VsdY(end-Nmeasurements+1:end));
            data.StdVsdY(CurrentParameterSet)=std(data.VsdY(end-Nmeasurements+1:end));
            CurrentParameterSet=CurrentParameterSet+1;
            
            %plot
            figure(91);
            scatter(data.AveVg(CurrentParameterSet-1),data.AveVsdX(CurrentParameterSet-1));
            if mod(CurrentParameterSet,20)==0
                figure(92);
                plot(data.VNA.freq,10*log10(abs(data.VNA.S11(CurrentParameterSet-1,:)).^2));
            end
        end
    end   
end

VG.ramp2V(EndingVg);
LA1.ramp2V(EndingVex);
%ramp temperature to "EndingTemperature"
%%%%%TC.range='MID'; TC.pGain=1; TC.iGain=10;
%%%%%TC.ramp2T(EndingTemperature,10); 
%%%%%TC.range='LOW'; TC.pGain=1; TC.iGain=1;

%clean things up
TC.disconnect();
VG.disconnect();
LA1.disconnect();
LA2.disconnect();
VNA.disconnect();
pause off;