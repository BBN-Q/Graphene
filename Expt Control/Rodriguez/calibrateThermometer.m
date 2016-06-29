%written by Artem Talanov 06/10/2016
%calibrates thermometer vs another thermometer on warmup only
%tempIndex: the index in the calibrated temps to which you want to calibrat
%waitTime: wait time in seconds to allow thermal equilibrium after the temp
%is reached
%avgTime: average time in seconds at the selected temp
function calibrateThermometer(tempIndex, waitTime, avgTime)

lowestTemp=3;

%index of curve that is calibrated
calibratedCurve=30;
calibratedChannel='B';

%new curve that is being calibrated
curve=21;
channel='A';

%where to save new calibration file
filename='calibration.dat';

name='DT670Cal';
serialNumber='000';
fformat=2; %V/K
coefficient=1; %positive

%load the calibration data 
load C:\Users\Gladys\Desktop\X108541.dat;
temps=X108541(:,1);

%connect to lakeshore bridge and set new curve header
ls335 = deviceDrivers.Lakeshore335();
ls335.connect('12')
ls335.setInputCurveNumber(calibratedCurve, calibratedChannel);
ls335.set_curve_header(curve, name, serialNumber, fformat, lowestTemp, coefficient);

%do the actual calibration now
%for given temperature point in calibrated curve, set the temp and wait
%after waiting average the resistance/voltage of the uncaled thermometer
ls335.setPoint1=temps(tempIndex);
    
%wait until temp is reached
fprintf('waiting to reach temperature %f K...',temps(tempIndex))
while(ls335.get_temperature(calibratedChannel)<temps(tempIndex))
   pause(15);
end

disp('temperature reached, waiting for equilibration...')

%after temp is reached wait to let it equilibrate
pause(waitTime);

disp('averaging temperature')

%average measurements for some time
n=0;
total=0;
totalTemp=0;
for j=1:avgTime*4
    total=total+ls335.readSensorUnitsInput(channel);
    totalTemp=totalTemp+ls335.get_temperature('B');
    n=n+1;
    pause(0.25);
end
avgValue=total/n;
avgTemp=totalTemp/n;

%add datapoint to curve and save to file
ls335.set_curve_val(curve, tempIndex, avgValue, temps(tempIndex));
fid=fopen(filename,'at');
fprintf(fid,'%f,%f,%f\n',temps(tempIndex), avgTemp, avgValue);
fclose(fid);

ls335.disconnect();

disp('datapoint done');

end