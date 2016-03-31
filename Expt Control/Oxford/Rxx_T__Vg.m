%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using LakeShore Temperature Controller while taking VNA data
% in Oxford fridge at KimLab
% Created in Mar 2014 by Jesse Crossno and KC Fong and Evan Walsh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = Rxx_T__Vg(Vg_list,VNA_Vg_list)

    if ~exist('Vg_list') && ~exist('VNA_Vg_list')
        Vgmin=0;
        Vgmax=2;
        Vgpts=20;
        VNApts=5;
        Vg_list=linspace(Vgmin,Vgmax,Vgpts);
        VNA_Vg_list=linspace(Vgmin,Vgmax,Vgpts/VNApts);
    end

%Internal convenience functions
    function plotTemperature()
        figure(992); clf; xlabel('Vg (Volts)');ylabel('Temperature (K)');
        grid on; hold on;
        plot(data.Vg,data.tempVapor,'r')
        plot(data.Vg,data.tempProbe,'b')
        legend('Vapor','Probe')
    end

    function plotResistance()
        figure(993); clf; xlabel('Vg (Volts)');ylabel('Resistance (\Omega)');
        grid on; hold on;
        plot(data.Vg,data.Rxx,'b')
    end

    function plotVNA(i)
        figure(991); xlabel('Frequency (MHz)');ylabel('S11^2'); hold all; grid on;
        plot(data.VNA.freq*1E-6,squeeze(20*log10(abs(data.VNA.traces(i,:)))));
    end

    function checkLockinSensitivity(lowerBound,upperBound)
        if ~exist('lowerBound','var')
            lowerBound = 0.10;
        end
        if ~exist('upperBound','var')
            upperBound = 0.75;
        end
        
        X5 = LA5.X;
        X6 = LA6.X;
        while (X5 > LA_sens*upperBound) || X5 < LA_sens*lowerBound
            if X5 > LA_sens*upperBound
                LA5.decreaseSens();
                LA_sens = LA5.sens();
            elseif X5 < LA_sens*lowerBound
                LA5.increaseSens()
                LA_sens = LA5.sens();
            end
            pause(LA_sensWaitTime)
            X5 = LA5.X;
        end
        while (X6 > LA_sens*upperBound) || X6 < LA_sens*lowerBound
            if X6 > LA_sens*upperBound
                LA6.decreaseSens();
                LA_sens = LA6.sens();
            elseif X6 < LA_sens*lowerBound
                LA6.increaseSens()
                LA_sens = LA6.sens();
            end
            pause(LA_sensWaitTime)
            X6 = LA6.X;
        end
    end

%measures the "fast" variables: Temp,Res, Field, and time
    function measure_fast_data(i)
        data.time(i) = etime(clock, StartTime);
        data.tempVapor(i) = TC.get_temperature('A');
        data.tempProbe(i) = TC.get_temperature('B');
        data.LA_ix_X(i) = LA5.X;
        data.LA_ix_Y(i) = LA5.Y;
        data.LA_vx_X(i) = LA6.X;
        data.LA_vx_Y(i) = LA6.Y;
        data.Rxx(i) =  data.LA_vx_X(i)/data.LA_ix_X(i);
        data.Vg(i) = currentVg;
    end

    function measure_VNA(i)
        data.VNA.time(i) = etime(clock, StartTime);
        data.VNA.TVapor(i) = TC.get_temperature('A');
        data.VNA.TProbe(i) = TC.get_temperature('B');
        data.VNA.LA_ix(i,j) = LA5.X();
        data.VNA.LA_vx(i,j) = LA6.Y();
        data.VNA.Rxx(i) = data.VNA.LA_vx(i)/data.VNA.LA_ix(i);
%         data.VNA.field(i,j) = MS.measuredField();
        VNA.output = 'on'; VNA.reaverage();
        data.VNA.traces(i,:) = VNA.getSingleTrace();
        VNA.output = 'off';
        pause(VNAwaitTime);
    end

    function saveData()
        save(fullfile(start_dir, FileName),'data');
        lastSave = clock;
    end

% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.Lakeshore335();
TC.connect('12');
% Connect to the VNA
VNA = deviceDrivers.AgilentE8363C();
VNA.connect('140.247.189.60')
%Connect lockin amplifier
LA5 = deviceDrivers.SRS830();
LA5.connect('5')
LA6 = deviceDrivers.SRS830();
LA6.connect('6')
%connect to YOKO gate supply
VG = deviceDrivers.YokoGS200();
VG.connect('17')


