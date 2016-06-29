R = squeeze(Calibration.R(7,1,:));
G=12*2.44E-8./R;
DeltaT=2;
P=G*DeltaT;
I = sqrt(P./R);
Vex = I*1E4;
clear R g G DeltaT P I