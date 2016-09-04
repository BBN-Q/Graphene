%written by Artem Talanov 06/10/2016
%loads calibration data from file into Lakeshore LS335

%load the calibration data 
load C:\Users\Gladys\Desktop\X108541.dat;

curve=30;
name='CX_1030_AA';
serialNumber='X108541';
format=3; %Ohm/K
limitValue=1.4;
coefficient=1; %negative

%extract temps and resistances from calibation data
temps=X108541(:,1);
resistances=X108541(:,2);

%connect to lakeshore bridge
ls335 = deviceDrivers.Lakeshore335();
ls335.connect('12')

ls335.set_curve_header(curve, name, serialNumber, format, limitValue, coefficient)

%function set_curve_val(obj, curve, index, val, temp)
for i=1:length(temps)
      ls335.set_curve_val(curve,i,resistances(i),temps(i));
end