%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect VNA, Resistance, and Temperature vs field and gate voltage
% 
% Created in Mar 2016 by Jesse Crossno
% 
% Modified June 2016 by Jonah Waissman: added RF lockin with SG ext.ref.
%          June 2016: separate RF lockins for 1f and 2f, modulated SG,
%          internal 865 params
% 
% to fix: huge temperature stabilization delay
%         optimize sensitivity (checking against log changes?)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = LI3_RF1f2fRTh_865AM1f2f_MMDC__Vbg_B_T_JW(Vg_list,B_list,T_list)


%%
%Internal convenience functions: plotting and data taking
%     function plotVNA(i,j,k)
%         figure(991); xlabel('Frequency (MHz)');ylabel('S11^2'); hold all; grid on;
%         plot(data.freq*1E-6,squeeze(20*log10(abs(data.traces(i,j,k,:)))));
%     end


    function plotLog()
        
        figure(992); clf; grid on; hold on; xlabel('time (hr)');
        
        [ax,h1,h2] = plotyy(data.log.time/3600,data.log.field,data.log.time/3600,data.log.TProbe);
        set(h1,'LineStyle','none','Marker','o');
        set(h2,'LineStyle','none','Marker','o');
        axes(ax(1));hold on;h4=plot(data.log.time/3600,data.log.persistfield,'oc');ylim(ax(1),'auto');
        axes(ax(2));hold on;h3=plot(data.log.time/3600,data.log.TVapor,'or');ylim(ax(2),'auto');
        
        ylabel(ax(1),'Field (Tesla)');
        ylabel(ax(2),'Temperature (K)');
        legend([h1 h4 h2 h3],'Field','Persistent Field','T Probe','T Vapor','Location','NorthWest');
        
    end


    function plotResistance(i)
        figure(993); clf; 
        
        subplot(3,4,1);
        
        xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        h=surf(data.Vg,data.field_set,squeeze(data.raw.R(i,:,:)));view(2);shading interp;
        set(h,'linestyle','none');colorbar;title('Resistance (no heating) (\Omega)');
        
        subplot(3,4,2); 
        
        xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        h=surf(data.Vg,data.field_set,squeeze(data.raw.R_hot(i,:,:)));view(2);shading interp;
        set(h,'linestyle','none');colorbar;title('Resistance w/ Heating (\Omega)');
        
        subplot(3,4,3);
        
        xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        h=surf(data.Vg,data.field_set,squeeze(data.raw.RF1f_R(i,:,:)));view(2);shading interp;
        set(h,'linestyle','none');colorbar;title('RF 1f R (V)');
        
        subplot(3,4,4);
        
        xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        h=surf(data.Vg,data.field_set,squeeze(data.raw.RF1f_theta(i,:,:)));view(2);shading interp;
        set(h,'linestyle','none');colorbar;title('RF 1f theta (deg)');
        
        subplot(3,4,5);
        
        xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        h=surf(data.Vg,data.field_set,squeeze(data.raw.RF2f_R(i,:,:)));view(2);shading interp;
        set(h,'linestyle','none');colorbar;title('RF 2f R (V)');
        
        subplot(3,4,6);
        
        xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        h=surf(data.Vg,data.field_set,squeeze(data.raw.RF2f_theta(i,:,:)));view(2);shading interp;
        set(h,'linestyle','none');colorbar;title('RF 2f theta (deg)');
        
        subplot(3,4,7);
