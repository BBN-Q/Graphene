%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graphene Sweeping Software
% version 2.0 in July 2016 by BBN Graphene Trio: Jess Crossno, Evan Walsh,
% and KC Fong
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [data] = VNA_vs_TestPower(PowerList, AveragingNumberList, InitialWaitTime)
pause on;
VNA = deviceDrivers.AgilentE8363C();
%VNA.connect('16');
%VNA.connect('128.33.89.251');   % Old
VNA.connect('128.33.89.252');   % New

%%%%%%%%%%%%%%%%%%%%%     RUN THE EXPERIMENT      %%%%%%%%%%%%%%%%%%%%%%%%%
VNA.power = PowerList(1); % Power in dBm
VNA.disconnect();
total_num = length(PowerList);
pause(InitialWaitTime);
for k=1:length(PowerList)
    VNA.connect('128.33.89.252');   % New
    sprintf('The %d/%d scanning with VNA test power %e', k, total_num, PowerList(k))
    VNA.power = PowerList(k);
    VNA.average_counts = AveragingNumberList(k);
    VNA.disconnect();
    spec = GetVNASpec_VNA();
    data.S(k,:) = spec.S;
end
data.Freq = spec.Freq;

%%%%%%%%%%%%%%%%%%%%    BACK TO DEFAULT, CLEAN UP     %%%%%%%%%%%%%%%%%%%%%%%%%
%pause off;
VNA.connect('128.33.89.252');   % New
VNA.power = min(PowerList);
%VNA.average_counts = max(AveragingNumberList);
VNA.disconnect();
clear VNA spec total_num k
end