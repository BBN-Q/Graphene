
VGStart=30;
VGEnd=0;
VGStep=1;
VGArray=V_Array(VGStart,VGEnd,VGStep,0);

% VbStartStart=3.2;
% VbStartEnd=3.7;
% VbStartStep=0.05;
% VbStartArray=V_Array(VbStartStart,VbStartEnd,VbStartStep,0);
VbStartArray=[3.70,3.66,3.61,3.54,3.49,3.46,3.43,3.36,3.28,3.20,3.17,3.14,3.08,3.00,2.92,2.86,2.79,2.72,2.62,2.53,2.49,2.41,2.33,2.23,2.16,2.05,1.91,1.75,1.54,1.32,1.08];

FileZero=3494;
KGate=deviceDrivers.Keithley2400();
KGate.connect('24');
pause on
Yoko=deviceDrivers.YokoGS200;
Yoko.connect('2');

for i = 1:length(VGArray)

    KGate.value = VGArray(i);
    
    pause(10)
    Yoko.value=0.44;
    SweepIb4Ic_NIDAQ(1e6,VbStartArray(i)-.5,VbStartArray(i)+.2,.01,.1,0,.2,.03,100,10000,500000,VGArray(i))
    Yoko.value=0.05;
    JJ_Ib_Sweep_NIDAQ(200e-12,VGArray(i),VbStartArray(i),VbStartArray(i)-0.2,.01,.03,50000,60,10,FileZero+(i-1)*21+1);
end

pause off

Yoko.disconnect;
clear Yoko
KGate.disconnect;
clear KGate