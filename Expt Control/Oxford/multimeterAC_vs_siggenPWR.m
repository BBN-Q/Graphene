% clear SG mmAC

mmAC = deviceDrivers.Keysight34401A();
mmAC.connect('4');
% 
% mmDC = deviceDrivers.Keysight34401A();
% mmDC.connect('5');

% 
% SG = deviceDrivers.SG382();
% 
%  SG.connect('27');
 
 SG_ampN=-110;
SG_ampBNC=0;
SG_freq=11000000;

SG.ampN=SG_ampN;
SG.ampBNC=SG_ampBNC;
SG.enableBNC='on'; %external reference for RFLA; can be always on
SG.enableN='on'; % RF drive turned on only before RF measurement

figure(999);clf;hold on;
% figure(998);clf;

ACread=[];

DCread=[];


powerArr=-20:1:10;


for i=1:numel(powerArr)
    SG.ampN=powerArr(i);
    pause(0.3);
    ACread(i)=mmAC.value;
    DCread(i)=mmDC.value;
    pause(0.3);
    figure(999);clf;
    plot(powerArr(1:i),ACread,'r');hold on;
%     figure(998);clf;
    plot(powerArr(1:i),DCread);
end

figure(999);clf;
plot(powerArr,ACread,'r');hold on;
    plot(powerArr(1:i),DCread);title('SG-DCBLK-SPLTTR-ATT20dB-PE8010-BLP19-VDC');

figure(998);clf;
plot(powerArr,DCread);

SG.ampN=-110;


    
    
    