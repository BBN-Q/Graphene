clear SG mmDC

mmDC = deviceDrivers.Keysight34401A();
mmDC.connect('5');

SG = deviceDrivers.SG382();

 SG.connect('27');
 
 SG_ampN=-110;
SG_ampBNC=0;
SG_freq=11000000;

SG.ampN=SG_ampN;
SG.ampBNC=SG_ampBNC;
SG.enableBNC='off'; %external reference for RFLA; can be always on
SG.enableN='on'; % RF drive turned on only before RF measurement

figure(999);clf;

DCread=[];

powerArr=-110:2:10;


for i=1:numel(powerArr)
    SG.ampN=powerArr(i);
    pause(0.5);
    DCread(i)=mmDC.value;
    pause(0.5);
    figure(999);clf;
    plot(powerArr(1:i),DCread,'r');
end

figure(999);clf;
plot(powerArr,DCread,'r');

    
    
    