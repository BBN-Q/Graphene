%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% PID Tuner %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PID_Tuner
TC = deviceDrivers.CryoCon22();
TC.connect('12');
pStart=25;
pEnd=50;
pDelta=5;

pause on
figure;hold all;
for i=0:(pEnd-pStart)/pDelta
    p=pStart+i*pDelta
    TC.pGain=p;
    pause(60)
    data=zeros(120,2);
    time=0;
    for j=1:600
        temp=TC.temperatureA();
        data(j,1)=time;
        data(j,2)=temp;
        pause(0.1)
        time=time+0.1;
    end
    plot(data(:,1),data(:,2));
end
        
    
