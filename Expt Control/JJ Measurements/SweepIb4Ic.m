function IcfromSweep = SweepIb4Ic(VbResistor, VbStart, VbEnd, VbStep, VbWait, VbReset, ResetWait, Vthresh, VGStart, VGEnd, VGStep, VGWait, NumTrials)
%Sweeps bias current, Ib, of JJ from VbStart/VbResistor to VbEnd/VbResistor
%or until JJ switches with step size of VbStep/VbResistor and wait time 
%VbWait. At end of trial, resets to VbReset with wait time ResetWait. 
%Repeats this process NumTrials times at each gate voltage between
%VGStart and VGEnd with step size VGStep and wait time VGWait. Plots
%distribution of number of switches at a given bias current.

StartTime = clock;

% Connect to Instruments
KGate=deviceDrivers.Keithley2400();
KGate.connect('24');
KMeas=deviceDrivers.Keithley2400();
KMeas.connect('23');
Lockin=deviceDrivers.SRS865;
Lockin.connect('9');

[Vb_Array, JJSteps]=V_Array(VbStart,VbEnd,VbStep,0);
[VG_Array, GateSteps]=V_Array(VGStart,VGEnd,VGStep,0);

IcfromSweep=struct('JJCurr_Array', Vb_Array/VbResistor, 'VG_Array', VG_Array, 'IbWait', VbWait);

FileName = strcat('Sweep4Ic_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
figure; pause on;
IcfromSweep.IcCount=zeros(GateSteps,JJSteps);
for i = 1:GateSteps
    KGate.value = VG_Array(i);
    pause(VGWait);
    for j = 1:NumTrials
        k=1;
        Lockin.DC = VbReset;
        pause(ResetWait)
        Lockin.DC = VbStart;
        JJ_V = KMeas.value();
        while JJ_V<Vthresh && k<JJSteps
            k=k+1;
            Lockin.DC = Vb_Array(k);
            pause(VbWait);
            JJ_V = KMeas.value();
            if JJ_V>Vthresh
                IcfromSweep.IcCount(i,k)=IcfromSweep.IcCount(i,k)+1;
            end
        end
        clf; plot(IcfromSweep.JJCurr_Array/10^-6, IcfromSweep.IcCount(i,:),'o'); grid on; xlabel('Critical Current (\muA)'); ylabel('Number'); title(strcat('Critical Current Distribution ', datestr(StartTime)));
    end

    save(FileName,'IcfromSweep')

end


pause off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
KMeas.disconnect();
Lockin.disconnect();
KGate.disconnect();
clear SetVolt;
clear KMeas;
clear KGate;
clear Lockin;

end

