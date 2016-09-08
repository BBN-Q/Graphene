function dubosData = dubosFit(Ic,Temp,RN,ETH,Ic0)
% Takes critical curent (Ic) as a function of temperature (Temp) for a JJ 
% with resistance RN and Thouless energy ETH and gives best fit to long
% diffusive equation from Dubos, et. al. PRB 63, 064502 (2001) pg 3. If Ic0
% (the critical current at T=0) is included, a is calculated from this
% value directly. Otherwise a is also a fitting parameter.

q = 1.6e-19; % Electron charge (C)
kB = 1.38e-23; % Boltzmann Constant (J/K)

preFactor=ETH/(q*RN);

if ~exist('Ic0')
    % Dubos fitting function, x(1) corresponds to Dubos "a", x(2) to "b"
    dubosFun=@(x,Tdata)preFactor*x(1)*(1-x(2)*exp(-x(1)*ETH./(3.2*kB*Tdata))); 

    options = optimoptions(@lsqcurvefit,'OptimalityTolerance',1e-12);
    fitParams = lsqcurvefit(dubosFun,[10.82 1.3],Temp,Ic,[],[],options);
    a=fitParams(1);
    b=fitParams(2);
    figure; plot(Temp,Ic/10^-6,'o'); grid on
    hold on; plot(Temp,dubosFun(fitParams,Temp)/10^-6)
else

    a=Ic0/preFactor;
    dubosFun=@(x,Tdata)Ic0*(1-x(1)*exp(-a*ETH./(3.2*kB*Tdata)));
    options = optimoptions(@lsqcurvefit,'OptimalityTolerance',1e-12);
    b = lsqcurvefit(dubosFun,1.3,Temp,Ic,[],[],options);
    figure; plot(Temp,Ic/10^-6,'o'); grid on
    hold on; plot(Temp,dubosFun(b,Temp)/10^-6)
end
xlabel('Temperature (K)'); ylabel('Critical Current (\muA)'); legend('Data','Dubos Fit');
    
dubosData=struct('Temp',Temp,'Ic',Ic,'dubosFun',dubosFun,'a',a,'b',b,'RN',RN,'ETH',ETH);

end

