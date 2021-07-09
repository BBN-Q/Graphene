function rampkeithley(Vfinal,Vint,waittime)
% ramps keithley voltage output up or down in a given interval, and plots
% measured current; designed for changing gate voltage and measuring
% leakage current in graphene devices.
%   by Caleb Fried (cfried@college.harvard.edu) 5/10/2021

keith = deviceDrivers.Keithley2400();
if keith.isConnected == 0
keith.connect('23');
end

str = keith.query('MEAS:VOLT?');
num = str2num(str);
Vstart = num(1);

if Vstart - Vfinal < 0
    a = 1;
else
    a = -1;
end

pause('on')
Vlist=Vstart:(a*Vint):Vfinal;
leakcurr = zeros(1,length(Vstart:Vint:Vfinal));
for i = 1:length(Vlist)
    keith.value = (Vlist(i));
    pause(waittime);
    str = keith.query('MEAS:CURR?');
    num = str2num(str);
    leakcurr(i) = num(2);
    figure(511);
    plot(Vlist(1:i),leakcurr(1:i));
    xlabel('gate voltage');
    ylabel('leakage current');
end
pause(waittime);
keith.value = Vfinal;
pause(0.5)

keith.disconnect
end

