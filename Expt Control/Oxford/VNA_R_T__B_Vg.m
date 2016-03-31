%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect VNA, Resistance, and Temperature vs field and gate voltage
% Created in Mar 2016 by Jesse Crossno
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = VNA_R_T__B_Vg(B_list,Vg_list,VNA_B_list,VNA_Vg_list)
%%
%Internal convenience functions: plotting and data taking
    function plotVNA(i,j)
        figure(991); xlabel('Frequency (MHz)');ylabel('S11^2'); hold all; grid on;
        plot(data.VNA.freq*1E-6,squeeze(20*log10(abs(data.VNA.traces(i,j,:)))));
    end
    function plotLog()
        figure(992); clf; grid on; hold on; xlabel('time (s)');
        [ax,h1,h2] = plotyy(data.log.time,data.log.field,data.log.time,data.log.TProbe);
        ylabel(ax(1),'Field (Tesla)');
        ylabel(ax(2),'Temperature (K)');
        legend('Probe','Field');
    end
    function plotResistance()
        figure(993); clf; xlabel('Field (Tesla)');ylabel('Field (Tesla)');
        grid on; hold on;
        h=surf(data.Vg,data.field_set,data.R);view(2);
        set(h,'linestyle','none');colorbar;title('Resistance (\Omega)');
    end
    function plotResistanceLine()
        figure(994); clf; xlabel('Vg (volts)');ylabel('Resistance (\Omega)');
        grid on; hold on;
        for i=1:length(data.R(:,1))
            plot(data.Vg,data.R(i,:));
        end
    end
    
    %measures the "fast" variables: Temp, R, Field, and time
    function measure_data(i,j)
        for n=1:Nmeasurements
            pause(measurementWaitTime)
            data.raw.time(i,j,n) = etime(clock, StartTime);
            data.raw.TVapor(i,j,n) = TC.get_temperature('A');
            data.raw.TProbe(i,j,n) = TC.get_temperature('B');
            [data.raw.LA_X(i,j,n) data.raw.LA_Y(i,j,n)] = LA.snapXY();
            data.raw.R(i,j,n) = data.raw.LA_X(i,j,n)*LA_Rex/LA_Vex;
            data.raw.field(i,j,n) = MS.measuredField();
        end
        data.TVapor(i,j) = mean(data.raw.TVapor(i,j,:));
        data.TProbe(i,j) = mean(data.raw.TProbe(i,j,:));
        data.LA_X(i,j) = mean(data.raw.LA_X(i,j,:));
        data.LA_Y(i,j) = mean(data.raw.LA_Y(i,j,:));
        data.R(i,j) = mean(data.raw.R(i,j,:));
        data.field(i,j) = mean(data.raw.field(i,j,:));
    end
    %keep a running track of all parameters vs time
    function timeLog()
        data.log.time(TL_n) = etime(clock, StartTime);
        data.log.TVapor(TL_n) = TC.get_temperature('A');
        data.log.TProbe(TL_n) = TC.get_temperature('B');
        [data.log.LA_X(TL_n) data.log.LA_Y(TL_n)] = LA.snapXY();
        data.log.R(TL_n) = data.log.LA_X(TL_n)*LA_Rex/LA_Vex;
        data.log.field(TL_n) = MS.measuredField();
        data.log.Vg(TL_n) = currentVg;
        TL_n = TL_n+1;
    end
    %measures the all variables including VNA 
    function measure_VNA(i,j)
        data.VNA.time(i,j) = etime(clock, StartTime);
        data.VNA.TVapor(i,j) = TC.get_temperature('A');
        data.VNA.TProbe(i,j) = TC.get_temperature('B');
        data.VNA.LA_X(i,j) = LA.X();
        data.VNA.LA_Y(i,j) = LA.Y();
        data.VNA.R(i,j) = data.LA_X(i,j)*1E7;
        data.VNA.field(i,j) = MS.measuredField();
        VNA.output = 'on'; VNA.reaverage();
        data.VNA.traces(i,j,:) = VNA.getSingleTrace();
        VNA.output = 'off';
        pause(VNAwaitTime);
    end
    function saveData()
        save(fullfile(start_dir, FileName),'data');
        lastSave = clock;
    end
    function checkLockinSensitivity(lowerBound,upperBound)
        if ~exist('lowerBound','var')
            lowerBound = 0.10;
        end
        if ~exist('upperBound','var')
            upperBound = 0.75;
        end
        
        R = LA.R;
        while (R > LA_sens*upperBound) || R < LA_sens*lowerBound
            if R > LA_sens*upperBound
                LA.decreaseSens();
                LA_sens = LA.sens();
            elseif R < LA_sens*lowerBound
                LA.increaseSens()
                LA_sens = LA.sens();
            end
            pause(LA_sensWaitTime)
            R = LA.R;
        end
    end

