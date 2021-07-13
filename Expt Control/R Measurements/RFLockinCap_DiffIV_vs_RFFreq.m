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

function [data] = RFLockinCap_DiffIV_vs_RFFreq(RFFreq, InitialWaitTime, measurementWaitTime)
pause on;
RFSource = deviceDrivers.AgilentN5183A();
RFSource.connect('19');
RFLockin1 = gpib('ni',0,15)
RFLockin1.InputBufferSize = 10000;
RFLockin1.Timeout = 20;
fopen(RFLockin1)
RFLockin2 = gpib('ni',0,20)
RFLockin2.InputBufferSize = 10000;
RFLockin2.Timeout = 20;
fopen(RFLockin2)
gv = gpib('ni',0,4)
gv.InputBufferSize = 20000;
gv.Timeout = 60;
fopen(gv)
gi = gpib('ni',0,9)
gi.InputBufferSize = 20000;
gi.Timeout = 60;
fopen(gi)

% initializing SR844 for data storage
fprintf(RFLockin1,'SRAT14'); fprintf(RFLockin1,'SEND0');
fprintf(RFLockin2,'SRAT14'); fprintf(RFLockin2,'SEND0');

% initializing the capture parameters
fprintf(gv,'CAPTURERATEMAX?'); CapFreqMax = str2num(fscanf(gv));
fprintf(gi,'CAPTURERATEMAX?'); assert(str2num(fscanf(gi)) == CapFreqMax)
LockinBufferLength_kByte = 8;
%fprintf(gv,'CAPTURELEN?'); LockinBufferLength_kByte = str2num(fscanf(gv));
cmd = sprintf('CAPTURELEN %d', LockinBufferLength_kByte);
fprintf(gv, cmd); fprintf(gi, cmd);
fprintf(gv,'CAPTURERATE?'); CapFreq = str2num(fscanf(gv));
cmd = sprintf('CAPTURERATE %d', round(log(CapFreqMax/CapFreq)/log(2)));
fprintf(gi, cmd);
fprintf(gv, 'CAPTURECFG 1');
fprintf(gi, 'CAPTURECFG 1');
TotalTime = 1024*LockinBufferLength_kByte/8/CapFreq;
disp(['Total time (s) = ', num2str(TotalTime)])

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(345); clf; plot(smoothdata(dataV(1,:)./dataI(1,:), 'movmean', 4)); grid on;
    figure(456); clf; subplot(2, 1, 1); 
    plot(dataV(1,:)); plot(dataV(2,:)); grid on; ylabel('Lockin V (V)')
    subplot(2, 1, 2); 
    plot(1e9*dataI(1,:)); plot(1e9*dataI(2,:)); grid on; ylabel('Lockin I (nA)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
RFSource.frequency = RFFreq(1)*1e-9;
pause(InitialWaitTime);
for k=1:length(RFFreq)
    RFSource.frequency = RFFreq(k)*1e-9;
    RFSource.output = sign(k-1);
    fprintf(RFLockin1,'REST'); fprintf(RFLockin1,'STRT');
    fprintf(RFLockin2,'REST'); fprintf(RFLockin2,'STRT');
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
    StartTime = clock;
    disp(['Start taking data now : ', datestr(StartTime), ' at RFFreq (MHz) = ', num2str(RFFreq(k)*1e-6)])
    while(iFlag == 3)
        pause(5)
        fprintf(gv,'CAPTURESTAT?'); iFlag = str2num(fscanf(gv));
        %disp(['Taken (mins.): ', num2str(etime(clock, StartTime)/60)])
    end
    pause(1);
    fprintf(gi,'CAPTURESTAT?'); assert(str2num(fscanf(gi))==6);
    disp([datestr(clock), ' : Taking data completed at RF Freq (MHz) = ', num2str(1e-6*RFFreq(k)), 'and taken (mins.)', num2str(etime(clock, StartTime)/60)])

    % download DC Lockin data
    clear dataV dataI
    cmd = sprintf('CAPTUREGET? 0,%d', LockinBufferLength_kByte);
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
    
    % download RF Lockin data
    clear OneSection RF2X RF2Y RF1X RF1Y;
    for j = 1:32
        cmd = sprintf('TRCB?1,%d,%d',32*(j-1), 32);
        fprintf(RFLockin2, cmd);
        OneSection = fread(RFLockin2, 32, 'float32');
        data.RF2X(k,32*(j-1)+1:32*(j)) = OneSection;
        cmd = sprintf('TRCB?2,%d,%d',32*(j-1), 32);
        fprintf(RFLockin2, cmd);
        OneSection = fread(RFLockin2, 32, 'float32');
        data.RF2Y(k,32*(j-1)+1:32*(j)) = OneSection;

        cmd = sprintf('TRCB?1,%d,%d',32*(j-1), 32);
        fprintf(RFLockin1, cmd);
        OneSection = fread(RFLockin1, 32, 'float32');
        data.RF1X(k,32*(j-1)+1:32*(j)) = OneSection;
        cmd = sprintf('TRCB?2,%d,%d',32*(j-1), 32);
        fprintf(RFLockin1, cmd);
        OneSection = fread(RFLockin1, 32, 'float32');
        data.RF1Y(k,32*(j-1)+1:32*(j)) = OneSection;
    end
    clear OneSection cmd
    %save('backup.mat')
end

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%Keithley.value = 0;
RFSource.disconnect();
pause off;
fclose(gv); fclose(gi);
fclose(RFLockin1); fclose(RFLockin2);
end