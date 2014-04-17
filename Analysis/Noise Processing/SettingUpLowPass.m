% normalized frequency = 0.5*sampling frequency = Nyquist frequency (\pi
% radian per sample in Matlab
[z,p,k] = butter(2,0.5,'low');  % Create zeros and poles and gain of a 2nd order low pass butterworth filter with cutoff frequency at 0.5*normalized frequency
[b,a] = butter(2,0.5,'low');  % Create a's and b's IIR coefficients
[sos,g] = zp2sos(z,p,k);	     % Convert to SOS form
Hd = dfilt.df2tsos(sos,g);   % Create a dfilt object
h = fvtool(Hd);	             % Plot magnitude response
set(h,'Analysis','freq')	     % Display frequency response 