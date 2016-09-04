function IcfromSweep = SweepIb4Ic_NIDAQ(VbResistor, VbStart, VbEnd, VbStep, VbWait, VbReset, ResetWait, Vthresh, NumTrials, num_points, sampling_rate, VG)
%Sweeps bias current, Ib, of JJ from VbStart/VbResistor to VbEnd/VbResistor
%or until JJ switches with step size of VbStep/VbResistor and wait time 
%VbWait. At end of trial, resets to VbReset with wait time ResetWait. 
%Repeats this process NumTrials times at each gate voltage between
%VGStart and VGEnd with step size VGStep and wait time VGWait. Plots
%distribution of number of switches at a given bias current.

StartTime = clock;

% Connect to Instruments
Lockin=deviceDrivers.SRS865;
Lockin.connect('9');

% Setup Voltage Bias Array
[Vb_Array, JJSteps]=V_Array(VbStart,VbEnd,VbStep,0);

% Setup output structure
IcfromSweep=struct('JJCurr_Array', Vb_Array/VbResistor, 'VG', VG, 'IbWait', VbWait,'IcCount',zeros(JJSteps,1),'IcAvg',[]);

% FileName for Saving
FileName = strcat('Sweep4Ic_VG_',num2str(VG),'_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
figure; pause on;

% Convert NIDAQ paramters to python objects for python wrapper
num_points=py.int(num_points);
sampling_rate=py.int(sampling_rate);

    for j = 1:NumTrials
        k=1;
        %Reset JJ
        Lockin.DC = VbReset;
        pause(ResetWait)
        % Sweep Ib on JJ until switching or until VbEnd
        Lockin.DC = VbStart;
        pause(ResetWait)
        pydata=py.take_data.take_data(num_points,sampling_rate);
        JJ_V = mean(double(py.array.array('d',py.numpy.nditer(pydata))));
        while JJ_V<Vthresh && k<JJSteps
            k=k+1;
            Lockin.DC = Vb_Array(k);
            pause(VbWait);
            pydata=py.take_data.take_data(num_points,sampling_rate);
            JJ_V = mean(double(py.array.array('d',py.numpy.nditer(pydata))));
            if JJ_V>Vthresh
                IcfromSweep.IcCount(k)=IcfromSweep.IcCount(k)+1;
            end
        end
        clf; plot(IcfromSweep.JJCurr_Array/10^-6, IcfromSweep.IcCount,'o'); grid on; xlabel('Critical Current (\muA)'); ylabel('Number'); title(strcat('Critical Current Distribution ', datestr(StartTime)));
    end
    IcfromSweep.IcAvg=sum(IcfromSweep.JJCurr_Array.*IcfromSweep.IcCount)/sum(IcfromSweep.IcCount);
    save(FileName,'IcfromSweep')

pause off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Lockin.disconnect();
clear SetVolt;
clear Lockin;

end