%%
%%Connect to devices
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
%connect to YOKO gate supply
VG = deviceDrivers.YokoGS200();
VG.connect('17')

%% get/set experimental parameters including saftey checks
%saftey checks (more checks below)
assert(max(abs(B_list)) < MS.maxField,'Target field exceeds limit set by magnet supply');

%internal defaults
timeLogInterval = 2; %time between timeLog measurments
fieldRes = 0.001; %take data when measured field is within fieldRes of target field
LA_Rex = 1E7; %resistor in series with sample
LA_Vex = 1; %Voltage to use on LA sine output
LA_phase = 0; %Phase to use on LA sine output
LA_freq = 17.777;
LA_timeConstant = 0.3; %time constant to use on LA
LA_coupling = 'AC'; %only use DC when measureing below 160mHz
LA_sens = 0.005;
LA_bufferRate = 16; % measurement rate in Hz (not used here)
LA_sensWaitTime = LA_timeConstant*4;

Nmeasurements = input('How many measurements per parameter point [10]? ');
if isempty(Nmeasurements)
    Nmeasurements = 10;
end
sweepRate = input('Enter magnet sweep rate (Tesla/min) [0.45] = ');
if isempty(sweepRate)
    sweepRate = 0.45;
end
assert(isnumeric(sweepRate), 'Oops! need to set a sweep rate.');
assert(abs(sweepRate) < MS.maxSweepRate,'sweep rate set too high!');

VWaitTime1 = input('Enter initial Vg equilibration time [5]: ');
if isempty(VWaitTime1)
    VWaitTime1 = 5;
end
VWaitTime2 = input('Enter Vg equilibration time for each step [1]: ');
if isempty(VWaitTime2)
    VWaitTime2 = 1;
end
measurementWaitTime = input('Enter time between measurents [1.2]: ');
if isempty(measurementWaitTime)
    measurementWaitTime = 1.2;
end

VNAwaitTime=input('Enter VNA wait time [2]: ');
if isempty(VNAwaitTime)
    VNAwaitTime = 2;
end

UniqueName = input('Enter uniquie file identifier: ','s');
EmailJess = input('Send Jess an email when done? Y/N [N]: ', 's');
if isempty(EmailJess)
    EmailJess = 'N';
end
EmailKC = input('Send KC an email when done? Y/N [N]: ', 's');
if isempty(EmailKC)
    EmailKC = 'N';
end
AddInfo = input('Enter any additional info to include in file header: ','s');

start_dir = 'C:\Crossno\data\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('VNA_R_T__B_Vg', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');

%% Initialize file structure and equipment
pause on;

%initialize the gate
currentVg = Vg_list(1);
VG.ramp2V(currentVg);
        
%initialize magent
MS.remoteMode();
MS.sweepRate = sweepRate;
MS.switchHeater = 1;

%initialize Lockin
LA.sineAmp = LA_Vex;
LA.sinePhase = LA_phase;
LA.sineFreq = LA_freq;
LA.timeConstant = LA_timeConstant;
LA.inputCoupling = LA_coupling;
LA.sens = LA_sens;
LA.bufferRate = LA_bufferRate;

%initialize VNA
VNA.output = 'on';
VNA.reaverage();
freq = VNA.getX;
VNA.output='off';
pause(VNAwaitTime);

