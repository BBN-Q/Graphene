%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect Noise, Resistance, vs Temperature, field and gate voltage
% Created in April 2016 by Jesse Crossno
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = Noise_R_G__T_B_Vg_VexArray(T_list,B_list,Vg_list,gain_array,Vex_array)
s = size(gain_array);
assert(length(s)==3,'gain array should be 3 dimensional');
assert(s(1)==length(T_list)&&s(2)==length(B_list)&&s(3)==length(Vg_list),'gain array dimensions do not allign with parameter list dimensions');
s = size(Vex_array);
assert(length(s)==3,'Vex array should be 3 dimensional');
assert(s(1)==length(T_list)&&s(2)==length(B_list)&&s(3)==length(Vg_list),'Vex array dimensions do not allign with parameter list dimensions');
clear s;
%%
%Internal convenience functions: plotting and data taking
    function plotLog()
        figure(991); clf; grid on; hold on; xlabel('time (s)');
        [ax,~,~] = plotyy(data.log.time,data.log.B,data.log.time,data.log.TProbe);
        ylabel(ax(1),'Field (Tesla)');
        ylabel(ax(2),'Temperature (K)');
        legend('Field','Probe');
    end
    function plotResistance(i)
        figure(992); clf; xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        plt=surf(data.Vg,data.B_set,squeeze(data.R_mean(i,:,:)));view(2);
        set(plt,'linestyle','none');
        c = colorbar;ylabel(c,'Resistance (\Omega)');
    end
    function plotNoise(i)
        figure(993); clf; xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        plt=surf(data.Vg,data.B_set,squeeze(data.Vn_mean(i,:,:)*1E6));view(2);
        set(plt,'linestyle','none');
        c = colorbar;ylabel(c,'Noise (\muV)');
    end
    function plotNoiseDC(i)
        figure(993); clf; xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        plt=surf(data.Vg,data.B_set,squeeze(data.VnDC_mean(i,:,:)*1E3));view(2);
        set(plt,'linestyle','none');
        c = colorbar;ylabel(c,'Noise (mV)');
    end
    function plotG(i)
        figure(994); clf; xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        plt=surf(data.Vg,data.B_set,squeeze(data.G_mean(i,:,:)));view(2);
        set(plt,'linestyle','none');
        c = colorbar;ylabel(c,'Thermal Conductance (W/K)');
    end
    function plotT_p2p()
        figure(995);clf;hold all;xlabel('time');ylabel('\DeltaT_{p2p}');
        s = size(data.time);
        len = s(1)*s(2)*s(3)*s(4);
        plot(reshape(data.time,[1,len]),reshape(data.T_p2p,[1,len]),'r.');
        plot(reshape(data.time,[1,len]),ones(1,len)*DeltaTset,'b--');
    end
