function dBm = totalPower(freq,amp,BW,units)
switch units
    case 'V'
        amp=amp.*amp/50;
        W =sum(amp*(freq(2)-freq(1))/BW);
        dBm=10*log10(W*1000);
    case 'v^2'
        amp=amp/50;
        W =sum(amp*(freq(2)-freq(1))/BW);
        dBm=10*log10(W*1000);
    case 'W'
        W =sum(amp*(freq(2)-freq(1))/BW);
        dBm=10*log10(W*1000);
    case 'dBm'
        for i=1:length(amp)
            amp(i)=10^(amp(i)/10)/1000;
        end
        W =sum(amp*(freq(2)-freq(1))/BW);
        dBm=10*log10(W*1000);
    otherwise
        error('error: choose V, V^2, W, or dBm')    
end
end