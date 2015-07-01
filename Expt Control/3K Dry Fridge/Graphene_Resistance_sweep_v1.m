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
%includes Spectrum Analyzer
%
%For each T, sweep VG. For each VG, sweep Vex
%
%Vsd is the volatage drop across the graphene
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = Graphene_Resistance_sweep_v1(T_Array,Vg_Array,Vex)
tic
% Initialize the path and create the data file with header
Nmeasurements = input('How many measurements per parameter point? ');
Rex=1E7; disp('Setting Rex to 10 MOhm'); %used to calculate R from Vsd
TWaitTime = input('Enter temperature equilibration time: ');
VWaitTime1 = input('Enter initial Vg equilibration time: ');
VWaitTime2 = input('Enter Vg equilibration time for each step: ');
MeasurementWaitTime = input('Enter time between lockin measurents: ');
Spectrum = input('Record spectrum? Y/N [N]: ','s');
Vector = input('Record VNA? Y/N [N]: ','s');
if Vector=='Y'
    VNAwaitTime=input('Enter VNA wait time: ');
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
start_dir = 'C:\Users\qlab\Documents\data\Graphene Data';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('GrapheneNoise_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName, '.dat');
FileName2 = strcat('GrapheneNoise_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName, '.mat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
%create header string
HeaderStr=strcat(datestr(StartTime), ' Noise sweep using Graphene_Noise_Main_v1\r\nTemp stabilization time = ',...
    num2str(TWaitTime),'s\tFile number:',UniqueName,'\r\n',AddInfo,...
    '\r\nTime   \tCryoConT_(K)\tVg_(V)\tVex_(V)\tVsdX_(V)\tVsdY_(V)\tVnoiseX_(V)\tVnoiseY_(V)\r\n');
fprintf(FilePtr, HeaderStr);
fclose(FilePtr);

%Set figure output properties
%figure(91);hold all;grid on;
%xlabel('Excitation power (nW)');ylabel('Noise Voltage (uV)');

%figure(92);hold all;grid on;
%xlabel('Frequency (MHz)');ylabel('PSD (dB)');

% Ending values
EndingTemperature = 0;
EndingVg = 0;
EndingVex = 0.01;

% Connect to the all the various devices
TC = deviceDrivers.CryoCon22();
VG = deviceDrivers.YokoGS200();
LA1 = deviceDrivers.SRS830();
LA2 = deviceDrivers.SRS830();
if Spectrum=='Y'
    SA = deviceDrivers.HP71000();
end
if Vector=='Y'
    VNA = deviceDrivers.AgilentE8363C();
end

TC.connect('12');
VG.connect('1');
LA1.connect('7');
LA2.connect('8');
if Spectrum=='Y'
    SA.connect('18');
end
if Vector=='Y'
    VNA.connect('192.168.5.101');
end


%saftey checks
T_max = 300; %max T
Vg_max = 30; %max absolute gate voltage
Vex_max = 5; %max excitation voltage

if max(T_Array)>T_max
    error('Temperature is set above T_max')
end
if max(abs(Vg_Array))>Vg_max
    error('Gate voltage is set above Vg_max')
end
if max(abs(Vex))>Vex_max
    error('Excitation voltage is set above Vex_max')
end
LA1.sineAmp=Vex;
%Save SA freq
if Spectrum=='Y'
    [freq, amp]=SA.downloadTrace();
    data.SA.freq=freq;
end

%save VNA freq
if Vector=='Y'
    VNA.output='on'; VNA.reaverage();
    [freq,S11]=VNA.getTrace();
    VNA.output='off';
    pause(VNAwaitTime);
    data.VNA.freq=freq;
end


pause on;

%Enter Tmperature Sweep
for T_n = 1:length(T_Array)
    
    %set Temperature and PID settings, ramps at 10Sec per Kelvin
    TC.loopTemperature = T_Array(T_n);
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
    if T_n>1
        pause(TWaitTime);
    end
    
    %enter Gate Voltage Sweep
    for Vg_n = 1:length(Vg_Array)
        CurrentVg=Vg_Array(Vg_n);
        Vgflag = VG.ramp2V(CurrentVg);
        
        %if first Vg, pause some time
        if Vg_n==1
            pause(VWaitTime1);
        else
            pause(VWaitTime2);
        end
        
        %take "Nmeasurement" measurements
        for n=1:Nmeasurements
            
            %wait MeasurmentWaitTime and find average Temperature
            %if Measurment Wait Time < 100ms, record single T Cryostat
            CurrentTemp=0;
            
            for j=1:max(floor(MeasurementWaitTime*10),1)
                CurrentTemp=CurrentTemp+TC.temperatureA();
                pause(0.1);
            end
            
            CurrentTemp=CurrentTemp/max(floor(MeasurementWaitTime*10),1);
            
            %Record current Source-Drain Voltage across graphene
            [VsdX,VsdY,VsdR,VsdTH]=LA1.get_signal2();
            
            %Record current noise voltage
            
            [VnX,VnY,VnR,VnTH]=LA2.get_signal2();
            
            %Recond the time
            CurrentTime=clock;
            
            %do some calulations
            R=VsdR*Rex/(Vex-VsdR);
            
            %add results into "data"
            data.raw.time(T_n,Vg_n,n)=round(etime(CurrentTime,StartTime)*100)/100;
            data.raw.CryoT(T_n,Vg_n,n)=CurrentTemp;
            data.raw.Vg(T_n,Vg_n,n)=CurrentVg;
            data.raw.Vex(T_n,Vg_n,n)=Vex;
            data.raw.VsdX(T_n,Vg_n,n)=VsdX;
            data.raw.VsdY(T_n,Vg_n,n)=VsdY;
            data.raw.VsdR(T_n,Vg_n,n)=VsdR;
            data.raw.VsdTH(T_n,Vg_n,n)=VsdTH;
            data.raw.R(T_n,Vg_n,n)=R;
            data.raw.VnX(T_n,Vg_n,n)=VnX;
            data.raw.VnY(T_n,Vg_n,n)=VnY;
            data.raw.VnR(T_n,Vg_n,n)=VnR;
            data.raw.VnTH(T_n,Vg_n,n)=VnTH;
            
            %save results to file
            tmp=[CurrentTemp,CurrentVg,Vex,VsdX,VsdY,VnX,VnY,R,];
            FilePtr = fopen(fullfile(start_dir, FileName), 'a');
            fprintf(FilePtr,'%s\t',datestr(CurrentTime,'HH:MM:SS'));
            fprintf(FilePtr,'%g\t%g\t%g\t%g\t%g\t%g\t%g\r\n',tmp);
            fclose(FilePtr);
            
            
        end
        
        
        
        %calculate averages and standard deviation for parameter set
        data.CryoT(T_n,Vg_n)=mean(data.raw.CryoT(T_n,Vg_n,:));
        data.std.CryoT(T_n,Vg_n)=std(data.raw.CryoT(T_n,Vg_n,:));
        data.Vg(T_n,Vg_n)=mean(data.raw.Vg(T_n,Vg_n,:));
        data.Vex(T_n,Vg_n)=mean(data.raw.Vex(T_n,Vg_n,:));
        
        data.VsdX(T_n,Vg_n)=mean(data.raw.VsdX(T_n,Vg_n,:));
        data.std.VsdX(T_n,Vg_n)=std(data.raw.VsdX(T_n,Vg_n,:));
        data.VsdY(T_n,Vg_n)=mean(data.raw.VsdY(T_n,Vg_n,:));
        data.std.VsdY(T_n,Vg_n)=std(data.raw.VsdY(T_n,Vg_n,:));
        data.VsdR(T_n,Vg_n)=mean(data.raw.VsdR(T_n,Vg_n,:));
        data.std.VsdR(T_n,Vg_n)=std(data.raw.VsdR(T_n,Vg_n,:));
        data.VsdTH(T_n,Vg_n)=mean(data.raw.VsdTH(T_n,Vg_n,:));
        data.std.VsdTH(T_n,Vg_n)=std(data.raw.VsdTH(T_n,Vg_n,:));
        
        data.VnX(T_n,Vg_n)=mean(data.raw.VnX(T_n,Vg_n,:));
        data.std.VnX(T_n,Vg_n)=std(data.raw.VnX(T_n,Vg_n,:));
        data.VnY(T_n,Vg_n)=mean(data.raw.VnY(T_n,Vg_n,:));
        data.std.VnY(T_n,Vg_n)=std(data.raw.VnY(T_n,Vg_n,:));
        data.VnR(T_n,Vg_n)=mean(data.raw.VnR(T_n,Vg_n,:));
        data.std.VnR(T_n,Vg_n)=std(data.raw.VnR(T_n,Vg_n,:));
        data.VnTH(T_n,Vg_n)=mean(data.raw.VnTH(T_n,Vg_n,:));
        data.std.VnTH(T_n,Vg_n)=std(data.raw.VnTH(T_n,Vg_n,:));
        
        data.R(T_n,Vg_n)=mean(data.raw.R(T_n,Vg_n,:));
        data.std.R(T_n,Vg_n)=std(data.raw.R(T_n,Vg_n,:));
        
        %plot
        %figure(91);xlabel('CryoCon Temperature (K)');ylabel('Resistance (Ohm)');
        %plot(data.ave.CryoT,data.ave.VsdX*1E8);
        %if mod(CurrentParameterSet,1)==0
        %    figure(92);
        %    plot(data.SA.freq/1E6,data.SA.spectrum);
        %end
        
        %Record Spectrum
        if Spectrum=='Y'
            [freq, amp]=SA.downloadTrace();
            data.SA.spectrum(T_n,Vg_n,:)=amp;
        end
        %record VNA
        if Vector=='Y'
            VNA.output='on'; VNA.reaverage();
            [freq,S11]=VNA.getTrace();
            VNA.output='off';
            pause(VNAwaitTime);
            data.VNA.S11(T_n,Vg_n,:)=S11;
            data.VNA.S11_LogMag(T_n,Vg_n,:)=10*log10(abs(S11).^2);
        end
        
    end
end

save(fullfile(start_dir, FileName2),'data');

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

VG.ramp2V(EndingVg);
LA1.sineAmp=EndingVex;
TC.loopTemperature = EndingTemperature;
TC.range='LOW'; TC.pGain=1; TC.iGain=1;

%clean things up
TC.disconnect();
VG.disconnect();
LA1.disconnect();
LA2.disconnect();
if Spectrum=='Y'
    SA.disconnect();
end
if Vector=='Y'
    VNA.disconnect();
end
pause off;
toc