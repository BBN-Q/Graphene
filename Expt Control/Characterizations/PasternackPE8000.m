   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%     CLEAR      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
temp = instrfind;
if ~isempty(temp)
    fclose(temp)
    delete(temp)
end
% clear temp sigGen spec
% close all
% fclose all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%     INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

base_path = 'C:\Users\qlab\Documents\data\Graphene data\PE8000 Characterization\';
cd(base_path)
% addpath([ base_path,'data'],'-END');
filename = 'PasternackPE8000_500MHz_v1.txt';
data = fopen(filename,'w');
pause on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%     INITIALIZE  EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pauseTime = 1;

% Connect to instruments
sigGen = deviceDrivers.AgilentN5183A();
sigGen.connect('128.33.89.196');
DVM = deviceDrivers.Keithley197();
DVM.connect('16')
%%%%%%%%%
%run information
startPower = -20; % in dBm
endPower = 20; % in dBm
PowerArray = startPower:1:endPower;
pauseTime = 2;
attn = 30;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SigGenPower = startPower;
for j=1:length(PowerArray)
    sigGen.power = PowerArray(j);
    pause(pauseTime);
    Result = DVM.get();
    PowerArray_W(j) = 0.001*10^((PowerArray(j)-attn)*0.1);
    Vdiode(j) = str2num(Result.value);
    fprintf(data,'%d %e %e \r\n', PowerArray(j)-40, PowerArray_W(j), Vdiode(j));
end
sigGen.power = -20;
figure; plot(PowerArray_W, Vdiode, 'd'); grid on;
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       PLOT AND SAVE DATA     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pause off ;
sigGen.disconnect();
DVM.disconnect();
fclose(data);


