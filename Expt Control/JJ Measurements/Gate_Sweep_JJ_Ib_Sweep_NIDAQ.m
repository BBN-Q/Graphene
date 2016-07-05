
VGStart=21;
VGEnd=30;
VGStep=1;
VGArray=V_Array(VGStart,VGEnd,VGStep,0);

VbStartStart=3.2;
VbStartEnd=3.7;
VbStartStep=0.05;
VbStartArray=V_Array(VbStartStart,VbStartEnd,VbStartStep,0);

FileStart=1421;


pause on

for i = 1:length(VGArray)
    KGate=deviceDrivers.Keithley2400();
    KGate.connect('24');
    KGate.value = VGArray(i);
    KGate.disconnect;
    clear KGate;
    pause(10)
    JJ_Ib_Sweep_NIDAQ(50e-12,VGArray(i),VbStartArray(i),VbStartArray(i)-0.3,.01,.07,50000,120,10,FileStart+(i-1)*length(VbStartArray)+1);
end

pause off

KGate.disconnect;
clear KGate