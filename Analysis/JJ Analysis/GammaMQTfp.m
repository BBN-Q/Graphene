function [GammaMQT, JJProps] = GammaMQTfp(Ib, Ic, RN, fp0)
%Gives JJ macroscopic quantum tunneling rate as a function of bias current 
%(Ib) for a given critical current (Ic), normal metal resistance (RN), 
%Thouless energy (ETH), and temperature (T)

%Constants of nature
hbar = 1.05e-34; %reduced Planck's constant (m^2kg/s)
e = 1.6e-19; %Electron charge (C)

gammaJJ=Ib/Ic; %Normalized bias current

wp0 = 2*pi*fp0;
wp=wp0*(1-gammaJJ.^2).^0.25; %Plasma frequency (rad/s)
CJJ=2*e*Ic/(hbar*wp0^2); %JJ capacitance (F)
Q=wp*RN*CJJ; %Quality Factor

EJ0=0.5*hbar*Ic/e; %Josephson Coupling Energy (J)
DU=2*EJ0*(sqrt(1-gammaJJ.^2)-gammaJJ.*acos(gammaJJ)); %Barrier height (J)

GammaMQT=12*wp.*sqrt(3*DU./(2*pi*hbar*wp)).*exp(-7.2*(1+.87./Q).*DU./(hbar*wp)); %MQT switching rate

JJProps.Ic = Ic;
JJProps.RN = RN;
JJProps.ETH=hbar/(CJJ*RN);
JJProps.gammaJJ = gammaJJ;
JJProps.CJJ = CJJ;
JJProps.wp0 = wp0;
JJProps.wp = wp;
JJProps.Q = Q;
JJProps.EJ0 = EJ0;
JJProps.DU = DU;
JJProps.GammaMQT = GammaMQT;

end


