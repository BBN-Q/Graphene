function IcfromSweep = SweepIb4Ic_NIDAQ_SRS865scan(VbResistor, VbStart, VbEnd, scanInterval, scanTime, VbReset, ResetWait, Vthresh, NumTrials, sampling_rate, VG)
%Sweeps bias current, Ib, of JJ from VbStart/VbResistor to VbEnd/VbResistor
%in time scanTime with time scanInterval between steps. At end of trial, 
%resets to VbReset with wait time ResetWait. Repeats this process 
%NumTrials times. VG is a passive input. Plots distribution of number of 
%switches at a given bias current.

StartTime = clock;

% Connect to Instruments
Lockin=deviceDrivers.SRS865;
Lockin.connect('9');

% FileName for Saving
FileName = strcat('Sweep4Ic_VG_',num2str(VG),'_', datestr(StartTime, 'yyyymmdd_HHMMSS'), '.mat');
figure; pause on;

bufferTime=.01; %Allow bufferTime seconds for scan to start and end
num_points_mat=round(sampling_rate*(scanTime+bufferTime))+1; %Number of points to take per channel
time=0:1/sampling_rate:scanTime+bufferTime;
% Convert NIDAQ parameters to python objects for python wrapper
num_points=py.int(num_points_mat);
sampling_rate=py.int(sampling_rate);

%Setup Scan
Lockin.scanDC_set;
Lockin.scanDC_start=VbStart;
Lockin.scanDC_end=VbEnd;
Lockin.scanInterval=scanInterval;
scanInterval=Lockin.scanInterval; %reset scanInterval to be actual value from Lockin
Lockin.scanTime=scanTime;
Lockin.scanMode=0;

%Setup Current Bins
VbSteps=ceil(scanTime/scanInterval)+1;
VbStep=(VbStart-VbEnd)/VbSteps;
VbArray=V_Array(VbStart,VbEnd,VbStep,0);

% Setup output structure
IcfromSweep=struct('JJCurr_Array', VbArray/VbResistor,'IcCount',zeros(VbSteps+1,1),'IcAvg',[],'IcStd',[], 'NumTrials', NumTrials, 'scanTime', scanTime, 'scanInterval', scanInterval, 'VG', VG);

%Set DC Voltage to VbReset when scan is disabled
Lockin.DC = VbReset;

    for j = 1:NumTrials
        tic;
        %Reset JJ
        Lockin.scanDisable;
        pause(ResetWait)
        
        %Set Ib on JJ to beginning value
        Lockin.scanEnable;
        
        %Begin Data Acquisition with NIDAQ
        taskHandle=py.NIDAQai0ai1.NIDAQai0ai1(num_points,sampling_rate);
        
        %Begin Ib Sweep
        Lockin.scanRun;
        
        %Get Data from NIDAQ
        pydata=py.NIDAQai0ai1.getData(taskHandle,num_points);
        py.NIDAQai0ai1.killTask(taskHandle);
        
        matdata = double(py.array.array('d',py.numpy.nditer(pydata)));

        JJ_V = matdata(1:num_points_mat);
        JJ_Ib = matdata(num_points_mat+1:end)/VbResistor;
        
        %Find JJ switching event
        switched = find(JJ_V>Vthresh,1);
        if ~isempty(switched) %Check that JJ switched
            IbSwitch=JJ_Ib(switched); %Find current corrsponding to switch
            [~, idx] = min(abs(IcfromSweep.JJCurr_Array-IbSwitch)); %Find bin to place count into
            IcfromSweep.IcCount(idx)=IcfromSweep.IcCount(idx)+1; %Place count into bin
        end
        
        clf;
        subplot(3,1,1);
        plot(time,JJ_V); grid on; xlabel('Time(s)'); ylabel('V_{JJ} (V)');
        subplot(3,1,2);
        plot(time,JJ_Ib); grid on; xlabel('Time(s)'); ylabel('Ib (\muA)');
        subplot(3,1,3);
        plot(IcfromSweep.JJCurr_Array/10^-6, IcfromSweep.IcCount,'o'); grid on; xlabel('Critical Current (\muA)'); ylabel('Number'); title(strcat('Critical Current Distribution ', datestr(StartTime)));
        toc
    end
    IcStats=StatsFromBinnedData(IcfromSweep.JJCurr_Array,IcfromSweep.IcCount);
    IcfromSweep.IcAvg=IcStats.mean;
    IcfromSweep.IcStd=IcStats.std;
    save(FileName,'IcfromSweep')

pause off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Lockin.disconnect();
clear Lockin;

end