%measures the data
    function measure_data(i,j,k,m)
        t1=clock;
        for n=1:Nmeasurements
            while etime(clock,t1)<measurementWaitTime;
            end
            t1=clock;
            data.raw.time(i,j,k,m,n) = etime(clock, StartTime);
            [data.raw.Vsd_X(i,j,k,m,n) data.raw.Vsd_Y(i,j,k,m,n)] = LA1.snapXY;
            [data.raw.Vn_X(i,j,k,m,n) data.raw.Vn_Y(i,j,k,m,n)] = LA2.snapXY;
            data.raw.VnDC(i,j,k,m,n) = MM.value;
            data.raw.Vsd(i,j,k,m,n) = sqrt(data.raw.Vsd_X(i,j,k,m,n)^2+data.raw.Vsd_Y(i,j,k,m,n)^2);
            data.raw.R(i,j,k,m,n) = data.raw.Vsd(i,j,k,m,n)*LA1_Rex/(LA1_Vex-data.raw.Vsd(i,j,k,m,n));
            data.raw.Vn(i,j,k,m,n)=sqrt(data.raw.Vn_X(i,j,k,m,n)^2+data.raw.Vn_Y(i,j,k,m,n)^2);
        end
        data.TVapor(i,j,k,m) = TC.temperatureA;
        data.TProbe(i,j,k,m) = TC.temperatureB;
        
        data.time(i,j,k,m) = mean(data.raw.time(i,j,k,m,:));
        data.Vsd_X(i,j,k,m) = mean(data.raw.Vsd_X(i,j,k,m,:));
        data.Vsd_Y(i,j,k,m) = mean(data.raw.Vsd_Y(i,j,k,m,:));
        data.Vsd(i,j,k,m) = mean(data.raw.Vsd(i,j,k,m,:));
        data.Vex(i,j,k,m) = LA1_Vex;
        data.Vn_X(i,j,k,m) = mean(data.raw.Vn_X(i,j,k,m,:));
        data.Vn_Y(i,j,k,m) = mean(data.raw.Vn_Y(i,j,k,m,:));
        data.Vn(i,j,k,m) = mean(data.raw.Vn(i,j,k,m,:));
        data.R(i,j,k,m) = mean(data.raw.R(i,j,k,m,:));
        data.VnDC(i,j,k,m) = mean(data.raw.VnDC(i,j,k,m,:));
        
        data.T_p2p(i,j,k,m)=2*sqrt(2)*data.Vn(i,j,k,m)/gain_array(i,j,k);
        data.P_p2p(i,j,k,m)=2*(data.Vsd(i,j,k,m)*data.Vsd(i,j,k,m))/data.R(i,j,k,m);
        data.G(i,j,k,m)=data.P_p2p(i,j,k,m)/data.T_p2p(i,j,k,m);
        
        data.std.Vsd_X(i,j,k,m) = std(data.raw.Vsd_X(i,j,k,m,:));
        data.std.Vsd_Y(i,j,k,m) = std(data.raw.Vsd_Y(i,j,k,m,:));
        data.std.Vn_X(i,j,k,m) = std(data.raw.Vn_X(i,j,k,m,:));
        data.std.Vn_Y(i,j,k,m) = std(data.raw.Vn_Y(i,j,k,m,:));
        data.std.Vn(i,j,k,m) = std(data.raw.Vn(i,j,k,m,:));
        data.std.R(i,j,k,m) = std(data.raw.R(i,j,k,m,:));
        data.std.VnDC(i,j,k,m) = std(data.raw.VnDC(i,j,k,m,:));
    end
%keep a running track of all parameters vs time
    function timeLog()
        data.log.time = [data.log.time etime(clock, StartTime)];
        data.log.TVapor = [data.log.TVapor TC.temperatureA];
        data.log.TProbe = [data.log.TProbe TC.temperatureB];
        [X Y] = LA1.snapXY();
        data.log.Vsd_X = [data.log.Vsd_X X];
        data.log.Vsd_Y = [data.log.Vsd_Y Y];
        data.log.R = [data.log.R sqrt(X^2+Y^2)*LA1_Rex/(LA1_Vex-sqrt(X^2+Y^2))];
        [X Y] = LA2.snapXY();
        data.log.Vn_X = [data.log.Vn_X X];
        data.log.Vn_Y = [data.log.Vn_Y Y];
        data.log.Vn = [data.log.Vn sqrt(X^2+Y^2)];
        data.log.VnDC = [data.log.VnDC MM.value];
        data.log.B = [data.log.B MS.measuredField()];
    end

