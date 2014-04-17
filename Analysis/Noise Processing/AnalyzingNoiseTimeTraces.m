% Analyzing the Noise Time Traces
% 1. low pass by a 2nd order butterworth filter at a specific cutoff
% frequency
% 2. compute the standard deviation of the noise; the standard deviation is
% proportional to the graphene electron temperature
% 3. repeating procedures 1 and 2 for different cutoff frequency

% alright, let's try to get the analyze all the time traces in the working
% directory without any filtering!
clear BandWidth VrmsArray deltaVrms;
BandWidth(1) = 1
for k=1:length(T_K)
    MM = importdata(DataFileList(k,:));
    NoisePowerOneTrace(1, k) = var(MM);   % NoisePower is proportional to graphene electron temperature
end
GroupedNoisePowerOneTrace = reshape(NoisePowerOneTrace, 100, 20);   % 20 is the number of data pts for a particular tau value in Dicke
AverageNoisePower(1) = mean(NoisePowerOneTrace(1,:));
DeltaNoisePower(1) = std(mean(GroupedNoisePowerOneTrace));

% good now. let's do the sample after filtering
for j=2:40
    j
    BandWidth(j) = 10^(-1*(j-1)/9);
    [b,a] = butter(2, BandWidth(j),'low');  % Create a's and b's IIR coefficients
    for k=1:length(T_K)
        MM = importdata(DataFileList(k,:));
        NoisePowerOneTrace(j, k) = var(filter(b, a, MM));
    end
    GroupedNoisePowerOneTrace = reshape(NoisePowerOneTrace(j,:), 100, 20);   % 20 is the number of data pts for a particular tau value in Dicke
    AverageNoisePower(j) = mean(NoisePowerOneTrace(j,:));
    DeltaNoisePower(j) = std(mean(GroupedNoisePowerOneTrace));
end
clear GroupedNoisePowerOneTrace;

SamplingFreq = 100;     % unit in MHz
BandWidth = 2*1.11*BandWidth*(0.5*SamplingFreq);   % Calculating the final noise equivalent bandwidth; Factor of 2 due to double side band; 1.11 due to 2nd order butterworth filter

dPoverP = DeltaNoisePower./AverageNoisePower;
figure; loglog(BandWidth, dPoverP, 'd');
dPoverP = dPoverP';
BandWidth = BandWidth';
save('dPoverP.dat', 'dPoverP', '-ASCII', '-tabs')
save('BandWidth.dat', 'BandWidth', '-ASCII', '-tabs')

clear MM;