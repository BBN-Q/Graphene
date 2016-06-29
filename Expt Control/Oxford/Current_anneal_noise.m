%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cooling log using LakeShore Temperature Controller while taking VNA data
% in Oxford fridge at KimLab
% Created in Mar 2014 by Jesse Crossno and KC Fong and Evan Walsh
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = Current_anneal_noise()

%Internal convenience functions
    function plotR()
        figure(992); clf; xlabel('Current (Amps)');ylabel('Resistance (\Omega)');
        grid on; hold on;
        plot(data.I,data.R,'r')
    end

    function plotJN()
        figure(993); clf; xlabel('Current (Amps)');ylabel('V_noise (V)');
        grid on; hold on;
        plot(data.I,data.JN,'linewidth',3)
    end


%measures the variables
    function measure_data(i)
        data.time(i) = etime(clock, StartTime);
        data.tempVapor(i) = TC.get_temperature('A');
        data.tempProbe(i) = TC.get_temperature('B');
        data.LA_X(i) = LA.X;
        data.LA_Y(i) = LA.Y;
        data.R(i) = sqrt(data.LA_X(i).^2+data.LA_X(i).^2)*Rex/Vex;
        data.I(i) = currentI;
        data.JN(i) = MM.value();
    end

    function saveData()
        save(fullfile(start_dir, FileName),'data');
        lastSave = clock;
    end




%get experiment parameters from user
Rex = 9.79E6; % resistor in series with sample for resistance measurements
finalI = input('Enter final current (A): ');
assert(finalI <1E-1,'final curent set too high');
stepI = input('Enter current step size : ');
assert(stepI<2E-5,'step current value set too high');
pausetime = input('Enter time to hold at max current: ');
waittime = input('Enter wait time at each current: ');
Vex = input('Enter source-drain excitation voltage: ');

UniqueName = input('Enter uniquie file identifier: ','s');
aditional_info = input('Any additional info to include with file? ','s');

% Initialize data structure and filename
start_dir = 'C:\Crossno\data\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('Current_anneal_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');

% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.Lakeshore335();
TC.connect('12');
%Connect lockin amplifier
LA = deviceDrivers.SRS830();
LA.connect('8')
LA.sineAmp = Vex;
%connect to YOKO gate supply
I = deviceDrivers.YokoGS200();
I.connect('20');
%connect to Agilent multimeter
MM = deviceDrivers.Keysight34401A;
MM.connect('5');

data = struct('time',[],'JN',[],'tempVapor',[],'tempProbe',[],'LA_X',[],'LA_Y',[], ...
    'R',[],'I',[],'LA',struct('Vex', Vex,'Rex',Rex,'timeConstant',LA.timeConstant()) ...
    ,'info',aditional_info);


%never go longer than saveTime without saving
saveTime = 60; %in seconds
lastSave = clock;

%initilze data counter
pause on;
%main loop
I_list = 0:stepI:finalI;
len = length(I_list);
I_list = [I_list fliplr(I_list)];
for I_n=1:length(I_list)
    
    %set Vg
    currentI = I_list(I_n);
    I.value = currentI;
    pause(waittime);
    %take "fast" data
    measure_data(I_n);

    %update plots
    plotR();
    plotJN();
    %save every "saveTime" seconds
    if etime(clock, lastSave) > saveTime
        saveData();
    end

    if I_n == len
        startTime=clock;
        while etime(clock,startTime) < pausetime
            measure_data(I_n);
            plotR();
            plotJN();
            pause(waittime);
        end
    end

    saveData()
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       Clear     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TC.disconnect();
LA.disconnect();
MM.disconnect();
clear TC LA VG
end