% Initialize data structure
blank = zeros(length(B_list),length(Vg_list));
VNA_blank = zeros(length(VNA_B_list),length(VNA_Vg_list));
trace_blank = zeros(length(VNA_B_list),length(VNA_Vg_list),length(freq));
data = struct('time',blank,'tempVapor',blank,'tempProbe',blank,'LA_X',blank ...
    ,'LA_Y',blank,'R',blank,'field',blank,'Vg',Vg_list,'field_set',B_list);
data.VNA=struct('time',VNA_blank,'tempVapor',VNA_blank,'tempProbe',VNA_blank ...
    ,'traces',trace_blank,'freq',freq ,'LA_X',VNA_blank,'LA_Y',VNA_blank,'R', ...
    VNA_blank,'field',VNA_blank,'Vg',VNA_Vg_list,'field_set',VNA_B_list);

%save every saveTime seconds
saveTime = 120;
lastSave = clock;

%% main loop
%keep a running log of all measureables vs time
TL_n = 1;
VNA_B_n = 1;
Vg_index = 1:length(Vg_list);
VNA_Vg_index = 1:length(VNA_Vg_list);
for B_n=1:length(B_list)
    
    %set target field
    targetField = B_list(B_n);
    MS.targetField = targetField;
    MS.goToTargetField();
    timeLog();
    plotLog();
    
    while data.log.field(end) < targetField - fieldRes || data.log.field(end) > targetField + fieldRes 
        pause(timeLogInterval);
        timeLog();
        plotLog();
    end
    
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
        measure_data(B_n,Vg_index(Vg_n));
        
        %update plots
        plotResistance();
        plotResistanceLine();
        
        if any(targetField==VNA_B_list) && any(currentVg==VNA_Vg_list)
            measure_VNA(VNA_B_n,VNA_Vg_index(VNA_Vg_n))
            plotVNA(VNA_B_n,VNA_Vg_index(VNA_Vg_n));
            VNA_Vg_n = VNA_Vg_n + 1;
        end
        
        %save every "saveTime" seconds
        if etime(clock, lastSave) > saveTime
            saveData();
        end
    end
    Vg_list = fliplr(Vg_list);
    Vg_index = fliplr(Vg_index);
    VNA_Vg_index = fliplr(VNA_Vg_index);
end
pause off;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     Ramp down and clear      %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
targetField = 0;
MS.targetField = targetField;
MS.goToTargetField();
timeLog();
while data.log.field(end) < targetField - fieldRes || data.log.field(end) > targetField + fieldRes
    pause(timeLogInterval);
    timeLog();
end
MS.switchHeater = 0;

VG.ramp2V(0);

TC.disconnect();
VNA.disconnect();
LA.disconnect();
MS.disconnect();
VG.disconnect();
clear TC VNA LA MS VG
%% Email data
if EmailJess || EmailKC == 'Y'
    setpref('Internet','E_mail','Sweet.Lady.Science@gmail.com');
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username','Sweet.Lady.Science@gmail.com');
    setpref('Internet','SMTP_Password','graphene');
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    if EmailJess && EmailKC == 'Y'
        sendmail({'JDCrossno@gmail.com','fongkc@gmail.com'},strcat('Your Science is done : ',UniqueName),strcat('File :', UniqueName,' taken on :',datestr(StartTime),' at BBN Technologies.   ',AddInfo, '    With Love, Sweet Lady Science'),{fullfile(start_dir, FileName),fullfile(start_dir, FileName2)});
    elseif EmailJess == 'Y'
        sendmail({'JDCrossno@gmail.com'},strcat('Your Science is done : ',UniqueName),strcat('File :', UniqueName,' taken on :',datestr(StartTime),' at BBN Technologies.   ',AddInfo, '    With Love, Sweet Lady Science'),{fullfile(start_dir, FileName),fullfile(start_dir, FileName2)});
    elseif EmailKC == 'Y'
        sendmail({'fongkc@gmail.com'},strcat('Your Science is done : ',UniqueName),strcat('File :', UniqueName,' taken on :',datestr(StartTime),' at BBN Technologies.   ',AddInfo, '    With Love, Sweet Lady Science'),{fullfile(start_dir, FileName),fullfile(start_dir, FileName2)});
    end
end
end