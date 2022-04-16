%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = VNA_vs_CapLength(CapLength, InitialWaitTime)
pause on;

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
pause(InitialWaitTime);
for k=1:length(CapLength)
    input(['Cut the wire to ' num2str(CapLength(k)) ' inches. Press any button to continue after cutting...\n'])
    datetime('now')
    sprintf('The %dth data point', k)
    result = GetVNASpec_VNA();
    data.S(k,:) = result.S;
    save('backup.mat')
end
data.Freq = result.Freq;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
pause off; clear result
end