%saftey checks (more checks below)
assert(max(abs(Vg_list)) < 30,'Gate voltage set above 30 V');


%get experiment parameters from user
%Rex = 1E7; % resistor in series with sample for resistance measurements
VNAwaitTime = 1;
% Nmeasurements = input('How many measurements per parameter point? ');
VWaitTime1 = 10;%input('Enter initial Vg equilibration time: ');
VWaitTime2 = 1;%input('Enter Vg equilibration time for each step: ');
Vex = 0.1;%input('Enter source-drain excitation voltage: ');
MeasurementWaitTime = 1; %input('Enter time between lockin measurents: ');
% assert(isnumeric(Nmeasurements)&&isnumeric(VWaitTime1)&&isnumeric(VWaitTime2)...
%     &&isnumeric(Vex)&&isnumeric(MeasurementWaitTime)&&Nmeasurements >= 0 ...
%     &&VWaitTime1 >= 0&&VWaitTime2 >= 0&&Vex >= 0&&MeasurementWaitTime >= 0 ...
%     , 'Oops! please enter non-negative values only')
UniqueName = input('Enter unique file identifier: ','s');
% aditional_info = input('Any additional info to include with file? ','s');


% Initialize data structure and filename
start_dir = 'C:\JW\b7_devA_Ox\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('Rxx_T__Vg_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');




%never go longer than saveTime without saving
saveTime = 60; %in seconds
lastSave = clock;

%initialize the gate
currentVg = Vg_list(1);
VG.ramp2V(currentVg);
Vg.output=1;

%initialize equip
LA_sens=0.005;
LA_phase=0;
LA_freq=117.37;
LA5.sineAmp=Vex;
LA5.sens = LA_sens;
LA6.sens = LA_sens;
LA5.sinePhase = LA_phase;
LA5.sineFreq = LA_freq;
% LA6.sinePhase = LA_phase; %locked to 5
% LA6.sineFreq = LA_freq;
LA_timeConstant = 0.3;
LA_coupling = 'AC';
LA_sensWaitTime = LA_timeConstant*4;

%initialize VNA
VNA.output = 'on';
VNA.reaverage();
freq = VNA.getX;
VNA.output='off';
pause(VNAwaitTime);

VNA_blank = zeros(length(VNA_Vg_list));
trace_blank = zeros(length(VNA_Vg_list),length(freq));


data = struct('time',[],'tempVapor',[],'tempProbe',[],'LA5_X',[],'LA5_Y',[],'LA6_X',[],'LA6_Y',[], ...
    'Rxx',[],'Vg',[],'LA',struct('Vex', Vex,'timeConstant5',LA5.timeConstant(),'timeConstant6',LA6.timeConstant()) ...
    );
% data.VNA=struct('time',[],'tempVapor',[],'tempProbe',[],'traces',[],'R',[],'Vg',[]);
data.VNA=struct('time',VNA_blank,'tempVapor',VNA_blank,'tempProbe',VNA_blank ...
    ,'traces',trace_blank,'freq',freq ,'LA5_X',VNA_blank,'LA5_Y',VNA_blank ...
    ,'LA6_X',VNA_blank,'LA6_Y',VNA_blank,'Rxx', ...
    VNA_blank,'Vg',VNA_Vg_list);

%initilze data counter
% slow_n = 1;
pause on;
%main loop


Vg_index = 1:length(Vg_list);
VNA_Vg_index = 1:length(VNA_Vg_list);

VNA_Vg_n=1;

for Vg_n=1:length(Vg_list)
    
    %set Vg
    currentVg = Vg_list(Vg_n);
    VG.ramp2V(currentVg);
    if Vg_n==1
        pause(VWaitTime1);
    else
        pause(VWaitTime2);
    end
    
    checkLockinSensitivity();
    
    %take "fast" data
%     for n=1:Nmeasurements
        pause(MeasurementWaitTime);
        measure_fast_data(Vg_n);
%     end
     
    %update plots
    plotTemperature();
    plotResistance();
    
    if  any(currentVg==VNA_Vg_list)
            measure_VNA(VNA_Vg_index(VNA_Vg_n))
            plotVNA(VNA_Vg_index(VNA_Vg_n));
            VNA_Vg_n = VNA_Vg_n + 1;
        end
    
    %save every "saveTime" seconds
    if etime(clock, lastSave) > saveTime
        saveData();
    end

    saveData()
    
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VG.ramp2V(0);
TC.disconnect();
VNA.disconnect();
LA5.disconnect();
LA6.disconnect();
clear TC VNA LA5 LA6 MS
end