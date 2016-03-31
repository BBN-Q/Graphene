%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect VNA, SA (peaks), ResistanceXX (ix and vx), and Temperature vs field and gate voltage
% Created in Mar 2016 by Jesse Crossno
% Modified by Jonah Waissman 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = VNA_Rxx_T_SA__B_Vg(B_list,Vg_list,VNA_B_list,VNA_Vg_list,SA_B_list,SA_Vg_list)
%%
%Internal convenience functions: plotting and data taking

    function plotVNA(i,j)
        
        figure(991); xlabel('Frequency (MHz)');ylabel('S11^2'); hold all; grid on;
        plot(data.VNA.freq*1E-6,squeeze(20*log10(abs(data.VNA.traces(i,j,:)))));
        
    end


    function plotSA(i,j)
        
        figure(995); xlabel('Frequency (MHz)');ylabel('dBm'); hold all; grid on;
        plot(data.SAdat{i,j}(:,1)*1E-6,data.SAdat{i,j}(:,2),'.');
        
    end


    function plotSA2D(i,j)
        
        [sr sc]=size(data.SAdat);  
        npkmat=zeros(sr,sc);
        
%         for n=1:sr
%             for m=1:sc
%                 npkmat(n,m)=numel(data.SAdat{n,m}(:,1));
%             end
%         end
%              
%         npeaks=min(min(npkmat));
        
        npeaks=3;

        for n=1:npeaks
            
            figure(880+n); clf; xlabel('Vg (V)'); ylabel('Field (Tesla)');
            grid on; hold on;
            
                      
            SAdatmat=zeros(sr,sc);
            
            for m=1:sr
                for p=1:sc
                    SAdatmat(m,p)=data.SAdat{m,p}(n,2);
                end
            end
            
            h=surf(data.SA.Vg,data.SA.field_set,SAdatmat);view(2);
            set(h,'linestyle','none');colorbar;title(['SA amp, peak #' num2str(n) ' (dBm)']);
            
        end
        
    end


    function plotLog()
        
        figure(992); clf; grid on; hold on; xlabel('time (s)');
        [ax,h1,h2] = plotyy(data.log.time,data.log.field,data.log.time,data.log.TProbe);
        ylabel(ax(1),'Field (Tesla)');
        ylabel(ax(2),'Temperature (K)');
        legend('Probe','Field');
        
    end


    function plotResistance()
        
        figure(993); clf; xlabel('Vg (V)');ylabel('Field (Tesla)');
        grid on; hold on;
        h=surf(data.Vg,data.field_set,data.Rxx);view(2);
        set(h,'linestyle','none');colorbar;title('Rxx (\Omega)');
        
    end


    function plotResistanceLine()
        
        figure(994); clf; xlabel('Vg (V)');ylabel('Rxx (\Omega)');
        grid on; hold on;
        for i=1:length(data.Rxx(:,1))
            plot(data.Vg,data.Rxx(i,:));
        end
        
    end
    
    %measures the "fast" variables: Temp, R, Field, and time
    
    function measure_data(i,j)
        
        for n=1:Nmeasurements
            pause(measurementWaitTime)
            data.raw.time(i,j,n) = etime(clock, StartTime);
            data.raw.TVapor(i,j,n) = TC.get_temperature('A');
            data.raw.TProbe(i,j,n) = TC.get_temperature('B');
            [data.raw.LA_ix_X(i,j,n) data.raw.LA_ix_Y(i,j,n)] = LA_ix.snapXY();
            [data.raw.LA_vx_X(i,j,n) data.raw.LA_vx_Y(i,j,n)] = LA_vx.snapXY();
            data.raw.Rxx(i,j,n) = data.raw.LA_vx_X(i,j,n)/data.raw.LA_ix_X(i,j,n);
            data.raw.field(i,j,n) = MS.measuredField();
        end
        data.TVapor(i,j) = mean(data.raw.TVapor(i,j,:));
        data.TProbe(i,j) = mean(data.raw.TProbe(i,j,:));
        data.LA_ix_X(i,j) = mean(data.raw.LA_ix_X(i,j,:));
        data.LA_ix_Y(i,j) = mean(data.raw.LA_ix_Y(i,j,:));
        data.LA_vx_X(i,j) = mean(data.raw.LA_vx_X(i,j,:));
        data.LA_vx_Y(i,j) = mean(data.raw.LA_vx_Y(i,j,:));
        data.Rxx(i,j) = mean(data.raw.Rxx(i,j,:));
        data.field(i,j) = mean(data.raw.field(i,j,:));
    end


    %keep a running track of all parameters vs time
    function timeLog()
        data.log.time(TL_n) = etime(clock, StartTime);
        data.log.TVapor(TL_n) = TC.get_temperature('A');
        data.log.TProbe(TL_n) = TC.get_temperature('B');
        [data.log.LA_ix_X(TL_n) data.log.LA_ix_Y(TL_n)] = LA_ix.snapXY();
        [data.log.LA_vx_X(TL_n) data.log.LA_vx_Y(TL_n)] = LA_vx.snapXY();
        data.log.Rxx(TL_n) = data.log.LA_vx_X(TL_n)/data.log.LA_ix_X(TL_n);
        data.log.field(TL_n) = MS.measuredField();
        data.log.Vg(TL_n) = currentVg;
        TL_n = TL_n+1;
    end


    %measures the all variables including VNA 
    
    function measure_VNA(i,j)
        data.VNA.time(i,j) = etime(clock, StartTime);
        data.VNA.TVapor(i,j) = TC.get_temperature('A');
        data.VNA.TProbe(i,j) = TC.get_temperature('B');
        data.VNA.LA_ix_X(i,j) = LA_ix.X();
        data.VNA.LA_ix_Y(i,j) = LA_ix.Y();
        data.VNA.LA_vx_X(i,j) = LA_vx.X();
        data.VNA.LA_vx_Y(i,j) = LA_vx.Y();
        data.VNA.Rxx(i,j) = data.LA_vx_X(i,j)/data.LA_ix_X(i,j);
        data.VNA.field(i,j) = MS.measuredField();
        VNA.output = 'on'; 
        pause(VNAwaitTime);VNA.reaverage();
        data.VNA.traces(i,j,:) = VNA.getSingleTrace();
        VNA.output = 'off';
        pause(VNAwaitTime);
    end


    function measure_SA(i,j)
        data.SA.time(i,j) = etime(clock, StartTime);
        data.SA.TVapor(i,j) = TC.get_temperature('A');
        data.SA.TProbe(i,j) = TC.get_temperature('B');
        data.SA.LA_ix_X(i,j) = LA_ix.X();
        data.SA.LA_ix_Y(i,j) = LA_ix.Y();
        data.SA.LA_vx_X(i,j) = LA_vx.X();
        data.SA.LA_vx_Y(i,j) = LA_vx.Y();
        data.SA.Rxx(i,j) = data.LA_vx_X(i,j)/data.LA_ix_X(i,j);
        data.SA.field(i,j) = MS.measuredField();
        [SAfreq SAtrace]=SA.SAPeakAcq();
        pause(SAwaitTime);
        [sortFreq ind]=sort(SAfreq);
        SAcurdat=[sortFreq SAtrace(ind)];
        data.SAdat{i,j}=SAcurdat;
        
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
        
        R = abs(LA_ix.R);
        while (R > LA_sens*1e-6*upperBound) || R < LA_sens*1e-6*lowerBound % factor for current sens
            
            if LA_sens < 100e-9 % to avoid very small sens for near-zero signals
                break;
            end
            
            if R > LA_sens*1e-6*upperBound
                LA_ix.decreaseSens();
                LA_sens = LA_ix.sens();
            elseif R < LA_sens*1e-6*lowerBound
                LA_ix.increaseSens()
                LA_sens = LA_ix.sens();
            end
            pause(LA_sensWaitTime)
            R = abs(LA_ix.R);
        end
        
        R = abs(LA_vx.R);
        while (R > LA_sens*upperBound) || R < LA_sens*lowerBound
            
            if LA_sens < 100e-9 % to avoid very small sens for near-zero signals
                break;
            end
            
            if R > LA_sens*upperBound
                LA_vx.decreaseSens();
                LA_sens = LA_vx.sens();
            elseif R < LA_sens*lowerBound
                LA_vx.increaseSens()
                LA_sens = LA_vx.sens();
            end
            pause(LA_sensWaitTime)
            R = abs(LA_vx.R);
        end
    end