%run until temperature is stable around setpoint
    function stabilizeTemperature(setPoint,time,tolerance)
        %temperature should be with +- tolerance in K for time seconds
        Tmonitor = 999*ones(1,time*10);
        n_mon = 0;
        %while max(max(Tmonitor))>tolerance
        while max(Tmonitor)>tolerance
            t1 = clock;
            Tmonitor(mod(n_mon,time*10)+1)=abs(TC.temperatureB()-setPoint);
            n_mon=n_mon+1;
            while etime(clock,t1) < 0.1
            end
        end
    end

    function saveData(i,j,k,m)
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
        tmp = [T_list(T_n), B_list(B_n), Vg_list(Vg_n),...
            data.TProbe(i,j,k,m), data.TVapor(i,j,k,m), data.VnDC(i,j,k,m),...
            data.Vn_X(i,j,k,m), data.Vn_Y(i,j,k,m), data.Vn(i,j,k,m),...
            data.Vsd_X(i,j,k,m), data.Vsd_Y(i,j,k,m), data.R(i,j,k,m)];
        
        fprintf(FilePtr,'%s,',datestr(clock,'YYYY/mm/DD HH:MM:SS'));
        fprintf(FilePtr,'%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g\r\n',tmp);
        fclose(FilePtr);
    end
    function saveMatFile()
        save(fullfile(start_dir, FileName2),'data');
    end
    function checkLockinSensitivity(lowerBound,upperBound)
        if ~exist('lowerBound','var')
            lowerBound = 0.10;
        end
        if ~exist('upperBound','var')
            upperBound = 0.75;
        end
        
        R = LA1.R;
        while (R > LA1_sens*upperBound) || R < LA1_sens*lowerBound
            if R > LA1_sens*upperBound
                LA1.decreaseSens();
                LA1_sens = LA1.sens();
            elseif R < LA1_sens*lowerBound
                LA1.increaseSens()
                LA1_sens = LA1.sens();
            end
            pause(LA1_sensWaitTime)
            R = LA1.R;
        end
    end

%%
%%Connect to devices
% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.Lakeshore335();
TC.connect('12');
% Connect to the multimeter
MM = deviceDrivers.Keysight34401A();
MM.connect('5');
%Connect lockin amplifier
LA1 = deviceDrivers.SRS830();
LA1.connect('8')
LA2 = deviceDrivers.SRS830();
LA2.connect('9')
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
Vex_max = 5;
LA1_Rex = 46E3; %resistor in series with sample
LA1_Vex = 0.1; %initial sine amplitude
LA1_phase = 0; %Phase to use on LA sine output
LA1_freq = 17.777;
LA1_timeConstant = 0.3; %time constant to use on LA
LA1_coupling = 'AC'; %only use DC when measureing below 160mHz
LA1_sens = 0.005;
LA1_bufferRate = 16; % measurement rate in Hz (not used here)
LA1_sensWaitTime = LA1_timeConstant*4;
LA2_phase = 0;
LA2_timeConstant = 0.3;
LA2_coupling = 'AC';
LA2_sens = 20E-6;
LA2_bufferRate = 16;

TvaporRampRate = 20;
TprobeRampRate = 20;
PID = [500,200,100];

DeltaTset = input('Enter target delta T [2]: ');
if isempty(DeltaTset)
    DeltaTset = 2;
end
Nmeasurements = input('How many measurements per parameter point [15]? ');
if isempty(Nmeasurements)
    Nmeasurements = 15;
end
Nruns = input('How many times would you like to sweep gate [2]? ');
if isempty(Nruns)
    Nruns = 2;
end
sweepRate = input('Enter magnet sweep rate (Tesla/min) [0.45] = ');
if isempty(sweepRate)
    sweepRate = 0.45;
end
assert(isnumeric(sweepRate), 'Oops! need to set a sweep rate.');
assert(abs(sweepRate) < MS.maxSweepRate,'sweep rate set too high!');

VWaitTime1 = input('Enter initial Vg equilibration time [2]: ');
if isempty(VWaitTime1)
    VWaitTime1 = 2;
end
VWaitTime2 = input('Enter Vg equilibration time for each step [2]: ');
if isempty(VWaitTime2)
    VWaitTime2 = 2;
end
measurementWaitTime = input('Enter time between measurents [0.3]: ');
if isempty(measurementWaitTime)
    measurementWaitTime = 0.3;
