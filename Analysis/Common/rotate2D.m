function RotatedVec = rotate2D(InputVec, theta)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
RotationalMatrix = [[cos(theta) -sin(theta)]; [sin(theta), cos(theta)]];
RotatedVec = RotationalMatrix*InputVec;
end
