%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AMI 430 Magnetic Field Controller
% version 1.0 in Dec 2017 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function value = AMI430Ctrller(field)

% Find a serial port object.
obj1 = instrfind('Type', 'serial', 'Port', 'COM3', 'Tag', '');

% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = serial('COM3');
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);
% Configure instrument object, obj1.
set(obj1, 'BaudRate', 115200);
set(obj1, 'FlowControl', 'hardware');
str = sprintf('CONFigure:FIELD:TARGet %.5f', field);
fprintf(obj1, '%s\r\n', str);
fprintf(obj1, '%s\r\n', 'RAMP');

end