end

UniqueName = input('Enter uniquie file identifier: ','s');
EmailJess = input('Send Jess an email when done? Y/N [Y]: ', 's');
if isempty(EmailJess)
    EmailJess = 'Y';
end
EmailKC = input('Send KC an email when done? Y/N [Y]: ', 's');
if isempty(EmailKC)
    EmailKC = 'Y';
end
AddInfo = input('Enter any additional info to include in file header: ','s');

start_dir = 'C:\Crossno\data\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('Noise_R_G__T_B_Vg', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.csv');
FileName2 = strcat('Noise_R_G__T_B_Vg', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
%create header string
HeaderStr=strcat('Time,T,B,Vg,TProbe,TVapor,VnDC,Vn_X,Vn_Y,Vn,Vsd_X,Vsd_Y,R\r\n');
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
LA1.sineAmp = LA1_Vex;
LA1.sinePhase = LA1_phase;
LA1.sineFreq = LA1_freq;
LA1.timeConstant = LA1_timeConstant;
LA1.inputCoupling = LA1_coupling;
LA1.sens = LA1_sens;
LA1.bufferRate = LA1_bufferRate;

LA2.sinePhase = LA2_phase;
LA2.timeConstant = LA2_timeConstant;
LA2.inputCoupling = LA2_coupling;
LA2.sens = LA2_sens;
LA2.bufferRate = LA2_bufferRate;


% Initialize data structure
blank = zeros(length(T_list),length(B_list),length(Vg_list),Nruns);
blank2 = zeros(length(T_list),length(B_list),length(Vg_list));
data = struct('time',blank,'T_set',T_list,'B_set',B_list,'Vg',Vg_list,...
    'TVapor',blank,'TProbe',blank,'Vn_X',blank,'Vn_Y',blank,'Vn',blank,'VnDC',blank,...
    'Vsd_X',blank,'Vsd_Y',blank,'R',blank,'T_p2p',blank,'P_p2p',blank,'G',blank,...
    'R_mean',blank2,'Vn_mean',blank2,'G_mean',blank2,'VnDC_mean',blank2);

data.log = struct('time',[],'TVapor',[],'TProbe',[],'Vsd_X',[],'Vsd_Y',[],'R',[],...
    'B',[],'Vn_X',[],'Vn_Y',[],'Vn',[],'VnDC',[]);

%record all the unsed settings
data.settings.TC.rampRate1 = TvaporRampRate;
data.settings.TC.rampRate2 = TprobeRampRate;
data.settings.TC.PID1 = PID;
data.settings.TC.PID2 = PID;
data.settings.LA1.sinePhase = LA1_phase;
data.settings.LA1.sineFreq = LA1_freq;
data.settings.LA1.timeConstant = LA1_timeConstant;
data.settings.LA1.inputCoupling = LA1_coupling;
data.settings.LA1.sens = LA1_sens;
data.settings.LA1.Rex = LA1_Rex;
data.settings.LA1.bufferRate = LA1_bufferRate;
data.settings.LA2.sinePhase = LA2_phase;
data.settings.LA2.timeConstant = LA2_timeConstant;
data.settings.LA2.inputCoupling = LA2_coupling;
data.settings.LA2.sens = LA2_sens;
data.settings.LA2.bufferRate = LA2_bufferRate;
data.settings.MS.sweepRate = sweepRate;
data.gain_array=gain_array;

plotResistance(1);
plotG(1)
plotNoise(1);
plotNoiseDC(1)
%% main loop
pauseButton = createPauseButton;
heliumUI = oxfordHeliumUI;
pause(0.01); % To create the button
T_ns = 1:length(T_list);
B_ns = 1:length(B_list);
Vg_ns = 1:length(Vg_list);
tic
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
    TC.setPoint1 = max(T_set-1,1);
    TC.setPoint2 = T_set;

    for B_n=B_ns
        Vex_list=squeeze(Vex_array(T_n,B_n,:));
        %set target field
        B_set = B_list(B_n);
        MS.switchHeater = 1;
        MS.targetField = B_set;
        MS.goToTargetField();
        pause(timeLogInterval);
        timeLog();
        plotLog();
        if B_n==B_ns(1)
            stabilizeTemperature(T_set,5,0.3)
        end
        
        while abs(data.log.B(end) - B_set) > fieldRes
            pause(timeLogInterval);
            timeLog();
            plotLog();
        end
        MS.switchHeater = 0;
        
        for run_n=1:Nruns
            if max(Vex_list) > Vex_max
                disp('warning: excitation voltage hit upper limit');
            end
            for Vg_n=Vg_ns
                %set Vg
                Vg_set = Vg_list(Vg_n);
                VG.ramp2V(Vg_set);
                t1 = clock;
                if Vex_list(Vg_n)>Vex_max
                    Vex_list(Vg_n)=Vex_max;
                end
                %round excitation current to the nearest 10mV with a 10mV min
                LA1_Vex=max(0.01,round(100*Vex_list(Vg_n))/100);
                LA1.sineAmp=LA1_Vex;
                checkLockinSensitivity();
                
                if Vg_n==1
                    while etime(clock,t1)<VWaitTime1;
                    end
                else
                    while etime(clock,t1)<VWaitTime2;
                    end
                end
                
                
                %take "fast" data
                measure_data(T_n,B_n,Vg_n,run_n);
                %save
                saveData(T_n,B_n,Vg_n,run_n);
                %update plots
                plotT_p2p;
            end
            %use measured T to set next guess close to Tset
            Vex_list=Vex_list.*sqrt(abs(DeltaTset./squeeze(data.T_p2p(T_n,B_n,:,run_n))));
            saveMatFile;
            Vg_ns = fliplr(Vg_ns);
        end
        for Vg_n = 1:length(Vg_list)
            data.R_mean(T_n,B_n,Vg_n)=mean(data.R(T_n,B_n,Vg_n,:));
            data.std.R_mean(T_n,B_n,Vg_n)=std(data.R(T_n,B_n,Vg_n,:));
            data.G_mean(T_n,B_n,Vg_n)=mean(data.G(T_n,B_n,Vg_n,:));
            data.std.G_mean(T_n,B_n,Vg_n)=std(data.G(T_n,B_n,Vg_n,:));
            data.Vn_mean(T_n,B_n,Vg_n)=mean(data.Vn(T_n,B_n,Vg_n,:));
            data.std.Vn_mean(T_n,B_n,Vg_n)=std(data.Vn(T_n,B_n,Vg_n,:));
            data.VnDC_mean(T_n,B_n,Vg_n)=mean(data.VnDC(T_n,B_n,Vg_n,:));
            data.std.VnDC_mean(T_n,B_n,Vg_n)=std(data.VnDC(T_n,B_n,Vg_n,:));
        end
        saveMatFile;
        close(heliumUI);
        heliumUI = oxfordHeliumUI;
        plotResistance(T_n);
        plotG(T_n)
        plotNoise(T_n);
        plotNoiseDC(T_n)
        B_ns = fliplr(B_ns);
    end
    toc
end
%calculate averages and standard deviation for parameter set

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     Ramp down and clear      %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
B_set = 0;
MS.switchHeater = 1;
MS.targetField = B_set;
MS.goToTargetField();
timeLog();
TC.range1 = 0;
TC.range2 = 0;
TC.setPoint1 = 0;
TC.setPoint2 = 0;
VG.ramp2V(0);
while abs(data.log.B(end) - B_set) > fieldRes
    pause(timeLogInterval);
    timeLog();
end
MS.switchHeater = 0;


TC.disconnect();
LA1.disconnect();
MS.disconnect();
MM.disconnect();
VG.disconnect();
close(pauseButton)
clear TC LA MS VG MM pauseButton
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