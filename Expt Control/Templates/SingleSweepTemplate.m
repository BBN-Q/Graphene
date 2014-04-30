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

base_path = 'C:\Documents and Settings\qlab\My Documents\data\Graphene\';
cd(base_path)
% addpath([ base_path,'data'],'-END');
filename = '20140327_mixer_2f_power.txt';
data = fopen(filename,'w');
pause on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%     INITIALIZE  EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pauseTime = 8;

%Connect to Tektronix AFG 3102 Signal Generator
sigGen = deviceDrivers.TekAFG3102();
sigGen.connect('11');
%Connect to Spectrum Analyser HP71000
spec = deviceDrivers.HP71000();
spec.connect('18')
spec.centerFreq = 0.02; %in GHz
spec.span = 30000000;   %in Hz

%%%%%%%%%
%run information
startFreq = 10000000; % in Hz
endFreq = 10000000; % in Hz
stepsFreq = 1; % number of frequency points taken

startAmp = 1; % in Vrms
endAmp = 0.01; % in Vrms
stepsAmp = 100; % number of voltage steps to take. Must be > 1
logSteps = 1; % take log voltage steps? (1=log , 0=Linear)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if stepsFreq == 1 
    freq = startFreq;
    sigGen.frequency = freq;
       for j=58:stepsAmp
 
            if logSteps == 1
                amp = exp(log(startAmp)+(j)*(log(endAmp)-log(startAmp))/(stepsAmp));
                pause(pauseTime);
                sigGen.rmsAmp = amp;
            else
               amp = startAmp+(j)*(endAmp-startAmp)/(stepsAmp);
                pause(pauseTime);
                sigGen.rmsAmp = amp;
            end
            pause(pauseTime);
            fprintf(data,'%u %u %u %u\r\n',freq,amp,spec.peakAmplitude,spec.peakFrequency);
            j
       end
else
    for i=0:stepsFreq

        freq = startFreq+(i)*(endFreq-startFreq)/(stepsFreq);

        pause(pauseTime);
        sigGen.frequency = freq;
        for j=1:stepsAmp

            if logSteps == 1
                amp = exp(log(startAmp)+(j)*(log(endAmp)-log(startAmp))/(stepsAmp));
                pause(pauseTime);
                sigGen.rmsAmp = amp;
            else
                amp = startAmp+(j)*(endAmp-startAmp)/(stepsAmp);
                pause(pauseTime);
                sigGen.rmsAmp = amp;
            end
            pause(pauseTime);
            fprintf(data,'%u %u %u %u\r\n',freq,amp,spec.peakAmplitude,spec.peakFrequency);
            j
        end
    end
end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       PLOT AND SAVE DATA     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pause off ;
sigGen.disconnect();
spec.disconnect();
fclose(data);


