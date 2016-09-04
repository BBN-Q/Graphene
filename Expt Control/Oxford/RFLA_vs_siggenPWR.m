clear SG mmAC mmDC RFLA
% 
% mmAC = deviceDrivers.Keysight34401A();
% mmAC.connect('4');
% 
% mmDC = deviceDrivers.Keysight34401A();
% mmDC.connect('5');

RFLA = deviceDrivers.SRS844();
RFLA.connect('11');

SG = deviceDrivers.SG382();
SG.connect('27');
 
 SG_ampN=-110;
SG_ampBNC=0;
SG_freq=11000000;

SG.ampN=SG_ampN;
SG.ampBNC=SG_ampBNC;
SG.enableBNC='on'; %external reference for RFLA; can be always on
SG.enableN='on'; % RF drive turned on only before RF measurement

figure(999);clf;
figure(998);clf;
% 
% ACread=[];
% 
% DCread=[];

RFLAread=[];

powerArr=-110:1:-10;

pause on;

for i=1:numel(powerArr)
    SG.ampN=powerArr(i);
    pause(0.5);
%     ACread(i)=mmAC.value;
%     DCread(i)=mmDC.value;
    [RFLAread(i,1) RFLAread(i,2)]=RFLA.snapRtheta();    
    pause(0.5);
    figure(997);clf;
    subplot(1,2,1);
    plot(powerArr(1:i),RFLAread(:,1));
    subplot(1,2,2);
    plot(powerArr(1:i),RFLAread(:,2));
%     figure(999);clf;
%     plot(powerArr(1:i),ACread);
%     figure(998);clf;
%     plot(powerArr(1:i),DCread);
end
% 
% figure(999);clf;
% plot(powerArr,ACread);
% 
% figure(998);clf;
% plot(powerArr,DCread);

   figure(997);clf;
    subplot(1,2,1);
    plot(powerArr,RFLAread(:,1));
    subplot(1,2,2);
    plot(powerArr,RFLAread(:,2));

SG.ampN=-110;


    
    
    