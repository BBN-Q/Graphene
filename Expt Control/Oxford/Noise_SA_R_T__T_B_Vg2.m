%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect VNA, Resistance, and Temperature vs field and gate voltage
% Created in Mar 2016 by Jesse Crossno
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = Noise_SA_R_T__T_B_Vg(T_list,B_list,Vg_list)
%%
%Internal convenience functions: plotting and data taking
    function plotSA(i,j,k)
        figure(991); xlabel('Frequency (MHz)');ylabel('dBm'); hold all; grid on;
        plot(data.freq*1E-6,squeeze(data.traces(i,j,k,:)));
    end
    function plotLog()
        figure(992); clf; grid on; hold on; xlabel('time (s)');
        [ax,h1,h2] = plotyy(data.log.time,data.log.field,data.log.time,data.log.TProbe);
        ylabel(ax(1),'Field (Tesla)');
        ylabel(ax(2),'Temperature (K)');
        legend('Field','Probe');
    end
    function plotResistance(i)
        figure(993); clf; xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        h=surf(data.Vg,data.field_set,squeeze(data.R(i,:,:)));view(2);
        set(h,'linestyle','none');colorbar;title('Resistance (\Omega)');
    end
    function plotResistanceLine(i,j)
        figure(994); xlabel('Vg (volts)');ylabel('Resistance (\Omega)');
        grid on; hold on;
        plot(data.Vg,squeeze(data.R(i,j,:)));
    end

%measures the "fast" variables: Temp, R, Field, and time
    function measure_data(i,j,k)
        for n=1:Nmeasurements
            data.raw.time(i,j,k,n) = etime(clock, StartTime);
            data.raw.TVapor(i,j,k,n) = TC.temperatureA;
            data.raw.TProbe(i,j,k,n) = TC.temperatureB;
            data.raw.field(i,j,k,n) = MS.measuredField();
            pause(measurementWaitTime)
            [data.raw.LA_X(i,j,k,n) data.raw.LA_Y(i,j,k,n)] = LA.snapXY();
            data.raw.noise(i,j,k,n) = MM.value();
            data.raw.R(i,j,k,n) = ...
                sqrt(data.raw.LA_X(i,j,k,n)^2+data.raw.LA_Y(i,j,k,n)^2)*LA_Rex/LA_Vex;
        end
        data.time(i,j,k) = mean(data.raw.time(i,j,k,:));
        data.TVapor(i,j,k) = mean(data.raw.TVapor(i,j,k,:));
        data.TProbe(i,j,k) = mean(data.raw.TProbe(i,j,k,:));
        data.LA_X(i,j,k) = mean(data.raw.LA_X(i,j,k,:));
        data.LA_Y(i,j,k) = mean(data.raw.LA_Y(i,j,k,:));
        data.R(i,j,k) = mean(data.raw.R(i,j,k,:));
        data.field(i,j,k) = mean(data.raw.field(i,j,k,:));
        data.noise(i,j,k) = mean(data.raw.noise(i,j,k,:));
        data.std.TVapor(i,j,k) = std(data.raw.TVapor(i,j,k,:));
        data.std.TProbe(i,j,k) = std(data.raw.TProbe(i,j,k,:));
        data.std.LA_X(i,j,k) = std(data.raw.LA_X(i,j,k,:));
        data.std.LA_Y(i,j,k) = std(data.raw.LA_Y(i,j,k,:));
        data.std.R(i,j,k) = std(data.raw.R(i,j,k,:));
        data.std.field(i,j,k) = std(data.raw.field(i,j,k,:));
        [tmp,data.traces(i,j,k,:)]= SA.SAGetTrace();
    end
%keep a running track of all parameters vs time
    function timeLog()
        data.log.time = [data.log.time etime(clock, StartTime)];
        data.log.TVapor = [data.log.TVapor TC.temperatureA];
        data.log.TProbe = [data.log.TProbe TC.temperatureB];
        [X Y] = LA.snapXY();
        data.log.LA_X = [data.log.LA_X X];
        data.log.LA_Y = [data.log.LA_Y Y];
        data.log.R = [data.log.R sqrt(X^2+Y^2)*LA_Rex/LA_Vex];
        data.log.field = [data.log.field MS.measuredField()];
    end

