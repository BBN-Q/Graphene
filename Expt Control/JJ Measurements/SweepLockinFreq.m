Lockin=deviceDrivers.SRS865;
Lockin.connect('9');


figure
pause on;
freq=100:100:20000;
for i=1:length(freq)
    Lockin.sineFreq=freq(i);
    pause(1);
    [data.X(i),data.Y(i)]=Lockin.get_XY();
    [data.R(i),data.TH(i)]=Lockin.get_Rtheta();
    clf; plot(freq(1:i),data.R(1:i));grid on; xlabel('Freq (Hz)'); ylabel('Voltage (V)');
end
pause off;
Lockin.disconnect;
clear Lockin