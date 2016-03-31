%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using LakeShore Temperature Controller while taking VNA data
% in Oxford fridge at KimLab
% Created in Mar 2014 by Jesse Crossno and KC Fong and Evan Walsh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = VNA_R_T__Vg(Vg_list,VNA_Vg_list)

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
        plot(data.Vg,data.R,'b')
    end
    function plotVNA()
        figure(991); clf; xlabel('Frequency (MHz)');ylabel('S11^2'); hold all; grid on;
        len = length(data.VNA.traces(:,1,1));
        traces = length(data.VNA.traces(1,1,:));
        for trace_n=2:traces
            for i=1:len
                plot(data.VNA.traces(i,:,1)*1E-6,20*log10(abs(data.VNA.traces(i,:,trace_n))));
            end
        end
        legend()
    end
%measures the "fast" variables: Temp,Res, Field, and time
    function measure_fast_data(i,j)
        data.time(i,j) = etime(clock, StartTime);
        data.tempVapor(i,j) = TC.get_temperature('A');
        data.tempProbe(i,j) = TC.get_temperature('B');
        data.LA_X(i,j) = LA.X;
        data.LA_Y(i,j) = LA.Y;
        data.R(i,j) = data.LA_X(i,j)*Rex/Vex;
        data.Vg(i,j) = currentVg;
    end
%measures the "slow" variables only once per Vg_list
%copies fast variables for convenience
    function measure_slow_data()
        data.VNA.time(slow_n) = data.time(end);
        data.VNA.tempVapor(slow_n) = data.tempVapor(end);
        data.VNA.tempProbe(slow_n) = data.tempVapor(end);
        data.VNA.Vg(slow_n) = currentVg;
        data.VNA.R(slow_n) = data.R(end);
        VNA.output = 'on';VNA.reaverage();
        data.VNA.traces(slow_n,:,:) = VNA.getAllTraces();
        pause(VNAWaitTime);
        VNA.output = 'off';
        slow_n = slow_n+1;
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
LA = deviceDrivers.SRS830();
LA.connect('8')
%connect to YOKO gate supply
VG = deviceDrivers.YokoGS200();
VG.connect('17')


%saftey checks (more checks below)
assert(max(abs(Vg_list)) < 30,'Gate voltage set above 30 V');


%get experiment parameters from user
Rex = 1E7; % resistor in series with sample for resistance measurements
VNAWaitTime = 1;
Nmeasurements = input('How many measurements per parameter point? ');
VWaitTime1 = input('Enter initial Vg equilibration time: ');
VWaitTime2 = input('Enter Vg equilibration time for each step: ');
Vex = input('Enter source-drain excitation voltage: ');
MeasurementWaitTime = input('Enter time between lockin measurents: ');
assert(isnumeric(Nmeasurements)&&isnumeric(VWaitTime1)&&isnumeric(VWaitTime2)...
    &&isnumeric(Vex)&&isnumeric(MeasurementWaitTime)&&Nmeasurements >= 0 ...
    &&VWaitTime1 >= 0&&VWaitTime2 >= 0&&Vex >= 0&&MeasurementWaitTime >= 0 ...
    , 'Oops! please enter non-negative values only')
UniqueName = input('Enter uniquie file identifier: ','s');
aditional_info = input('Any additional info to include with file? ','s');

% Initialize data structure and filename
start_dir = 'C:\Crossno\data\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('VNA_R_T__Vg_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');

data = struct('time',[],'tempVapor',[],'tempProbe',[],'LA_X',[],'LA_Y',[], ...
    'R',[],'Vg',[],'LA',struct('Vex', Vex,'Rex',Rex,'timeConstant',LA.timeConstant()) ...
    ,'info',aditional_info);
data.VNA=struct('time',[],'tempVapor',[],'tempProbe',[],'traces',[],'R',[],'Vg',[]);


%never go longer than saveTime without saving
saveTime = 60; %in seconds
lastSave = clock;

%initialize equip
LA.sineAmp=Vex;
VNA.output = 'off';
pause(VNAWaitTime);

%initilze data counter
slow_n = 1;
pause on;
%main loop
for Vg_n=1:length(Vg_list)
    
    %set Vg
    currentVg = Vg_list(Vg_n);
    VG.ramp2V(currentVg);
    if Vg_n==1
        pause(VWaitTime1);
    else
        pause(VWaitTime2);
    end
    
    %take "fast" data
    for n=1:Nmeasurements
        measure_fast_data(Vg_n,n);
        pause(MeasurementWaitTime);
    end
    
    %take VNA data every in the current Vg is in VNA_Vg_list
    if any(currentVg==VNA_Vg_list)
        measure_slow_data();
    end
    
    %update plots
    plotTemperature();
    plotResistance();
    
    %save every "saveTime" seconds
    if etime(clock, lastSave) > saveTime
        saveData();
    end

    plotVNA();
    saveData()
    
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VG.ramp2V(0);
TC.disconnect();
VNA.disconnect();
LA.disconnect();
clear TC VNA LA MS
end