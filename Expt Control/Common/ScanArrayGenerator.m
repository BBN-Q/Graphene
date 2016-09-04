function [V_Array, TotalSteps] = ScanArrayGenerator(StartValue, StopValue, StepValue, flag)
%Takes a start, end, and step voltage and gives the corresponding array of
%voltage values. V_Step is unsigned. If flag=0, one way trip. If flag=1,
%round trip.

if StopValue>StartValue
    StepValue=abs(StepValue);
elseif StartValue>StopValue
    StepValue=-abs(StepValue);
end
if StepValue==0
    TotalSteps=1;
else
    TotalSteps=round((StopValue-StartValue)/StepValue)+1;
end
V_Array=zeros(TotalSteps,1);
for i = 1:TotalSteps
    V_Array(i) = StartValue + (i-1)*StepValue;
end
if flag==1 && StepValue~=0
    for i = 1:TotalSteps
        V_Array(TotalSteps+i) = StopValue - (i-1)*StepValue;
    end
    TotalSteps=2*TotalSteps;
end