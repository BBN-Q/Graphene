%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measurement to test out the Johnson noise measurement and system noise
% temperature by comparing a resistive load at room temperature (297 K) and
% 77 K (dip test in LN)
% Created in April 2014 by Jesse Crossno and KC Fong
%
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

base_path = 'C:\Users\qlab\Documents\data\Graphene\TwoPts XCorrelation Test\';
cd(base_path)
% addpath([ base_path,'data'],'-END');
addpath([ base_path],'-END');
filename = 'Testing.dat';
%FilePtr = fopen(filename,'w');
% pause on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%     INITIALIZE  EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SA = deviceDrivers.HP71000();
SA.connect('18');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     Parameters and Info      %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AnalysisBW_MHz = [200 400];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure; j=0;
while input('Get the Johnson noise PSD now? (y/n) ', 's') == 'y'
    j = j+1;
    T_K(j) = input('What is the temperature? ');
    [Freq_MHz, rtPSD_V]=SA.downloadTrace();
    Freq_MHz = Freq_MHz/1e6;
    PSD_V2(j, :) = rtPSD_V.^2;
    hold on; semilogy(Freq_MHz, PSD_V2(j,:)); grid on;
end
xlabel('Frequency (MHz)'); ylabel('PSD (V^2)'); title('PSD of a 50\Omega terminator');
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%       PLOT AND SAVE DATA     %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure; semilogy(Freq_MHz, PSD_V2(1,:), 'r', Freq_MHz, PSD_V2(2,:), 'g'); grid on;

[minValue, lowerIndex] = min(abs(Freq_MHz-AnalysisBW_MHz(1))); [minValue, upperIndex] = min(abs(Freq_MHz-AnalysisBW_MHz(2)));
JohnsonData(1,:) = T_K;
for j=1:length(T_K)
    JohnsonData(2, j) = mean(PSD_V2(j, lowerIndex:upperIndex));
end
figure; plot(JohnsonData(1,:), JohnsonData(2,:), 'd'); grid on; 
xlim([-200 300]); ylim([0 1.1*max(JohnsonData(2,:))]); xlabel('Temperature (K)'); ylabel('PSD (V^2)'); title('Noise temperature by two points measurement');

% pause off ;
SA.disconnect();
if input('Save to matlab.mat? (y/n) ','s') == 'y'
    save
end
%fclose(FilePtr); 