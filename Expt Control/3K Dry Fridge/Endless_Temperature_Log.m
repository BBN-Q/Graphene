% Connect to the Cryo-Con 22 temperature controler
TC = deviceDrivers.CryoCon22();
TC.connect('12');

% Set the units to K
TC.setUnitsKelvin();

% Initialize variables
file = fopen('C:\Users\qlab\Qlab\experiments\Graphene\50Ohm_Johnson_Noise\20140429_Cool_Down.txt','w');
fprintf(file,'March 29th 2014. Cool down log of 3K BBN fridge\r\n\r\n');
fprintf(file,'Time\tTemperature\r\n');

% temperature log loop
pause on
pause(5)
t=0;
while true
    temp = TC.temperatureA();
    pause(5)
    fprintf(file,'%d\t%G\r\n',[t,temp]);
    pause(5);
    t=t+10;
end
