% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.CryoCon22();
TC.connect('12');

% Set the units to K
TC.setUnitsKelvin();

% Initialize variables
file = fopen('C:\Users\qlab\Documents\Graphene Data\3K Fridge T Oscillation\20140505_15K.txt','w');
fprintf(file,'April 5th 2014. PID held at 15K\r\n\r\n');
fprintf(file,'Time\tTemperature\r\n');

% temperature log loop
pause on
pause(5)
t=0;
while true
    temp = TC.temperatureA();
    pause(0.25)
    fprintf(file,'%d\t%G\r\n',[t,temp]);
    pause(0.25);
    t=t+10;
end
