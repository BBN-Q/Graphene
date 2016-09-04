MMDC = deviceDrivers.Keysight34401A();
MMDC.connect('5');
TC = deviceDrivers.Lakeshore335();
TC.connect('12');



figure(677);clf;
vals=[];
temps=[];
while 1
   vals = [vals MMDC.value];
   pause(1);
   temps = [temps TC.temperatureB];
   pause(1);
   figure(676);clf;
   plot(temps,vals);
end