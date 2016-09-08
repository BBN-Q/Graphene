function GrapheneProperties = Mobility_lmfp_from_RvsVG(R,VG,dev_w,dev_l)
%Takes resistance in ohms (R) as a function of gate voltage in volts (VG)
%for a graphene device of dimension dev_w wide by dev_l long (in meters)
%and returns mobility (in cm^2/(Vs)) and mean free path (in meters)


%constants of nature
eps0=8.85e-12;
qelectron=1.6e-19;
hbar=1.05e-34;
vF=1e6;

%assuming SiO2 back gate
epsSiO2=3.9*eps0;
tSiO2=285e-9;

%Charge Neutrality Point
[~, idx]=max(R);
CNP=VG(idx);
GrapheneProperties=struct('R',R,'VG',VG,'CNP',CNP,'dev_w',dev_w,'dev_l',dev_l,'mobility',[],'lmfp',[],'ETHd',[],'ETHb',[]);



%Electron Density, Sheet Resistivity
nden=epsSiO2*1e-4/(qelectron*tSiO2)*(VG-CNP); %cm^-2
rho=R*dev_w/dev_l; %Ohm

mob=(1./(rho.*nden*qelectron)); %cm^2/(Vs)
GrapheneProperties.mobility=mob;
GrapheneProperties.lmfp=abs(hbar/qelectron*sqrt(pi*abs(nden)*10^4).*mob/10^4); %m
GrapheneProperties.ETHd=hbar*(.5*vF*GrapheneProperties.lmfp)/dev_l^2;
GrapheneProperties.ETHb=hbar*vF/dev_l;


figure; plot(VG,R); grid on
xlabel('Gate Voltage (V)','FontSize',14);ylabel('Resistance (\Omega)','FontSize',14); title('Resistance vs Gate','FontSize',14); set(gca,'FontSize',14);
figure; plot(VG,abs(GrapheneProperties.mobility)); grid on
xlabel('Gate Voltage (V)','FontSize',14);ylabel('Mobility (cm^2/(Vs))','FontSize',14); title('Mobility vs Gate','FontSize',14); set(gca,'FontSize',14);
figure; plot(VG,GrapheneProperties.lmfp); grid on
xlabel('Gate Voltage (V)','FontSize',14);ylabel('Mean Free Path (nm)','FontSize',14); title('Mean Free Path vs Gate','FontSize',14); set(gca,'FontSize',14);

end

