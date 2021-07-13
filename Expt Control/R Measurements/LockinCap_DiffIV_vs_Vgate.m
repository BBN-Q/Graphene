%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = LockinCap_DiffIV_vs_Vgate(VgateList, InitialWaitTime, measurementWaitTime)
pause on;
GateController = deviceDrivers.Keithley2400();
GateController.connect('23');
%Yoko = deviceDrivers.YokoGS200();
%Yoko.connect('2');
% Lockin2 = deviceDrivers.SRS830();
% Lockin2.connect('15');
% setup
gv = gpib('ni',0,4)
gv.InputBufferSize = 20000;
gv.Timeout = 60;
fopen(gv)
gi = gpib('ni',0,9)
gi.InputBufferSize = 20000;
gi.Timeout = 60;
fopen(gi)

% initializing the capture parameters
fprintf(gv,'CAPTURERATEMAX?'); CapFreqMax = str2num(fscanf(gv));
fprintf(gi,'CAPTURERATEMAX?'); assert(str2num(fscanf(gi)) == CapFreqMax)
LockinBufferLength_kByte = 8;
%fprintf(gv,'CAPTURELEN?'); LockinBufferLen gth_kByte = str2num(fscanf(gv));
cmd = sprintf('CAPTURELEN %d', LockinBufferLength_kByte);
fprintf(gv, cmd); fprintf(gi, cmd);
fprintf(gv,'CAPTURERATE 8');
fprintf(gi,'CAPTURERATE 8');
fprintf(gv,'CAPTURERATE?'); CapFreq = str2num(fscanf(gv));
cmd = sprintf('CAPTURERATE %d', round(log(CapFreqMax/CapFreq)/log(2)));
fprintf(gi, cmd);
fprintf(gv, 'CAPTURECFG 1');
fprintf(gi, 'CAPTURECFG 1');
TotalTime = 1e3*LockinBufferLength_kByte/8/CapFreq;
disp(['Total time (s) = ', num2str(TotalTime)])

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(345); clf; plot(smoothdata(dataV(1,:)./dataI(1,:), 'movmean', 4)); grid on;
    figure(456); clf; subplot(2, 1, 1); 
    plot(dataV(1,:)); %hold on; plot(dataV(2,:)); 
    grid on; ylabel('Lockin V (V)')
    subplot(2, 1, 2); 
    plot(1e9*dataI(1,:)); %hold on; plot(1e9*dataI(2,:)); 
    grid on; ylabel('Lockin I (nA)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
GateController.value = VgateList(1);
pause(InitialWaitTime);
for k=1:length(VgateList)
    GateController.value = VgateList(k);
    pause(measurementWaitTime);

    % start running
    fprintf(gv,'CAPTURESTART 0,1');
    fprintf(gi,'CAPTURESTART 0,1');
    fprintf(gv,'CAPTURESTAT?');
    assert( str2num(fscanf(gv)) == 0)
    fprintf(gi,'CAPTURESTAT?');
    assert( str2num(fscanf(gi)) == 0)
    pause on;
    TrigCtrl = deviceDrivers.Agilent33220A();
    TrigCtrl.connect('6')
    TrigCtrl.output = 1;
    pause(1);
    TrigCtrl.output = 0;
    TrigCtrl.disconnect();
    clear TrigCtrl
    fprintf(gv,'CAPTURESTAT?');
    assert( str2num(fscanf(gv)) == 3)
    fprintf(gi,'CAPTURESTAT?');
    assert( str2num(fscanf(gi)) == 3)

    fprintf(gv,'CAPTURESTAT?'); iFlag = str2num(fscanf(gv));
    disp(['Start taking data now.'])
    while(iFlag == 3)
        pause(10)
        fprintf(gv,'CAPTURESTAT?'); iFlag = str2num(fscanf(gv));
        %disp(['Taking data now at Vgate(V) = ', num2str(VgateList(k))])
    end
    pause(1);
    fprintf(gi,'CAPTURESTAT?'); assert(str2num(fscanf(gi))==6);
    disp(['Taking data completed at Vgate(V) = ', num2str(VgateList(k))])

    % download DC Lockin data
    clear dataV dataI
    cmd = sprintf('CAPTUREGET? 0,%d', LockinBufferLength_kByte)
    fprintf(gv, cmd);
    dataV = binblockread(gv, 'float32');
    dataV = reshape(dataV, 2, length(dataV)/2);
    fprintf(gi, cmd);
    dataI = binblockread(gi, 'float32');
    dataI = reshape(dataI, 2, length(dataI)/2);    
    
    data.X(k,:) = dataV(1,:);
    data.Y(k,:) = dataV(2,:);
    data.IX(k,:) = dataI(1,:);
    data.IY(k,:) = dataI(2,:);
    plot_data()
    
    save('backup.mat')
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = 0;
GateController.disconnect();
pause off; clear Lockin GateController;
fclose(gv)
fclose(gi)
end