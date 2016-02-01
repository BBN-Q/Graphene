function [V_Array, TotalSteps] = V_Array(V_Start, V_End, V_Step,flag)
%Takes a start, end, and step voltage and gives the corresponding array of
%voltage values. V_Step is unsigned. If varargin=0, one way trip. If varargin=1,
%round trip.

if V_End>V_Start
    V_Step=abs(V_Step);
elseif V_Start>V_End
    V_Step=-abs(V_Step);
end
if V_Step==0
    TotalSteps=1;
else
    TotalSteps=(V_End-V_Start)/V_Step+1;
end
V_Array=zeros(TotalSteps,1);
for i = 1:TotalSteps
    V_Array(i) = V_Start + (i-1)*V_Step;
end
if flag==1 && V_Step~=0
    for i = 1:TotalSteps
        V_Array(TotalSteps+i) = V_End - (i-1)*V_Step;
    end
    TotalSteps=2*TotalSteps;
end