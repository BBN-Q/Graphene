function CombineJJSwitchData = CombineJJSwitchData(JJ_switch_data1,JJ_switch_data2)
%Combines two data sets from JJ switch data with the same bias current,
%reset current, threshold voltage, and gate voltage into one structure.

length1=length(JJ_switch_data1.Time);
length2=length(JJ_switch_data2.Time);

CombineJJSwitchData=JJ_switch_data1;

%Combine data ignoring first data point of JJ_switch_data2
CombineJJSwitchData.VJJ((length1+1):(length1+length2-1))=JJ_switch_data2.VJJ(2:length2);
CombineJJSwitchData.Time((length1+1):(length1+length2-1))=JJ_switch_data2.Time(2:length2)+JJ_switch_data1.Time(length1);