%%
%%Connect to devices
% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.Lakeshore335();
TC.connect('12');
%Connect to the VNA
VNA = deviceDrivers.AgilentE8363C();
VNA.connect('140.247.189.60')
%Connect lockin amplifier
LA_ix = deviceDrivers.SRS830();
LA_ix.connect('5')
LA_vx = deviceDrivers.SRS830();
LA_vx.connect('6')
%Connect to the Oxford magnet supply
MS = deviceDrivers.Oxford_IPS_120_10();
MS.connect('25');
%connect to YOKO gate supply
VG = deviceDrivers.YokoGS200();
VG.connect('17')
%connect to SA
SA = deviceDrivers.AgilentN9020A;
SA.connect('7');

%% get/set experimental parameters including saftey checks
%saftey checks (more checks below)
% assert(max(abs(B_list)) < MS.maxField,'Target field exceeds limit set by magnet supply');

%internal defaults
timeLogInterval = 2; %time between timeLog measurments
fieldRes = 0.001; %take data when measured field is within fieldRes of target field
% LA_Rex = 1E7; %resistor in series with sample
LA_Vex = 0.1; %Voltage to use on LA sine output
LA_phase = 0; %Phase to use on LA sine output
LA_freq = 67.717;
LA_timeConstant = 0.3; %time constant to use on LA
LA_coupling = 'AC'; %only use DC when measureing below 160mHz
LA_sens = 0.005;
LA_bufferRate = 16; % measurement rate in Hz (not used here)
LA_sensWaitTime = LA_timeConstant*4;

