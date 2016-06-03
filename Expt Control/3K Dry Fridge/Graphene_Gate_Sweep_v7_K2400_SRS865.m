%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Noise Measurment Sweeping Software
% version 1.0
% Edited in July 2015 by Evan Walsh
% Version 1.0 Created in August 2014 by Jess Crossno
% Using:
%   K2400 as Gate Voltage Source (VG)
%   SRS865 #1 as excitation current and resistance monitor (LA1)
%
%function takes in a temperature array (K), gate voltage array (V), and excitation
%voltage array (V) then sweeps them. Basic structure is:
%
% Sweep VG. For each VG, sweep Vex
%
%Vsd is the volatage drop measured across the graphene
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = Graphene_Gate_Sweep_v7_K2400_SRS865(Vg_Array)

% Initialize the path and create the data file with header
Nmeasurements = input('How many measurements per parameter point? ');
VWaitTime1 = input('Enter initial Vg equilibration time: ');
VWaitTime2 = input('Enter Vg equilibration time for each step: ');
Vex = input('Enter source-drain excitation voltage: ');
Resistor = input('Enter load resistance: ');
MeasurementWaitTime = input('Enter time between lockin measurents: ');
dev_w = input('Enter device width (m): ');
dev_l = input('Enter device length (m): ');
UniqueName = input('Enter uniquie file identifier: ','s');
AddInfo = input('Enter any additional info to include in file header: ','s');
start_dir = 'C:\Users\qlab\Documents\data\Graphene Data';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('GrapheneGateSweep_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName, '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
%create header string
HeaderStr=strcat(datestr(StartTime), ' Gate sweep using Graphene_Gate_swep_v1 Vex=',num2str(Vex),...
    's\tFile number:',UniqueName,'\r\n',AddInfo,...
    '\r\nTime\tVg_(V)\tVsdX_(V)\tVsdY_(V)\tVsdR_(V)\tVsdTH_(deg)\r\n');
fprintf(FilePtr, HeaderStr);
fclose(FilePtr);


% Ending values
EndingVg = 0;

% Connect to the all the various devices
VG = deviceDrivers.Keithley2400();
VG.connect('24')
LA1 = deviceDrivers.SRS865();
LA1.connect('9');

%saftey checks
Vg_max = 30; %max absolute gate voltage

if max(abs(Vg_Array))>Vg_max
    error('Gate voltage is set above Vg_max')
end

CurrentMeasurementNumber=1; %keeps track of which measurment you are on
CurrentParameterSet=1; %keeps track of the unique parameter configs
pause on;

LA1.sineAmp=Vex;
data.Vex=Vex;
data.Resistor=Resistor;

eps0=8.85e-12;
epsSiO2=3.9*eps0;
qelectron=1.6e-19;
tSiO2=285e-9;

n_coeff=epsSiO2*1e-4/(qelectron*tSiO2);
rho_coeff=dev_w/dev_l;
mob_coeff=1/(n_coeff*rho_coeff*qelectron);

tic;
%enter Gate Voltage Sweep
for Vg_n = 1:length(Vg_Array)
    CurrentVg=Vg_Array(Vg_n);
    VG.value=CurrentVg;
    
    %if first Vg, pause some time
    if Vg_n==1
        pause(VWaitTime1);
    else
        pause(VWaitTime2);
    end
    
    
    for n=1:Nmeasurements
        
        %wait MeasurmentWaitTime and find average Temperature
        %if Measurment Wait Time < 100ms, record average T Cryostat
%         CurrentTemp=0;
        
%         for j=1:max(floor(MeasurementWaitTime*10),1)
%             CurrentTemp=CurrentTemp+TC.temperatureA();
%             pause(0.1);
%         end
%         
%         CurrentTemp=CurrentTemp/max(floor(MeasurementWaitTime*10),1);
        
        %Record current Source-Drain Voltage across graphene
        flag=1;
        while flag==1
            try
                [X,Y]=LA1.get_XY();
                [R,TH]=LA1.get_Rtheta();
                flag=0;
            catch
                flag=1;
            end
        end
        
        %Record the time
        CurrentTime=clock;
        
        %add results into "data"
        data.raw.time(CurrentMeasurementNumber)=round(etime(CurrentTime,StartTime)*100)/100;
%         data.raw.CryoT(CurrentMeasurementNumber)=CurrentTemp;
        data.raw.Vg(CurrentMeasurementNumber)=CurrentVg;
        data.raw.VsdX(CurrentMeasurementNumber)=X;
        data.raw.VsdY(CurrentMeasurementNumber)=Y;
        data.raw.VsdR(CurrentMeasurementNumber)=R;
        data.raw.VsdTH(CurrentMeasurementNumber)=TH;
        data.raw.mobility_cm2Vs(CurrentMeasurementNumber)=(mob_coeff./(R*CurrentVg/(data.Vex/data.Resistor)));
        
        %save results to file
%         tmp=[CurrentTemp,CurrentVg,X,Y,R,TH];
        tmp=[CurrentVg,X,Y,R,TH];
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
        fprintf(FilePtr,'%s\t',datestr(CurrentTime,'HH:MM:SS'));
%         fprintf(FilePtr,'%g\t%g\t%g\t%g\t%g\t%g\r\n',tmp);
        fprintf(FilePtr,'%g\t%g\t%g\t%g\t%g\r\n',tmp);
        fclose(FilePtr);
        
        %increment the measurement number
        CurrentMeasurementNumber=CurrentMeasurementNumber+1;
    end
    
    
    %calculate averages and standard deviation for parameter set
    %time col 1 is start time, col 2 is end time
    data.time(CurrentParameterSet,:)=[data.raw.time(end-Nmeasurements+1),data.raw.time(end)];
%     data.CryoT(CurrentParameterSet)=mean(data.raw.CryoT(end-Nmeasurements+1:end));
%     data.std.CryoT(CurrentParameterSet)=std(data.raw.CryoT(end-Nmeasurements+1:end));
    data.Vg(CurrentParameterSet)=mean(data.raw.Vg(end-Nmeasurements+1:end));
    data.VsdX(CurrentParameterSet)=mean(data.raw.VsdX(end-Nmeasurements+1:end));
    data.std.VsdX(CurrentParameterSet)=std(data.raw.VsdX(end-Nmeasurements+1:end));
    data.VsdY(CurrentParameterSet)=mean(data.raw.VsdY(end-Nmeasurements+1:end));
    data.std.VsdY(CurrentParameterSet)=std(data.raw.VsdY(end-Nmeasurements+1:end));
    data.VsdR(CurrentParameterSet)=mean(data.raw.VsdR(end-Nmeasurements+1:end));
    data.std.VsdR(CurrentParameterSet)=std(data.raw.VsdR(end-Nmeasurements+1:end));
    data.VsdTH(CurrentParameterSet)=mean(data.raw.VsdTH(end-Nmeasurements+1:end));
    data.std.VsdTH(CurrentParameterSet)=std(data.raw.VsdTH(end-Nmeasurements+1:end));
    CurrentParameterSet=CurrentParameterSet+1;
    
    
    
    
    
    
    
    %plot
    figure(991);
    subplot(2,1,1)
    plot(data.raw.Vg,data.raw.VsdR*1E6);
    xlabel('Gate Voltage (V)');ylabel('Source-Drain Voltage (uV)');
    subplot(2,1,2)
    plot(data.raw.Vg,data.raw.mobility_cm2Vs);
    xlabel('Gate Voltage (V)');ylabel('Mobility (cm^2/Vs)');
   
end
toc;
% Vg_n=0;
% while CurrentVg ~= EndingVg
%     Vg_n=Vg_n+1;
%     CurrentVg=Vg_Array(length(Vg_Array)+1-Vg_n);
%     VG.value=CurrentVg;
%     pause(.5);
% end

%clean things up

VG.disconnect();
LA1.disconnect();

pause off;