%         
%         xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
%         grid on; hold on;
%         h=surf(data.Vg,data.field_set,squeeze(data.raw.LA865_1f_R(i,:,:)));view(2);shading interp;
%         set(h,'linestyle','none');colorbar;title('LA865 1f R (V)');
        
        subplot(3,4,8);
        
        xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        h=surf(data.Vg,data.field_set,squeeze(data.raw.LA865_2f_R(i,:,:)));view(2);shading interp;
        set(h,'linestyle','none');colorbar;title('LA865 2f R (V)');
        
        subplot(3,4,9); 
         
         xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        h=surf(data.Vg,data.field_set,squeeze(data.raw.MMDCnoheat(i,:,:)));view(2);shading interp;
        set(h,'linestyle','none');colorbar;title('MMDC heating off (Volt)');
        
        subplot(3,4,10);
        
        xlabel('Gate Voltage (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        h=surf(data.Vg,data.field_set,squeeze(data.raw.MMDCheat(i,:,:)));view(2);shading interp;
        set(h,'linestyle','none');colorbar;title('MMDC heating on (Volt)');
        
    end

% 
%     function plotResistanceLine(i,j)
%         figure(994); xlabel('Vg (volts)');ylabel('Resistance (\Omega)');
%         grid on; hold on;
%         plot(data.Vg,squeeze(data.raw.R(i,j,:)));
%     end

%measures the "fast" variables: Temp, R, Field, and time plus RFLA
%measurements
    function measure_data(i,j,k)
        
        for n=1:Nmeasurements
            
            data.raw.time(i,j,k,n) = etime(clock, StartTime);
            data.raw.TVapor(i,j,k,n) = TC.temperatureA;
            data.raw.TProbe(i,j,k,n) = TC.temperatureB;
            data.raw.field(i,j,k,n) = MS.measuredField();
            
             pause on;
                                    
                pause(measurementWaitTime)
            
            [data.raw.LA_R(i,j,k,n) data.raw.LA_theta(i,j,k,n)] = LA.snapRtheta();
            [data.raw.LA_R(i,j,k,n) data.raw.LA_theta(i,j,k,n) data.settings.LA.sensLog] =...
                checkLockinSensitivity(LA,data.raw.LA_R(i,j,k,n),data.raw.LA_theta(i,j,k,n),data.settings.LA.sensLog);
            
            data.raw.R(i,j,k,n) = data.raw.LA_R(i,j,k,n)*LA_Rex/LA_Vex;
            
            MMDCnoheat=[];
            for ii=1:Nnoise
                pause(measurementWaitTime)
            
                MMDCnoheat(ii) = MMDC.value;          
            
                pause(measurementWaitTime)
            end
            
            data.raw.MMDCnoheat(i,j,k,n) = mean(MMDCnoheat);
            
            SG.enableN='on'; % RF drive turned on only for measurement
            
                pause(2*measurementWaitTime)
                                   
            [data.raw.RF1f_R(i,j,k,n) data.raw.RF1f_theta(i,j,k,n)] = RF1f.snapRtheta();
            [data.raw.RF1f_R(i,j,k,n) data.raw.RF1f_theta(i,j,k,n) data.settings.RF1f.sensLog] = ...
                checkLockinSensitivity(RF1f,data.raw.RF1f_R(i,j,k,n),data.raw.RF1f_theta(i,j,k,n),data.settings.RF1f.sensLog);
                                                
                pause(measurementWaitTime)
            
            [data.raw.RF2f_R(i,j,k,n) data.raw.RF2f_theta(i,j,k,n)] = RF2f.snapRtheta();
            [data.raw.RF2f_R(i,j,k,n) data.raw.RF2f_theta(i,j,k,n) data.settings.RF2f.sensLog] =...
                checkLockinSensitivity(RF2f,data.raw.RF2f_R(i,j,k,n),data.raw.RF2f_theta(i,j,k,n),data.settings.RF2f.sensLog);
                                    
                pause(measurementWaitTime)
            
            [data.raw.LA_R_hot(i,j,k,n) data.raw.LA_theta_hot(i,j,k,n)] = LA.snapRtheta(); %check hot resistance
            [data.raw.LA_R_hot(i,j,k,n) data.raw.LA_theta_hot(i,j,k,n) data.settings.LA.sensLog] =...
                checkLockinSensitivity(LA,data.raw.LA_R_hot(i,j,k,n),data.raw.LA_theta_hot(i,j,k,n),data.settings.LA.sensLog);
            data.raw.R_hot(i,j,k,n) = data.raw.LA_R_hot(i,j,k,n)*LA_Rex/LA_Vex;                        
            
                
            
                pause(2*measurementWaitTime)
                
%             [data.raw.LA865_1f_R(i,j,k,n) data.raw.LA865_1f_theta(i,j,k,n)] = LA865.snapRtheta();
%             [data.raw.LA865_1f_R(i,j,k,n) data.raw.LA865_1f_theta(i,j,k,n) data.settings.LA865.sensLog] =...
%                 checkLockinSensitivity(LA865,data.raw.LA865_1f_R(i,j,k,n),data.raw.LA865_1f_theta(i,j,k,n),data.settings.LA865.sensLog);
%             
%                 pause(2*measurementWaitTime)
%                 
%             LA865.harm=2; % harmonic set in initialization
%                 
%                 pause(2*measurementWaitTime)
                
            [data.raw.LA865_2f_R(i,j,k,n) data.raw.LA865_2f_theta(i,j,k,n)] = LA865.snapRtheta();
            [data.raw.LA865_2f_R(i,j,k,n) data.raw.LA865_2f_theta(i,j,k,n) data.settings.LA865.sensLog] =...
                checkLockinSensitivity(LA865,data.raw.LA865_2f_R(i,j,k,n),data.raw.LA865_2f_theta(i,j,k,n),data.settings.LA865.sensLog);
            
                pause(LA865_sensWaitTime)      %time constant = 1s (MAKE THIS A PARAM)
                
%             LA865.harm=1;
            
%                 pause(measurementWaitTime)

            MMDCheat=[];
            for ii=1:Nnoise
                pause(measurementWaitTime)
            
                MMDCheat(ii) = MMDC.value;          
            
                pause(measurementWaitTime)
            end
            
            data.raw.MMDCheat(i,j,k,n) = mean(MMDCheat);
            
                pause(measurementWaitTime)
            
            SG.enableN='off'; % RF drive turned on only for measurement w/ heating
            
                pause(measurementWaitTime) %add some time to cool off (should check)
                                  
        end
        
        if n>1
            data.time(i,j,k) = mean(data.raw.time(i,j,k,:));
            data.TVapor(i,j,k) = mean(data.raw.TVapor(i,j,k,:));
            data.TProbe(i,j,k) = mean(data.raw.TProbe(i,j,k,:));
            data.LA_R(i,j,k) = mean(data.raw.LA_R(i,j,k,:));
            data.LA_theta(i,j,k) = mean(data.raw.LA_theta(i,j,k,:));
            data.R(i,j,k) = mean(data.raw.R(i,j,k,:));
            data.field(i,j,k) = mean(data.raw.field(i,j,k,:));
            data.std.TVapor(i,j,k) = std(data.raw.TVapor(i,j,k,:));
            data.std.TProbe(i,j,k) = std(data.raw.TProbe(i,j,k,:));
            data.std.LA_R(i,j,k) = std(data.raw.LA_R(i,j,k,:));
            data.std.LA_theta(i,j,k) = std(data.raw.LA_theta(i,j,k,:));
            data.std.R(i,j,k) = std(data.raw.R(i,j,k,:));
            data.std.field(i,j,k) = std(data.raw.field(i,j,k,:));
        end
        
%         VNA.trigger;
%         data.traces(i,j,k,:) = VNA.getSingleTrace();
%         pause(VNAwaitTime);
        
    end

%keep a running track of all parameters vs time
    function timeLog()
        data.log.time = [data.log.time etime(clock, StartTime)];
        data.log.TVapor = [data.log.TVapor TC.temperatureA];
        pause(0.5)
        data.log.TProbe = [data.log.TProbe TC.temperatureB];
        pause(0.5)
        data.log.field = [data.log.field MS.measuredField()];
        pause(0.5)
        data.log.persistfield = [data.log.persistfield MS.persistentField()];
        pause(0.5)
%         [X Y] = LA.snapXY();
%         [R1f theta1f] = RF1f.snapRtheta();
%         [R2f theta2f] = RF2f.snapRtheta();  %heater is off, most of this
%         is irrelevant
%         data.log.LA_X = [data.log.LA_X X];
%         data.log.LA_Y = [data.log.LA_Y Y];
%         data.log.RF1f_R     = [data.log.RF1f_R R1f];         
%         data.log.RF1f_theta     = [data.log.RF1f_theta theta1f];  
%         data.log.RF2f_R     = [data.log.RF2f_R R2f];         
%         data.log.RF2f_theta     = [data.log.RF2f_theta theta2f]; 
%         data.log.R = [data.log.R sqrt(X^2+Y^2)*LA_Rex/LA_Vex];

    end

%run until temperature is stable around setpoint %OUTDATED VERSION REQUIRES
%UPDATE
    function stabilizeTemperature(setPointProbe,setPointVapor,time,tolerance)
        %temperature should be with +- tolerance in K for time seconds
        %Tmonitor = 999*ones(2,time*10);
        TmonitorA = 999*ones(1,time*2);
        TmonitorB = 999*ones(1,time*2);
        n_mon = 0;
        %while max(max(Tmonitor))>tolerance
        starttime=tic;
        while max(TmonitorA)>tolerance || max(TmonitorB)>tolerance || timeelapsed<time
            timeLog();
            pause(timeLogInterval);
            plotLog();
            %Tmonitor(1,mod(n_mon,time*10)+1)=abs(TC.temperatureA()-setPoint+1);
            TmonitorA(1,mod(n_mon,time*2)+1)=abs(data.log.TVapor(end)-setPointVapor);
            TmonitorB(1,mod(n_mon,time*2)+1)=abs(data.log.TProbe(end)-setPointProbe);
            n_mon=n_mon+1;
            timeelapsed=toc(starttime);
        end
        
            
        
        
    end

%saves the  variables
    function saveData(i,j,k)
        save(fullfile(start_dir, FileName2),'data');
%         FilePtr = fopen(fullfile(start_dir, FileName), 'a');
%         tmp = [data.TProbe(i,j,k) data.TVapor(i,j,k) Vg_list(Vg_n)...
%             data.field(i,j,k) data.LA_X(i,j,k) data.LA_Y(i,j,k) data.R(i,j,k)];
%         fprintf(FilePtr,'%s\t',datestr(clock,'YYYY_mm_DD HH:MM:SS'));
%         fprintf(FilePtr,'%g\t%g\t%g\t%g\t%g\t%g\t%g',tmp);
% %         for d=data.traces(i,j,k,:)
% %             fprintf(FilePtr,'\t%s',num2str(d));
% %         end
%         fprintf(FilePtr,'\r\n');
%         fclose(FilePtr);
        
    end

    %checksens has been rewritten to compare passed R reading with local
    %logged sens value to avoid unnecessary gpib calls
    function [R theta sens] = checkLockinSensitivity(LAobj,R,theta,sens,lowerBound,upperBound)
        if ~exist('lowerBound','var')
            lowerBound = 0.10;
        end
        if ~exist('upperBound','var')
            upperBound = 0.75;
        end
        
        if ~exist('R','var')
            [R theta] = LAobj.snapRtheta();
            pause(measurementWaitTime)
        end
        
        if ~exist('sens','var')
            sens = LAobj.sens();
            pause(measurementWaitTime)
        end
            
           
            while (R > sens*upperBound) || (R < sens*lowerBound)
                   
                if R > sens*upperBound
                    LAobj.decreaseSens();
                    pause(2*LA_sensWaitTime)
                    sens = LAobj.sens();
                elseif R < sens*lowerBound
                    LAobj.increaseSens();
                    pause(2*LA_sensWaitTime)
                    sens = LAobj.sens();
                end
                
                pause(LA_sensWaitTime)
                [R theta] = LAobj.snapRtheta();
                pause(measurementWaitTime)
                
            end
            
            
    end


%%
%%Connect to devices
% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.Lakeshore335();
TC.connect('12');
% % Connect to the VNA
% VNA = deviceDrivers.AgilentE8363C();
% VNA.connect('140.247.189.97')
%Connect lockin amplifier
LA = deviceDrivers.SRS830();
LA.connect('9');
%Connect RF lockin amplifiers
RF1f = deviceDrivers.SRS844();
RF1f.connect('6');
RF2f = deviceDrivers.SRS844();
RF2f.connect('11');
%Connect to the Oxford magnet supply
MS = deviceDrivers.Oxford_IPS_120_10();
MS.connect('25');
%connect to YOKO gate supply(using 10Mohm series resistor)
VG = deviceDrivers.YokoGS200();
VG.connect('18')
%connect to SG382 RF drive
SG = deviceDrivers.SG382();
SG.connect('27');
%connect to 34401A
MMDC = deviceDrivers.Keysight34401A();
MMDC.connect('5');
%Connect 865 lockin amplifier
LA865 = deviceDrivers.SRS865();
LA865.connect('3');


%% get/set experimental parameters including saftey checks
%saftey checks (more checks below)
assert(max(abs(B_list)) < MS.maxField,'Target field exceeds limit set by magnet supply');

%internal defaults
timeLogInterval = 2; %time between timeLog measurments
fieldRes = 0.001; %take data when measured field is within fieldRes of target field
LA_Rex = 9.79E6; %resistor in series with sample
LA_Vex = 0.2; %Voltage to use on LA sine output
LA_phase = 0; %Phase to use on LA sine output
LA_freq = 17.317;
LA_timeConstant = 0.3; %time constant to use on LA
LA_coupling = 'AC'; %only use DC when measureing below 160mHz
LA_sens = 0.005;
LA_bufferRate = 16; % measurement rate in Hz (not used here)
LA_sensWaitTime = LA_timeConstant*4;
TvaporRampRate = 2;
TprobeRampRate = 2;
PID = [200,200,100]; %parameters chosen 15-6-2016 JW
Toffset=0.9;
%RF
RF1f_timeConstant = 0.3;
RF1f_sens = 0.0001;
RF1f_phase = 0;
RF1f_freq = 11e6;
RF2f_timeConstant = 0.3;
RF2f_sens = 0.0001;
RF2f_phase = 0;
RF2f_freq = 11e6;
% %VNA
% VNA_power = -30;
%SG
SG_ampN=-33;
SG_ampBNC=0;
SG_freq=11000000;
SG_modenable='on';
SG_modtype=0;
SG_modfunc=0;
SG_modrate=2013;
SG_modAMdepth=100;
%LA865 (done manually for now)
LA865_sineFreq=SG_modrate; 
LA865_intFreq=SG_modrate; 
LA865_refsource=0;
LA865_harm=2; % option to measure both 1f and 2f in measureData **Currently only 2f** (sol'n to heat equation)
LA865_sineAmp=1;
LA865_refsource=0;
LA865_sens=2e-6;
LA865_timeConstant=3;
LA865_sensWaitTime = LA865_timeConstant*4;
Nnoise=3;

Nmeasurements = input('How many measurements per parameter point [1]? ');
if isempty(Nmeasurements)
    Nmeasurements = 1;
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
measurementWaitTime = input('Enter time between measurents [1.2]: ');
if isempty(measurementWaitTime)
    measurementWaitTime = 1.2;
end
% 
% VNAwaitTime=input('Enter VNA wait time [0]: ');
% if isempty(VNAwaitTime)
%     VNAwaitTime = 0;
% end

UniqueName = input('Enter uniquie file identifier: ','s');
% EmailJess = input('Send Jess an email when done? Y/N [N]: ', 's');
% if isempty(EmailJess)
%     EmailJess = 'N';
% end
% EmailKC = input('Send KC an email when done? Y/N [N]: ', 's');
% if isempty(EmailKC)
%     EmailKC = 'N';
% end
AddInfo = input('Enter any additional info to include in file header: ','s');

start_dir = 'C:\JW\b7_devB_Ox\data';
start_dir = uigetdir(start_dir);
StartTime = clock;
% FileName = strcat('Noise_AM865_R_RF1f2f_T__T_B_Vg_JW', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.dat');
FileName2 = strcat('LI3_RF1f2fRTh_865AM1f2f_MMDC__Vbg_B_T_JW', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');
% FilePtr = fopen(fullfile(start_dir, FileName), 'w');
%create header string
% HeaderStr=strcat('Time\tTProbe(K)\tTVapor\tVg\tfield\tX\tY\tR');
% fprintf(FilePtr, HeaderStr);
% fclose(FilePtr);

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

%initialize RF Lockin
RF1f.sinePhase = RF1f_phase; %used for internal ref mode
RF1f.sineFreq = RF1f_freq;   %used for internal ref mode
RF1f.inputImpedance = '50';
RF1f.refMode = 'external';
RF1f.twoFMode = 'off';
RF1f.timeConstant = RF1f_timeConstant;
RF1f.sens = RF1f_sens;

RF2f.sinePhase = RF2f_phase; %used for internal ref mode
RF2f.sineFreq = RF2f_freq;   %used for internal ref mode
RF2f.inputImpedance = '50';
RF2f.refMode = 'external';
RF2f.twoFMode = 'on';
RF2f.timeConstant = RF2f_timeConstant;
RF2f.sens = RF2f_sens;

%initialize VNA
% VNA.trigger_source = 'immediate'; %try this sometime
% pause(1)
% freq = VNA.getX;
% VNA.power = VNA_power; 
% VNA.trigger_source = 'manual';

%initialize SG
SG.ampN=SG_ampN;
SG.ampBNC=SG_ampBNC;
SG.enableBNC='off'; %external reference for RFLA is now a separate SG (not remotely op'd as of 6/16)
SG.enableN='off'; % RF drive turned on only before RF measurement
SG.modenable=SG_modenable;
SG.modtype=SG_modtype;
SG.modfunc=SG_modfunc;
SG.modrate=SG_modrate;
SG.modAMdepth=SG_modAMdepth;

%initialize LA865 
LA865.sineFreq=LA865_sineFreq; 
LA865.intFreq=LA865_intFreq; 
LA865.refsource=LA865_refsource;
LA865.harm=LA865_harm;
LA865.sineAmp=LA865_sineAmp;
LA865.refsource=LA865_refsource;
LA865.sens=LA865_sens;
LA865.timeConstant=LA865_timeConstant;

% 
% %add freq to dat file as col names
% FilePtr = fopen(fullfile(start_dir, FileName), 'a');
% for f=freq
%     fprintf(FilePtr,'\t%e',f);
% end
%     fprintf(FilePtr,'\r\n');
% fclose(FilePtr);

% Initialize data structure
blank = zeros(length(T_list),length(B_list),length(Vg_list));
% trace_blank = zeros(length(T_list),length(B_list),length(Vg_list),length(freq));
data = struct('time',blank,'TVapor',blank,'TProbe',blank,'LA_R',blank ...
    ,'LA_theta',blank,'R',blank,'field',blank,'Vg',Vg_list,'field_set',B_list...
    ,'T_set',T_list...
    ,'RF1f_R',blank,'RF1f_theta',blank...
    ,'RF2f_R',blank,'RF2f_theta',blank...
    ,'LA_R_hot',blank,'LA_theta_hot',blank,'R_hot',blank...
    ,'MMDCnoheat',blank,'MMDCheat',blank...
    ,'MMAC',blank...
    ,'LA865_1f_R',blank,'LA865_1f_theta',blank...
    ,'LA865_2f_R',blank,'LA865_2f_theta',blank);
data.raw = struct('time',blank,'TVapor',blank,'TProbe',blank,'LA_R',blank ...
    ,'LA_theta',blank,'R',blank,'field',blank,'Vg',Vg_list,'field_set',B_list...
    ,'T_set',T_list...
    ,'RF1f_R',blank,'RF1f_theta',blank...
    ,'RF2f_R',blank,'RF2f_theta',blank...
    ,'LA_R_hot',blank,'LA_theta_hot',blank,'R_hot',blank...
    ,'MMDCnoheat',blank,'MMDCheat',blank...
    ,'MMAC',blank...
    ,'LA865_1f_R',blank,'LA865_1f_theta',blank...
    ,'LA865_2f_R',blank,'LA865_2f_theta',blank);
data.log = struct('time',[],'TVapor',[],'TProbe',[],'LA_R',[],'LA_theta',[],'R',[],'field',[],'persistfield',[],'RF1f_R',[],'RF1f_theta',[],'RF2f_R',[],'RF2f_theta',[],'MMDC',[]);

%record all the used settings
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
% data.settings.VNA.power = VNA_power;
data.settings.RF1f.sens = RF1f_sens;
data.settings.RF1f.timeConstant = RF1f_timeConstant;
data.settings.RF1f.inputImpedance = '50';
data.settings.RF1f.refMode = 'external';
data.settings.RF1f.extfreq = 11e6; %Hz, SG382 #2 set manually
data.settings.RF1f.extphase = 0; %deg, SG382 #2 set manually
data.settings.RF1f.extamp = -2; %dBm, SG382 #2 set manually
data.settings.RF2f.sens = RF2f_sens;
data.settings.RF2f.timeConstant = RF2f_timeConstant;
data.settings.RF2f.inputImpedance = '50';
data.settings.RF2f.refMode = 'external';
data.settings.RF2f.extfreq = 11e6; %Hz, SG382 #2 set manually
data.settings.RF2f.extphase = 0; %deg, SG382 #2 set manually
data.settings.RF2f.extamp = -2; %dBm, SG382 #2 set manually
data.settings.SG.ampN=SG_ampN;
data.settings.SG.ampBNC=SG_ampBNC;
data.settings.SG.freq=SG_freq;
data.settings.SG.modenable=SG_modenable;
data.settings.SG.modtype=SG_modtype;
data.settings.SG.modfunc=SG_modfunc;
data.settings.SG.modrate=SG_modrate;
data.settings.SG.modAMdepth=SG_modAMdepth;
data.settings.LA865.sineFreq=LA865_sineFreq; 
data.settings.LA865.refsource=LA865_refsource;
data.settings.LA865.harm=LA865_harm;
data.settings.LA865.sineAmp=LA865_sineAmp;
data.settings.LA865.refsource=LA865_refsource;
data.settings.LA865.sens=LA865_sens;
data.settings.LA865.timeConstant=LA865_timeConstant;
data.settings.Nnoise=Nnoise;
%initialize sens log
data.settings.LA.sensLog = LA_sens;
data.settings.RF1f.sensLog = RF1f_sens;
data.settings.RF2f.sensLog = RF2f_sens;
data.settings.LA865.sensLog = LA865_sens;

%% main loop
pauseButton = createPauseButton;
heliumUI = oxfordHeliumUI; %changed position
pause(0.01); % To create the button
%keep a running log of all measureables vs time
T_ns = 1:length(T_list);
B_ns = 1:length(B_list);
Vg_ns = 1:length(Vg_list);

for T_n=T_ns
    
    T_set = T_list(T_n);
    
    Tvap=T_set-Toffset;
    TC.setPoint1 = Tvap;
    pause(measurementWaitTime);
    TC.setPoint2 = T_set;
    
    if T_set <= 1.6
        T_set=1.5;
        Tvap=T_set;
        TC.setPoint1 = Tvap;
        TC.setPoint2 = T_set;
        TC.range1 = 0;
        TC.range2 = 0;
    elseif T_set <= 2.4
        Tvap=1.5;
        TC.setPoint1 = Tvap;
        TC.setPoint2 = T_set;
        TC.range1 = 1;
        TC.range2 = 1;
    elseif T_set <= 3.5      % changed from 8  
        TC.range1 = 1;
        TC.range2 = 1;
    elseif T_set <= 20     % changed from 70, then 50   
        TC.range1 = 2; 
        TC.range2 = 2;  
    else
        TC.range1 = 3;
        TC.range2 = 3;
    end
 
    pause(timeLogInterval);
        timeLog();
        plotLog();
    disp('Stabilizing new temperature...')
    stabilizeTemperature(T_set,Tvap,5,0.3)
    
    
    for B_n=B_ns
        
        %set target field
        disp('Setting new B field value...')
        field_set = B_list(B_n);
        
        %expect magnet in persistent mode
        %to switch on heater, need to make initial field point same as
        %current persistent value (following SM driver, see p14 of IPS manual)
        MS.switchHeater = 0;
        pause(timeLogInterval);
        persistentField = MS.persistentField;
        pause(timeLogInterval);
        MS.targetField = persistentField;
        pause(timeLogInterval);
        MS.goToTargetField();
        pause(5);
        MS.switchHeater = 1;
        pause(15);
        MS.targetField = field_set;
        pause(timeLogInterval);
        MS.goToTargetField();
        pause(5);
        timeLog();
        pause(timeLogInterval);
        plotLog();
        
        while abs(data.log.field(end) - field_set) > fieldRes           
            timeLog();
            pause(timeLogInterval);
            plotLog();
        end
        MS.switchHeater = 0;
        pause(15);
        MS.goToZero();
        
        disp('Performing measurements...')
        for Vg_n=Vg_ns
            %set Vg
            Vg_set = Vg_list(Vg_n);
            VG.ramp2V(Vg_set);
            
            if Vg_n==1
                pause(VWaitTime1);
            else
                pause(VWaitTime2);
            end
            
            
%             checkLockinSensitivity(LA); %sensitivity checks now done
%             before measurements, see measure_data
            
            
            %take "fast" data
            measure_data(T_n,B_n,Vg_n);
            
            %update plots
            plotResistance(T_n);
%             plotVNA(T_n,B_n,Vg_n);
            %save
            saveData(T_n,B_n,Vg_n);
            
        end
        
        pause(timeLogInterval);
            timeLog();
            plotLog();
        
%         plotResistanceLine(T_n,B_n);

        close(heliumUI);
        heliumUI = oxfordHeliumUI;
        
    end
    
    B_ns = fliplr(B_ns);
    
end

pause off;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     Ramp down and clear      %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Measurements complete. Zeroing and shutting down...')
MS.switchHeater = 0;
pause(timeLogInterval);
persistentField = MS.persistentField;
pause(timeLogInterval);
MS.targetField = persistentField;
pause(timeLogInterval);
MS.goToTargetField();
pause(timeLogInterval);
MS.switchHeater = 1;
pause(15);
MS.targetField = 0;
pause(timeLogInterval);
MS.goToTargetField();
timeLog();
pause(timeLogInterval);
plotLog();
while abs(data.log.field(end)) > fieldRes
    timeLog();
    pause(timeLogInterval);
    plotLog();
end
MS.switchHeater = 0;
pause(15);
MS.goToZero();

TC.range1 = 0;
TC.range2 = 0;
TC.setPoint1 = 0;
TC.setPoint2 = 0;
VG.ramp2V(0);

LA.sineAmp = 0.004;
SG.ampN=-110;
SG.ampBNC=SG_ampBNC;
SG.enableBNC='off'; 
SG.enableN='off'; 

%Record final sensitivity settings
data.settings.LA.sensLog = LA.sens();
pause(measurementWaitTime)
data.settings.RF1f.sensLog = RF1f.sens();
pause(measurementWaitTime)
data.settings.RF2f.sensLog = RF2f.sens();
pause(measurementWaitTime)
data.settings.LA865.sensLog = LA865.sens();
pause(measurementWaitTime)


TC.disconnect();
% VNA.disconnect();
LA.disconnect();
MS.disconnect();
VG.disconnect();
RF1f.disconnect();
RF2f.disconnect();
MMDC.disconnect();
LA865.disconnect();
clear TC LA MS VG RF1f RF2f MMDC LA865

disp('Finished!')

% %% Email data
% if EmailJess || EmailKC == 'Y'
%     setpref('Internet','E_mail','Sweet.Lady.Science@gmail.com');
%     setpref('Internet','SMTP_Server','smtp.gmail.com');
%     setpref('Internet','SMTP_Username','Sweet.Lady.Science@gmail.com');
%     setpref('Internet','SMTP_Password','graphene');
%     props = java.lang.System.getProperties;
%     props.setProperty('mail.smtp.auth','true');
%     props.setProperty('mail.smtp.socketFactory.class','javax.net.ssl.SSLSocketFactory');
%     props.setProperty('mail.smtp.socketFactory.port','465');
%     if EmailJess && EmailKC == 'Y'
%         sendmail({'JDCrossno@gmail.com','fongkc@gmail.com'},strcat('Your Science is done : ',UniqueName),strcat('File :', UniqueName,' taken on :',datestr(StartTime),' at BBN Technologies.   ',AddInfo, '    With Love, Sweet Lady Science'),{fullfile(start_dir, FileName),fullfile(start_dir, FileName2)});
%     elseif EmailJess == 'Y'
%         sendmail({'JDCrossno@gmail.com'},strcat('Your Science is done : ',UniqueName),strcat('File :', UniqueName,' taken on :',datestr(StartTime),' at BBN Technologies.   ',AddInfo, '    With Love, Sweet Lady Science'),{fullfile(start_dir, FileName),fullfile(start_dir, FileName2)});
%     elseif EmailKC == 'Y'
%         sendmail({'fongkc@gmail.com'},strcat('Your Science is done : ',UniqueName),strcat('File :', UniqueName,' taken on :',datestr(StartTime),' at BBN Technologies.   ',AddInfo, '    With Love, Sweet Lady Science'),{fullfile(start_dir, FileName),fullfile(start_dir, FileName2)});
%     end
% end
end