%run until temperature is stable around setpoint
    function stabilizeTemperature(setPoint,time,tolerance)
        %temperature should be with +- tolerance in K for time seconds
        %Tmonitor = 999*ones(2,time*10);
        Tmonitor = 999*ones(1,time*10);
        n_mon = 0;
        %while max(max(Tmonitor))>tolerance
        while max(Tmonitor)>tolerance
            %Tmonitor(1,mod(n_mon,time*10)+1)=abs(TC.temperatureA()-setPoint+1);
            Tmonitor(1,mod(n_mon,time*10)+1)=abs(TC.temperatureB()-setPoint);
            n_mon=n_mon+1;
            pause(0.095);
        end
    end

%measures the all variables including VNA
    function saveData(i,j,k)
        save(fullfile(start_dir, FileName2),'data');
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
        tmp = [data.TProbe(i,j,k) data.TVapor(i,j,k) Vg_list(Vg_n)...
            data.field(i,j,k) data.LA_X(i,j,k) data.LA_Y(i,j,k) data.R(i,j,k)];
        fprintf(FilePtr,'%s\t',datestr(clock,'YYYY_mm_DD HH:MM:SS'));
        fprintf(FilePtr,'%g\t%g\t%g\t%g\t%g\t%g\t%g',tmp);
        for d=data.traces(i,j,k,:)
            fprintf(FilePtr,'\t%s',num2str(d));
        end
        fprintf(FilePtr,'\r\n');
        fclose(FilePtr);
        
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
% Connect to the SA
VNA = deviceDrivers.AgilentN9020A;
VNA.connect('140.247.189.131')
% Connect to the multimeter
MM = deviceDrivers.Keysight34401A();
MM.connect('5');
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
LA_Rex = 9.79E6; %resistor in series with sample
LA_Vex = 1; %Voltage to use on LA sine output
LA_phase = 0; %Phase to use on LA sine output
LA_freq = 17.777;
LA_timeConstant = 0.3; %time constant to use on LA
LA_coupling = 'AC'; %only use DC when measureing below 160mHz
LA_sens = 0.005;
LA_bufferRate = 16; % measurement rate in Hz (not used here)
LA_sensWaitTime = LA_timeConstant*4;
TvaporRampRate = 20;
TprobeRampRate = 20;
PID = [500,200,100];

Nmeasurements = input('How many measurements per parameter point [20]? ');
if isempty(Nmeasurements)
    Nmeasurements = 20;
end
sweepRate = input('Enter magnet sweep rate (Tesla/min) [0.45] = ');
if isempty(sweepRate)
    sweepRate = 0.45;
end
assert(isnumeric(sweepRate), 'Oops! need to set a sweep rate.');
assert(abs(sweepRate) < MS.maxSweepRate,'sweep rate set too high!');

VWaitTime1 = input('Enter initial Vg equilibration time [1]: ');
if isempty(VWaitTime1)
    VWaitTime1 = 1;
end
VWaitTime2 = input('Enter Vg equilibration time for each step [1]: ');
if isempty(VWaitTime2)
    VWaitTime2 = 1;