Nmeasurements = input('How many measurements per parameter point [10]? ');
if isempty(Nmeasurements)
    Nmeasurements = 10;
end
sweepRate = input('Enter magnet sweep rate (Tesla/min) [0.1] = ');
if isempty(sweepRate)
    sweepRate = 0.1;
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

SAwaitTime=input('Enter SA wait time [2]: ');
if isempty(SAwaitTime)
    SAwaitTime = 1;
end

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

start_dir = 'C:\JW\b7_devA_Ox\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('VNA_Rxx_T__B_Vg', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');

%% Initialize file structure and equipment
pause on;

%initialize the gate
currentVg = Vg_list(1);
VG.ramp2V(currentVg);
        
% %initialize magent
MS.remoteMode();
MS.sweepRate = sweepRate;
MS.switchHeater = 1;

%initialize Lockin
LA_ix.sineAmp = LA_Vex;
LA_ix.sinePhase = LA_phase;
LA_ix.sineFreq = LA_freq;
LA_ix.timeConstant = LA_timeConstant;
LA_ix.inputCoupling = LA_coupling;
LA_ix.sens = LA_sens;
LA_ix.bufferRate = LA_bufferRate;
% LA_vx.sineAmp = LA_Vex;       % locked to LA_ix
% LA_vx.sinePhase = LA_phase;   % locked to LA_ix
% LA_vx.sineFreq = LA_freq;     % locked to LA_ix
LA_vx.timeConstant = LA_timeConstant;
LA_vx.inputCoupling = LA_coupling;
LA_vx.sens = LA_sens;
LA_vx.bufferRate = LA_bufferRate;
% 
% %initialize VNA
VNA.output = 'on';
pause(VNAwaitTime);
VNA.reaverage();
freq = VNA.getX;
VNA.output='off';


