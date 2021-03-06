%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Noise Measurment Sweeping Software
% version 1.0
% Created in Dec 2014 by Jess Crossno
% Using:
%   CryoCon22 as Temperature Tontrol (TC)
%   Yoko GS200 as Gate Voltage Source (VG)
%   SRS830 #1 as excitation current and resistance monitor (LA1)
%   SRS830 #2 as Noise/Temperature monitor at 2f (LA2)
%   HP71000 as spectrum analyzer (SA)
%   AgilentE8363C as VNA (VNA)
%
%
% Used to collect thermal conductance. Attemps to heat sample by some
% amount (DeltaTset) using the gain value specified by the gain_matrix.
% Ramps through T_array and Vg_array. gain_matrix should be T_array by
% Vg_array. Can record spectrum and VNA is desired
%
% Starts by applying constant Vex then runs each temperature twice using
% the previous runs Gth (i.e. is run run 5

%
%

%
%For each T, sweep VG. For each VG
%
%gain_matrix should be (T x Vg)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data] = Graphene_Noise_Main_v5(T_Array,Vg_Array,gain_matrix,initial_Vex_Array)
tic
% Initialize the path and create the data file with header
DeltaTset = input('Enter target delta T: ');
Rex=5E4; disp('Setting Rex to 50KOhm'); %used to calculate R from Vsd
%InitialVex = input('Enter Initial Vex for guess: ');
Nmeasurements = input('How many measurements per parameter point? ');
NTempPoints = input('How many times would you like to measure each temperature? ');
TWaitTime = input('Enter temperature equilibration time: ');
VWaitTime1 = input('Enter initial Vg equilibration time: ');
VWaitTime2 = input('Enter Vg equilibration time for each step: ');
MeasurementWaitTime = input('Enter time between lockin measurents: ');
Spectrum = input('Record spectrum? Y/N [N]: ','s');
if isempty(Spectrum)
    Spectrum = 'N';
end
Vector = input('Record VNA? Y/N [N]: ','s');
if isempty(Vector)
    Vector = 'N';
end
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
    num2str(TWaitTime),'s\tFile number:',UniqueName,'\tRex=',num2str(Rex),'\r\n',AddInfo,...
    '\r\nTime   \tCryoConT_(K)\tVg_(V)\tVex_(V)\tVsdX_(V)\tVsdY_(V)\tVnX_(V)\tVnY_(V)\tR_(Ohm)\tT_p2p_(K)\tP_p2p_(W)\tG_(W/K)\r\n');
fprintf(FilePtr, HeaderStr);
fclose(FilePtr);


% Ending values
EndingTemperature = 0;
EndingVg = 0;
EndingVex = 0.01;

% Connect to the all the various devices
TC = deviceDrivers.CryoCon22();
VG = deviceDrivers.YokoGS200();
LA1 = deviceDrivers.SRS830();
LA2 = deviceDrivers.SRS830();
LA3 = deviceDrivers.SRS830();

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
LA3.connect('9');
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

%clear figures
figure(91);clf;