end
measurementWaitTime = input('Enter time between measurents [0]: ');
if isempty(measurementWaitTime)
    measurementWaitTime = 0;
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
FileName = strcat('VNA_R_T__B_Vg', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.dat');
FileName2 = strcat('VNA_R_T__B_Vg', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
%create header string
HeaderStr=strcat('Time\tTProbe(K)\tTVapor\tVg\tfield\tX\tY\tR');
fprintf(FilePtr, HeaderStr);
fclose(FilePtr);

%% Initialize file structure and equipment
pause on;

%initialize the gate
currentVg = Vg_list(1);
VG.ramp2V(currentVg);

%initialize temperature controller
TC.rampRate1 = TvaporRampRate;
TC.rampRate2 = TprobeRampRate;
TC.PID1 = PID;
TC.PID2 = PID;

%initialize magent
MS.remoteMode();
MS.sweepRate = sweepRate;

%initialize Lockin
LA.sineAmp = LA_Vex;
LA.sinePhase = LA_phase;
LA.sineFreq = LA_freq;
LA.timeConstant = LA_timeConstant;
LA.inputCoupling = LA_coupling;
LA.sens = LA_sens;
LA.bufferRate = LA_bufferRate;

%initialize VNA
VNA.trigger_source = 'manual';
freq = VNA.getX;

%add freq to dat file as col names
FilePtr = fopen(fullfile(start_dir, FileName), 'a');
for f=freq
    fprintf(FilePtr,'\t%e',f);
end
    fprintf(FilePtr,'\r\n');
fclose(FilePtr);

% Initialize data structure
blank = zeros(length(T_list),length(B_list),length(Vg_list));
trace_blank = zeros(length(T_list),length(B_list),length(Vg_list),length(freq));
data = struct('time',blank,'TVapor',blank,'TProbe',blank,'LA_X',blank ...
    ,'LA_Y',blank,'R',blank,'field',blank,'Vg',Vg_list,'field_set',B_list...
    ,'traces',trace_blank,'freq',freq,'T_set',T_list);
data.log = struct('time',[],'TVapor',[],'TProbe',[],'LA_X',[],'LA_Y',[],'R',[],'field',[]);

%record all the unsed settings
data.settings.TC.rampRate1 = TvaporRampRate;
data.settings.TC.rampRate2 = TprobeRampRate;
data.settings.TC.PID1 = PID;
data.settings.TC.PID2 = PID;
data.settings.LA.sineAmp = LA_Vex;
data.settings.LA.sinePhase = LA_phase;
data.settings.LA.sineFreq = LA_freq;
data.settings.LA.timeConstant = LA_timeConstant;
data.settings.LA.inputCoupling = LA_coupling;
data.settings.LA.sens = LA_sens;
data.settings.LA.Rex = LA_Rex;
data.settings.LA.bufferRate = LA_bufferRate;
data.settings.MS.sweepRate = sweepRate;

%% main loop
%keep a running log of all measureables vs time
T_ns = 1:length(T_list);
B_ns = 1:length(B_list);
Vg_ns = 1:length(Vg_list);
for T_n=T_ns
    T_set = T_list(T_n);
    if T_set <= 5.5        
        TC.range1 = 1;
        TC.range2 = 1;
    elseif T_set <= 70        
        TC.range1 = 2; 
        TC.range2 = 2;  
    else
        TC.range1 = 3;
        TC.range2 = 3;
    end
    TC.setPoint1 = T_set-1;
    TC.setPoint2 = T_set;
    
    stabilizeTemperature(T_set,5,0.3)
    
    
    for B_n=B_ns
        
        %set target field
        field_set = B_list(B_n);
        MS.switchHeater = 1;
        MS.targetField = field_set;
        MS.goToTargetField();
        pause(timeLogInterval);
        timeLog();
        plotLog();
        
        while abs(data.log.field(end) - field_set) > fieldRes
            pause(timeLogInterval);
            timeLog();
            plotLog();
        end
        MS.switchHeater = 0;
        
        for Vg_n=Vg_ns
            %set Vg
            Vg_set = Vg_list(Vg_n);
            VG.ramp2V(Vg_set);
            
            if Vg_n==1
                pause(VWaitTime1);
            else
                pause(VWaitTime2);
            end
            checkLockinSensitivity();
            
            %take "fast" data
            measure_data(T_n,B_n,Vg_n);
            
            %update plots
            plotResistance(T_n);
            plotVNA(T_n,B_n,Vg_n);
            %save
            saveData(T_n,B_n,Vg_n);
        end
        plotResistanceLine(T_n,B_n);
        Vg_ns = fliplr(Vg_ns);
        B_ns = fliplr(B_ns);
        figure(991);clf;
    end
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
TC.range1 = 0;
TC.range2 = 0;
TC.setPoint1 = 0;
TC.setPoint2 = 0;
VG.ramp2V(0);
while abs(data.log.field(end) - field_set) > fieldRes
    pause(timeLogInterval);
    timeLog();
end
MS.switchHeater = 0;


TC.disconnect();
VNA.disconnect();
LA.disconnect();
MS.disconnect();
VG.disconnect();
clear TC SA LA MS VG MM
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