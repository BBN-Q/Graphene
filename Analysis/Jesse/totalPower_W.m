function [dBm,W]= totalPower_W(freq,amp,BW)
W =sum(amp*(freq(2)-freq(1))/BW);
dBm=10*log10(W*1000);
end