% Initialize data structure
blank = zeros(length(B_list),length(Vg_list));
VNA_blank = zeros(length(VNA_B_list),length(VNA_Vg_list));
SA_blank = zeros(length(SA_B_list),length(SA_Vg_list));
trace_blank = zeros(length(VNA_B_list),length(VNA_Vg_list),length(freq));
data = struct('time',blank,'tempVapor',blank,'tempProbe',blank,'LA_ix_X',blank ...
    ,'LA_ix_Y',blank,'LA_vx_X',blank,'LA_vx_Y',blank,'Rxx',blank,'field',blank ...
    ,'Vg',Vg_list,'field_set',B_list);
data.VNA=struct('time',VNA_blank,'tempVapor',VNA_blank,'tempProbe',VNA_blank ...
    ,'traces',trace_blank,'freq',freq ,'LA_ix_X',blank ...
    ,'LA_ix_Y',blank,'LA_vx_X',blank,'LA_vx_Y',blank,'Rxx', ...
    VNA_blank,'field',VNA_blank,'Vg',VNA_Vg_list,'field_set',VNA_B_list);
data.SA=struct('time',SA_blank,'tempVapor',SA_blank,'tempProbe',SA_blank ...
    ,'LA_ix_X',blank ...
    ,'LA_ix_Y',blank,'LA_vx_X',blank,'LA_vx_Y',blank,'Rxx', ...
    SA_blank,'field',SA_blank,'Vg',SA_Vg_list,'field_set',SA_B_list);
data.SAdat=cell(length(SA_B_list),length(SA_Vg_list));

for n =1:length(SA_B_list)
    for m =1:length(SA_Vg_list)
        data.SAdat{n,m}=zeros(10,2);
    end
end


%save every saveTime seconds
saveTime = 60;
lastSave = clock;

%% main loop

%keep a running log of all measureables vs time
TL_n = 1;
VNA_B_n = 1;
SA_B_n = 1;
Vg_index = 1:length(Vg_list);
VNA_Vg_index = 1:length(VNA_Vg_list);
VNA_B_index = 1:length(VNA_B_list);
SA_Vg_index = 1:length(SA_Vg_list);
SA_B_index = 1:length(SA_B_list);
VNA_curB=0;
SA_curB=0;

for B_n=1:length(B_list)
    
    %set target field
    targetField = B_list(B_n);
    MS.targetField = targetField;
    MS.goToTargetField();
    timeLog();
    plotLog();
    
    if numel(VNA_B_list)>1
    	if any(targetField==VNA_B_list) && B_n~=1
          VNA_B_n=VNA_B_n+1;
          VNA_curB=VNA_B_list(VNA_B_n);
        end
    end
    
    if numel(SA_B_list)>1
        if any(targetField==SA_B_list)  && B_n~=1
            SA_B_n=SA_B_n+1;
            SA_curB=SA_B_list(SA_B_n);
        end
    end
    
    while data.log.field(end) < targetField - fieldRes || data.log.field(end) > targetField + fieldRes 
        pause(timeLogInterval);
        timeLog();
        plotLog();
    end
    
    VNA_Vg_n=1;
    SA_Vg_n=1;
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
        
         if any(targetField==SA_B_list) && any(currentVg==SA_Vg_list)
            measure_SA(SA_B_n,SA_Vg_index(SA_Vg_n));
            plotSA(SA_B_n,SA_Vg_index(SA_Vg_n));
            
            if(SA_B_n>1) && (SA_Vg_index(SA_Vg_n)>1)
                plotSA2D(SA_B_n,SA_Vg_index(SA_Vg_n));
            end
            
            SA_Vg_n = SA_Vg_n + 1;
         end
        
        
         
        %save every "saveTime" seconds
        if etime(clock, lastSave) > saveTime
            saveData();
        end
    end
%     Vg_list = fliplr(Vg_list);  % don't raster; measure always same direction
%     Vg_index = fliplr(Vg_index);
%     VNA_Vg_index = fliplr(VNA_Vg_index);
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

LA_ix.sineAmp = 0.004;
VG.ramp2V(0);

TC.disconnect();
VNA.disconnect();
LA_ix.disconnect();
LA_vx.disconnect();
MS.disconnect();
VG.disconnect();
SA.disconnect();
clear TC VNA LA_ix LA_vx MS VG SA
%% Email data
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