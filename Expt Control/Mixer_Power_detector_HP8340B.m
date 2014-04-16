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
clear temp SG SA
%close all
%fclose all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%     INITIALIZE PATH     %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

base_path = 'C:\Users\qlab\Documents\data\Graphene\20140415\';
cd(base_path)
filename = '20140415_Multiplier-Pdetect_1000MHz_1stHarmonic.txt';
data = fopen(filename,'w');
fprintf(data,'%s\r\n\r\n','attn=0dbm resBW=Auto vidBW=Auto visAve=10');
fprintf(data,'%s\t%s\t%s\t%s\r\n','Set F','Set P_dbm','Meas F','Meas P_dbm');
pause on;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%     INITIALIZE  EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pauseTime = 4;

%Connect to Tektronix AFG 3102 Signal Generator
SG = deviceDrivers.HP8340B();
SG.connect('16');
%Connect to Spectrum Analyser HP71000
SA = deviceDrivers.HP71000();
SA.connect('18')


%%%%%%%%%
%run information
startFreq = 2; % in GHz
endFreq = 2; % in GHz
pointsFreq = 1; % number of frequency points taken
logFreq = 0; % take log freq steps? (1=log , 0=Linear)

startAmp = 10; % in Dbm
endAmp = -20; % in Dbm
pointsAmp = 31; % number of voltage steps to take.
logAmp = 0; % take log voltage steps? (1=log , 0=Linear)

freq=0;
amp=0;

tempSet=zeros(1,pointsAmp);
tempMeas=zeros(1,pointsAmp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=0:pointsFreq-1
    
    if pointsFreq==1
        freq=startFreq;
    else
        if logFreq == 1
            freq = startFreq*(endFreq/startFreq)^(i/(pointsFreq-1));
        else
            freq = startFreq+(endFreq-startFreq)*(i/(pointsFreq-1));
        end
    end
    
    SG.frequency = freq/2;
    SA.centerFreq = freq;
    SA.span = (freq/5)*10^9;
    
    
    for j=0:pointsAmp-1
        
        if pointsAmp==1
            amp = startAmp;
        else
            if logAmp == 1
                amp = startAmp*(endAmp/startAmp)^(j/(pointsAmp-1));
            else
                amp = startAmp+(endAmp-startAmp)*(j/(pointsAmp-1));
            end
        end
        
        SG.power = amp;
        pause(pauseTime);
        pause(pauseTime);
        
        measAmp=SA.peakAmplitude;
        
        fprintf(data,'%u\t%u\t%u\t%u\r\n',freq,amp,SA.peakFrequency,measAmp);
        
        tempSet(j+1)=amp;
        tempMeas(j+1)=measAmp;
        
    end
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       PLOT AND SAVE DATA     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);plot(tempSet,tempMeas);grid on;
pause off ;
SG.disconnect();
SA.disconnect();
fclose(data);

