%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = NIDAQ_dcIV_vs_IBiasSweep1(TotalTime, SamplingFreq, InitialWaitTime)
pause on;
%SweepGen = deviceDrivers.TekAFG3102();
%SweepGen.connect('11');
%Lockin = deviceDrivers.SRS865();
%Lockin.connect('4');
NiDaq = daq.createSession('ni');
addAnalogInputChannel(NiDaq,'Dev1', 0, 'Voltage');
addAnalogInputChannel(NiDaq,'Dev1', 1, 'Voltage');
addTriggerConnection(NiDaq,'external','Dev1/PFI0','StartTrigger');
NiDaq.Rate = SamplingFreq;
NiDaq.NumberOfScans = floor(TotalTime*SamplingFreq)+1;

%%%%%%%%%%%%%%%%%%%%%       PLOT DATA     %%%%%%%%%%%%%%%%%%%%%%%%
function plot_data()
    figure(799); clf; plot(data.time, data.dcV, '.-'); grid on;
    xlabel('time (s)'); ylabel('Amplified dc V_{JJ} (V)');
end

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%SweepGen.high1 = BiasRange(2); SweepGen.low1 = BiasRange(1);
%SweepGen.frequency1 = SweepFreq;
pause(InitialWaitTime);
[voltage1, time] = NiDaq.startForeground;
data.dcV = voltage1'; data.time = time';
%data.Vbias = linspace(BiasRange(2), BiasRange(1), length(data.dcV));
%plot_data();

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%

% removeConnection(NiDaq, 1); removeChannel(NiDaq, 1); 
%SweepGen.disconnect(); %Lockin.disconnect();
removeConnection(NiDaq,1); removeChannel(NiDaq,2); removeChannel(NiDaq,1);
pause off; clear voltage1 time Lockin SweepGen NiDaq;
end