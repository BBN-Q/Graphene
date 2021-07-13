%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AMI 430 Magnetic Field Controller
% version 1.0 in Dec 2017 by KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function value = AMI430Target(field)

% Find a serial port object.
obj1 = tcpip('128.33.89.45', 7180)

% Connect to instrument object, obj1.
fopen(obj1);
% Configure instrument object, obj1.
%fprintf(obj1, '%s\n', 'ZERO');
value = sprintf('CONFigure:FIELD:TARGet %.4f', field)
fprintf(obj1, value)
fclose(obj1);
delete(obj1);
end