Vex_Array=initial_Vex_Array;
data.gain_matrix=gain_matrix;




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
    toc;
    if T_Array(T_n) ~= 0
        pause(TWaitTime);
    end
    
    for TempPoints_n=1:NTempPoints
        
        if max(abs(Vex_Array))>Vex_max
            disp('Warning: Vex attempted to go above Vex_max')
        end
        
        %enter Gate Voltage Sweep
        for Vg_n = 1:length(Vg_Array)
            
            %set amp to a safe value before changing Vg
            LA1.sineAmp=EndingVex;
            
            %set gate voltage
            CurrentVg=Vg_Array(Vg_n);
            Vgflag = VG.ramp2V(CurrentVg);
            
            if Vex_Array(Vg_n)>Vex_max
                Vex_Array(Vg_n)=Vex_max;
            end
            
            %round excitation current to the nearest 10mV with a 10mV min
            CurrentVex=max(0.01,round(100*Vex_Array(Vg_n))/100);
            LA1.sineAmp=CurrentVex;
            
            %if first Vg, pause some time
            if Vg_n==1
                pause(VWaitTime1);
            else
                pause(VWaitTime2);
            end
            
            %comment this line out if you dont want auto gain/phase
            % pause(20)
            % LA1.auto_gain;%LA1.auto_phase;
            % LA2.auto_gain;%LA2.auto_phase;
            % pause(20);
            
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
                
                %Record 3 omega signal
                
                [V3wX,V3wY,V3wR,V3wTH]=LA3.get_signal2();
                
                %Recond the time
                CurrentTime=clock;
                
                %do some calulations
                R=VsdR*Rex/(CurrentVex-VsdR);
                T_p2p=2*sqrt(2)*VnX/gain_matrix(T_n,Vg_n);
                P_p2p=2*VsdR*CurrentVex/Rex;
                G=P_p2p/T_p2p;
                
                %add results into "data"
                data.raw.time(T_n,Vg_n,TempPoints_n,n)=round(etime(CurrentTime,StartTime)*100)/100;
                data.raw.CryoT(T_n,Vg_n,TempPoints_n,n)=CurrentTemp;
                data.raw.Vg(T_n,Vg_n,TempPoints_n,n)=CurrentVg;
                data.raw.Vex(T_n,Vg_n,TempPoints_n,n)=CurrentVex;
                data.raw.VsdX(T_n,Vg_n,TempPoints_n,n)=VsdX;
                data.raw.VsdY(T_n,Vg_n,TempPoints_n,n)=VsdY;
                data.raw.VsdR(T_n,Vg_n,TempPoints_n,n)=VsdR;
                data.raw.VsdTH(T_n,Vg_n,TempPoints_n,n)=VsdTH;
                data.raw.R(T_n,Vg_n,TempPoints_n,n)=R;
                data.raw.VnX(T_n,Vg_n,TempPoints_n,n)=VnX;
                data.raw.VnY(T_n,Vg_n,TempPoints_n,n)=VnY;
                data.raw.VnR(T_n,Vg_n,TempPoints_n,n)=VnR;
                data.raw.VnTH(T_n,Vg_n,TempPoints_n,n)=VnTH;
                data.raw.V3wX(T_n,Vg_n,TempPoints_n,n)=VnX;
                data.raw.V3wY(T_n,Vg_n,TempPoints_n,n)=VnY;
                data.raw.V3wR(T_n,Vg_n,TempPoints_n,n)=VnR;
                data.raw.V3wTH(T_n,Vg_n,TempPoints_n,n)=VnTH;
                data.raw.T_p2p(T_n,Vg_n,TempPoints_n,n)=T_p2p;
                data.raw.P_p2p(T_n,Vg_n,TempPoints_n,n)=P_p2p;
                data.raw.G(T_n,Vg_n,TempPoints_n,n)=G;
                
                %save results to file
                tmp=[CurrentTemp,CurrentVg,CurrentVex,VsdX,VsdY,VnX,VnY,V3wX,V3wY,R,T_p2p,P_p2p,G];
                FilePtr = fopen(fullfile(start_dir, FileName), 'a');
                fprintf(FilePtr,'%s\t',datestr(CurrentTime,'HH:MM:SS'));
                fprintf(FilePtr,'%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\r\n',tmp);
                fclose(FilePtr);
                
                
            end
            
            
            
            %calculate averages and standard deviation for parameter set
            data.CryoT(T_n,Vg_n,TempPoints_n)=mean(data.raw.CryoT(T_n,Vg_n,TempPoints_n,:));
            data.std.CryoT(T_n,Vg_n,TempPoints_n)=std(data.raw.CryoT(T_n,Vg_n,TempPoints_n,:));
            data.Vg(T_n,Vg_n,TempPoints_n)=mean(data.raw.Vg(T_n,Vg_n,TempPoints_n,:));
            data.Vex(T_n,Vg_n,TempPoints_n)=mean(data.raw.Vex(T_n,Vg_n,TempPoints_n,:));
            
            data.Vsd.X(T_n,Vg_n,TempPoints_n)=mean(data.raw.VsdX(T_n,Vg_n,TempPoints_n,:));
            data.std.Vsd.X(T_n,Vg_n,TempPoints_n)=std(data.raw.VsdX(T_n,Vg_n,TempPoints_n,:));
            data.Vsd.Y(T_n,Vg_n,TempPoints_n)=mean(data.raw.VsdY(T_n,Vg_n,TempPoints_n,:));
            data.std.Vsd.Y(T_n,Vg_n,TempPoints_n)=std(data.raw.VsdY(T_n,Vg_n,TempPoints_n,:));
            data.Vsd.R(T_n,Vg_n,TempPoints_n)=mean(data.raw.VsdR(T_n,Vg_n,TempPoints_n,:));
            data.std.Vsd.R(T_n,Vg_n,TempPoints_n)=std(data.raw.VsdR(T_n,Vg_n,TempPoints_n,:));
            data.Vsd.TH(T_n,Vg_n,TempPoints_n)=mean(data.raw.VsdTH(T_n,Vg_n,TempPoints_n,:));
            data.std.Vsd.TH(T_n,Vg_n,TempPoints_n)=std(data.raw.VsdTH(T_n,Vg_n,TempPoints_n,:));
            
            data.Vn.X(T_n,Vg_n,TempPoints_n)=mean(data.raw.VnX(T_n,Vg_n,TempPoints_n,:));
            data.std.Vn.X(T_n,Vg_n,TempPoints_n)=std(data.raw.VnX(T_n,Vg_n,TempPoints_n,:));
            data.Vn.Y(T_n,Vg_n,TempPoints_n)=mean(data.raw.VnY(T_n,Vg_n,TempPoints_n,:));
            data.std.Vn.Y(T_n,Vg_n,TempPoints_n)=std(data.raw.VnY(T_n,Vg_n,TempPoints_n,:));
            data.Vn.R(T_n,Vg_n,TempPoints_n)=mean(data.raw.VnR(T_n,Vg_n,TempPoints_n,:));
            data.std.Vn.R(T_n,Vg_n,TempPoints_n)=std(data.raw.VnR(T_n,Vg_n,TempPoints_n,:));
            data.Vn.TH(T_n,Vg_n,TempPoints_n)=mean(data.raw.VnTH(T_n,Vg_n,TempPoints_n,:));
            data.std.Vn.TH(T_n,Vg_n,TempPoints_n)=std(data.raw.VnTH(T_n,Vg_n,TempPoints_n,:));
            
            data.V3w.X(T_n,Vg_n,TempPoints_n)=mean(data.raw.V3wX(T_n,Vg_n,TempPoints_n,:));
            data.std.V3w.X(T_n,Vg_n,TempPoints_n)=std(data.raw.V3wX(T_n,Vg_n,TempPoints_n,:));
            data.V3w.Y(T_n,Vg_n,TempPoints_n)=mean(data.raw.V3wY(T_n,Vg_n,TempPoints_n,:));
            data.std.V3w.Y(T_n,Vg_n,TempPoints_n)=std(data.raw.V3wY(T_n,Vg_n,TempPoints_n,:));
            data.V3w.R(T_n,Vg_n,TempPoints_n)=mean(data.raw.V3wR(T_n,Vg_n,TempPoints_n,:));
            data.std.V3w.R(T_n,Vg_n,TempPoints_n)=std(data.raw.V3wR(T_n,Vg_n,TempPoints_n,:));
            data.V3w.TH(T_n,Vg_n,TempPoints_n)=mean(data.raw.V3wTH(T_n,Vg_n,TempPoints_n,:));
            data.std.V3w.TH(T_n,Vg_n,TempPoints_n)=std(data.raw.V3wTH(T_n,Vg_n,TempPoints_n,:));
            
            data.T_p2p(T_n,Vg_n,TempPoints_n)=mean(data.raw.T_p2p(T_n,Vg_n,TempPoints_n,:));
            data.std.T_p2p(T_n,Vg_n,TempPoints_n)=std(data.raw.T_p2p(T_n,Vg_n,TempPoints_n,:));
            data.R(T_n,Vg_n,TempPoints_n)=mean(data.raw.R(T_n,Vg_n,TempPoints_n,:));
            data.std.R(T_n,Vg_n,TempPoints_n)=std(data.raw.R(T_n,Vg_n,TempPoints_n,:));
            data.P_p2p(T_n,Vg_n,TempPoints_n)=mean(data.raw.P_p2p(T_n,Vg_n,TempPoints_n,:));
            data.std.P_p2p(T_n,Vg_n,TempPoints_n)=std(data.raw.P_p2p(T_n,Vg_n,TempPoints_n,:));
            data.G(T_n,Vg_n,TempPoints_n)=mean(data.raw.G(T_n,Vg_n,TempPoints_n,:));
            data.std.G(T_n,Vg_n,TempPoints_n)=std(data.raw.G(T_n,Vg_n,TempPoints_n,:));
            
            
            
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
            end
            
            
        end
        
        %save data
        save(fullfile(start_dir, FileName2),'data');
        
        %plot
        figure(90);hold all;xlabel('Gate Voltage [V]');ylabel('Mean Temperature Rise [K]')
        plot(data.Vg(end,:,TempPoints_n),data.T_p2p(end,:,TempPoints_n));
        
        %use measured T to set next guess close to Tset
        Vex_Array=Vex_Array.*sqrt(abs(DeltaTset./data.T_p2p(T_n,:,TempPoints_n)));
        
    end
    
    %calculate averages and standard deviation for parameter set
    for Vg_n_tmp = 1:length(Vg_Array)
        data.CryoT_mean(T_n,Vg_n_tmp)=mean(data.CryoT(T_n,Vg_n_tmp,:));
        data.std.CryoT_mean(T_n,Vg_n_tmp)=std(data.CryoT(T_n,Vg_n_tmp,:));
        data.R_mean(T_n,Vg_n_tmp)=mean(data.R(T_n,Vg_n_tmp,:));
        data.std.R_mean(T_n,Vg_n_tmp)=std(data.R(T_n,Vg_n_tmp,:));
        data.G_mean(T_n,Vg_n_tmp)=mean(data.G(T_n,Vg_n_tmp,:));
        data.std.G_mean(T_n,Vg_n_tmp)=std(data.G(T_n,Vg_n_tmp,:));
    end
    
    if T_n > 1
        figure(92);clf;
        h=surf(Vg_Array,data.CryoT_mean(:,1),data.R_mean);view(2);
        xlabel('Gate Voltage (V)'),ylabel('Bath Temperature (K)');
        set(h,'linestyle','none');colorbar;title('Electrical Resistance');
        figure(93);clf;
        h=surf(Vg_Array,data.CryoT_mean(:,1),data.G_mean);view(2);
        xlabel('Gate Voltage (V)'),ylabel('Bath Temperature (K)');
        set(h,'linestyle','none');colorbar;title('Thermal Conductance');
        figure(94);clf;
        h=surf(Vg_Array,data.CryoT_mean(:,1),data.G_mean.*data.R_mean./(data.CryoT_mean*12*2.44E-8));view(2)
        set(h,'linestyle','none');colorbar;title('Lorenz Ratio');
        xlabel('Gate Voltage (V)'),ylabel('Bath Temperature (K)');
    end
    
    %save data
    save(fullfile(start_dir, FileName2),'data');
        
end



%turn all value to final "default" values
LA1.sineAmp=EndingVex;
VG.ramp2V(EndingVg);
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
toc