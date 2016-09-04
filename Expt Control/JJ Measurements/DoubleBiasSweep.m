function JJxSwitch_vs_JJyBias = DoubleBiasSweep
%All paramters are hardwired - manually change within program

last_file_num=365; %CHANGE FILE # HERE (# should be last saved File #)

StartTime = clock;
FileName = strcat('DoubleBiasSweep_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'.mat');

temp = instrfind;
if ~isempty(temp)
    fclose(temp);
    delete(temp);
end

Vb=V_Array(3,1,.1,0);
JJxSwitch_vs_JJyBias=struct('Ib_Array',Vb,'JJ0Rate',[],'JJ1Rate',[]);

for i=1:length(Vb)
    
	Ibstring=strrep(num2str(Vb(i)),'.','p');
    
    filestring=num2str(last_file_num+2*i-1);
    tag=strcat('BGB57_VG_30V_SwitchJJ0_Ib_1p66uA_ConstJJ1_Ib_',Ibstring,'uA_File',filestring); %CHANGE POWER LABEL HERE
    CrossTalk_data=BiasJJ1_SRS865Excite_K2400Meas_MeasJJ0_SRS865Excite_K2400Meas(600,1e6,1.66,.1,1,.05,1e6,Vb(i),30,tag);
    
    JJxSwitch_vs_JJyBias.JJ0Rate(i)=CrossTalk_data.Clicks0/CrossTalk_data.Time(end);
   
    filestring=num2str(last_file_num+2*i); %CHANGE FILE # HERE (# should be last saved File #)
    tag=strcat('BGB57_VG_30V_SwitchJJ1_Ib_1p47uA_ConstJJ0_Ib_',Ibstring,'uA_File',filestring); %CHANGE POWER LABEL HERE
    CrossTalk_data=BiasJJ0_SRS865Excite_K2400Meas_MeasJJ1_SRS865Excite_K2400Meas(600,1e6,Vb(i),1e6,1.47,.1,1,.05,30,tag);

    JJxSwitch_vs_JJyBias.JJ1Rate(i)=CrossTalk_data.Clicks1/CrossTalk_data.Time(end);
    
    save(FileName,'JJxSwitch_vs_JJyBias')
    close all
end

