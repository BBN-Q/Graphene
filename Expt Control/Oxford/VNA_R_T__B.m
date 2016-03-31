%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using LakeShore Temperature Controller while taking VNA data
% in Oxford fridge at KimLab
% Created in Mar 2014 by Jesse Crossno and KC Fong and Evan Walsh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = VNA_R_T__B(B_list)

    %Internal convenience functions
    function plotTemperature()
        figure(992); clf; xlabel('Field (Tesla)');ylabel('Temperature (K)');
        grid on; hold on;
        plot(data.field,data.tempVapor,'r')
        plot(data.field,data.tempProbe,'b')
        legend('Vapor','Probe')
    end
    function plotResistance()
        figure(993); clf; xlabel('Field (Tesla)');ylabel('Resistance (\Omega)');
        grid on; hold on;
        plot(data.field,data.R,'b')
    end
    function plotVNA()
        figure(991); clf; xlabel('Frequency (MHz)');ylabel('S11^2'); hold all; grid on;
        len = length(data.VNA.traces(:,1,1));
        for i=1:len
            plot(data.VNA.traces(i,:,1)*1E-6,20*log10(abs(data.VNA.traces(i,:,2))));
            %plot(data.VNA.traces(i,:,1)*1E-6,20*log10(abs(data.VNA.traces(i,:,3))));
            
        end
        legend()
    end
    %measures the "fast" variables: Temp,Res, Field, and time
    function measure_fast_data()
        data.time(fast_n) = etime(clock, StartTime);
        data.tempVapor(fast_n) = TC.get_temperature('A');
        data.tempProbe(fast_n) = TC.get_temperature('B');
        data.LA_X(fast_n) = LA.X();
        data.LA_Y(fast_n) = LA.Y();
        data.R(fast_n) = data.LA_X(fast_n)*1E7;
        data.field(fast_n) = MS.measuredField();
        fast_n = fast_n+1;
    end
    %measures the "slow" variables only once per B_list
    %copies fast variables for convenience 
    function measure_slow_data()
        data.VNA.time(B_n) = data.time(end);
        data.VNA.tempVapor(B_n) = data.tempVapor(end);
        data.VNA.tempProbe(B_n) = data.tempVapor(end);
        data.VNA.field(B_n) = data.field(end);
        data.VNA.LA_X(B_n) = data.LA_X(end);
        data.VNA.LA_Y(B_n) = data.LA_X(end);
        data.VNA.R(B_n) = data.R(end);
        data.VNA.traces(B_n,:,:) = VNA.getAllTraces();
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

%Connect to the Oxford magnet supply
MS = deviceDrivers.Oxford_IPS_120_10();
MS.connect('25');

%saftey checks (more checks below)
assert(max(abs(B_list)) < MS.maxField,'Target field exceeds limit set by magnet supply');

%collect needed variables from the user
fieldRes = 0.001; %take data when measured field is within fieldRes of target field

sweepRate = input('Enter magnet sweep rate (Tesla/min) [0.3] = ');
if isempty(sweepRate)
    sweepRate = 0.3;
end
assert(isnumeric(sweepRate), 'Oops! need to set a sweep rate.');
assert(abs(sweepRate) < MS.maxSweepRate,'sweep rate set too high!');

dataInterval = input('Time interval between T/R measurements (in second) = ');
assert(isnumeric(dataInterval), 'Oops! interval time must be a number')
assert(dataInterval >= 0, 'Oops! interval time must be non-negative')

UniqueName = input('Enter uniquie file identifier: ','s');

start_dir = 'C:\Crossno\data\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('VNA_R_T__B_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');


% Initialize data structure
data = struct('time',[],'tempVapor',[],'tempProbe',[],'LA_X',[],'LA_Y',[],'R',[],'field',[]);
data.VNA=struct('time',[],'tempVapor',[],'tempProbe',[],'traces',[],'LA_X',[],'LA_Y',[],'R',[],'field',[]);


%initialize magent
MS.remoteMode();
MS.sweepRate = sweepRate;
MS.switchHeater = 1;
targetField = B_list(1);
MS.targetField = targetField;
MS.goToTargetField();

%never go longer than saveTime without saving
saveTime = 60; %in seconds
lastSave = clock;

%initilze data counter
fast_n = 1;
pause on;
%main loop
for B_n=1:length(B_list)
    
    %set target field
    targetField = B_list(B_n);
    MS.targetField = targetField;
    MS.goToTargetField();
    
    %take "fast" data
    measure_fast_data();
    
    %take "fast" data every "dataInterval" until target field is reached
    while data.field(end) < targetField - fieldRes || data.field(end) > targetField + fieldRes 
        pause(dataInterval);
        measure_fast_data();
        
        %update plots
        plotTemperature();
        plotResistance();
        
        %save every "saveTime" seconds
        if etime(clock, lastSave) > saveTime
            saveData();
        end
    end
    
    %once field is reached, take "slow" data (VNA)
    %save a copy of previously taken "fast" data for convenience
    measure_slow_data();
    
    plotVNA();
    saveData();
    
end
pause off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MS.targetField = 0;
TC.disconnect();
VNA.disconnect();
LA.disconnect();
MS.disconnect();
clear TC VNA LA MS
end