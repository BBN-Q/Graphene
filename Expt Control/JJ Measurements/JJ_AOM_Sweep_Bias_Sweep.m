FileStart=2381;

%Connect to RF Source
RFsource=deviceDrivers.AgilentN5183A;
RFsource.connect('19');

RFpower=[-16.22,-13.07,-11.25,-10,-9,-6.08];
LaserPower=[100, 200, 300, 400, 500, 1000]*10^-12;
pause on

for i = 1:length(RFpower)
    RFsource=deviceDrivers.AgilentN5183A;
    RFsource.connect('19');
	RFsource.power=RFpower(i);
    RFsource.disconnect;
    clear RFsource;
    pause(1)
    JJ_Ib_Sweep_NIDAQ(LaserPower(i),20,3.2,2.9,.01,.07,50000,120,10,FileStart+(i-1)*31);
end

pause off