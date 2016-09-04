
VGStart=0;
VGEnd=30;
VGStep=1;
VGArray=V_Array(VGStart,VGEnd,VGStep,0);

VbStartArray=[0.95, 1.2, 1.35, 1.55, 1.7, 1.8, 1.85, 1.95, 2.1, 2.15, 2.2, 2.25, 2.35, 2.45, 2.5, 2.6, 2.65, 2.75, 2.8, 2.85, 2.9, 2.95, 3, 3.05, 3.1, 3.15, 3.2, 3.25, 3.3, 3.35, 3.4];      

pause on

for i = 1:length(VGArray)
    KGate=deviceDrivers.Keithley2400();
    KGate.connect('24');
    KGate.value = VGArray(i);
    KGate.disconnect;
    clear KGate;
    pause(10)
    SweepIb4Ic_NIDAQ(1e6,VbStartArray(i),VbStartArray(i)+0.4,0.01,.1,0,.1,.03,1000,10000,500000,VGArray(i));
end

pause off

KGate.disconnect;
clear KGate