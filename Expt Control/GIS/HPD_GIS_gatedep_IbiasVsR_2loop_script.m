%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect Ibias sweeps at different temperatures in a temperature series.
% Intended for 3 K Dry Fridge
% Created in April 2021 by Bevin Huang

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%     CLEAR      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end

if ~exist('FileNumber', 'var') FileNumber = 1; end
if exist('data', 'var')
    clear data;
end

% close all
% fclose all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%     INITIALIZE PATH and Experiment     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IbiasList = 1e-9*linspace(-80, 80, 241); %was at 481
stepVolt=0.01; % V step in volts.
stepTime=1; % Time step in seconds. Volt ramp = stepVolt per stepTime in seconds
%gateList=[-10 -5 -2 0:0.05:3 5 10];
gateList= [-2.2:0.050:-1.7];
LoadResistor = 10e6;
ExcitCurrent = 0.02/LoadResistor;
InitialWaitTime = 7;
measurementWaitTime = 3;

clear keith

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pause on

for i=1:numel(gateList)
    
    %set gate voltage
    disp('Ramping gate voltage...')
    rampkeithley(gateList(i),stepVolt,stepTime);
    disp(['Taking bias-dependent dI/dV measurements at ' num2str(gateList(i)) ' V...'])
    data = DiffIV_vs_IBias(IbiasList*LoadResistor, InitialWaitTime, measurementWaitTime);
    data.Ibias = IbiasList;
    data.LoadResistor = LoadResistor;
    data.ExcitCurrent = ExcitCurrent;
    data.Vgate = gateList;
    data.R = data.X/ExcitCurrent; data.dR = data.Y/ExcitCurrent;
    data.note = ['SD: 14-4, Vxx: 16-5, Gate: ' num2str(gateList(i)) ' V'];
    
    data.identifierNum=strcat('GIS01-K', num2str(FileNumber, '%03i'));
    
    figure(FileNumber)
    plot(data.Ibias.*data.R*1e3, 1e6*1./data.R, '.','markersize',10);
    grid on
    xlabel('V_{bias} (mV)')
    ylabel('dI/dV (\muS)');
    title(strcat(data.identifierNum,'\_',data.note));
    
    % convert temperature to string, replace period with p, append
    % important info onto file name and save
    GateString=num2str(gateList(i));
    dotIndex=find(GateString=='.');
    if ~isempty(dotIndex)
        GateString(dotIndex)='p';
    end
    save(strcat(data.identifierNum, '_GateDep_diffIVvsIBias_Vg=', GateString, 'V_', datestr(clock, 'yyyymmdd_HHMMSS'), '.mat'),'-struct','data');
    
    FileNumber = FileNumber+1;
end

clear IbiasList LoadResistor InitialWaitTime measurementWaitTime Vgate ExcitCurrent;