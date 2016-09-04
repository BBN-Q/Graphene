P_list = [-55:13];
f_list = [1e6,1e7,1e8,1E9,5E9];
Nmeasurements = 10;
blank = zeros(length(f_list),length(P_list));
data = struct('P',P_list,'freq',f_list,'V',blank,'V_std',blank);
data.raw = struct('V',zeros(length(f_list),length(P_list),Nmeasurements));

SG = deviceDrivers.SG382();
MM = deviceDrivers.Keysight34401A();
SG.connect('27');
MM.connect('11');

start_dir = 'C:\Crossno\data\';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('PowerDiodeTester', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_J-210.dat');
FileName2 = strcat('owerDiodeTester', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_J-210.mat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
%create header string
fprintf(FilePtr, 'Time\tfreq\tpower\tVmean');
fmtstr = '';
for i=1:Nmeasurements
    fprintf(FilePtr, sprintf('\tV%d',i));
    fmtstr = [fmtstr '\t%e'];
end
fmtstr = [fmtstr '\r\n'];
fprintf(FilePtr, '\r\n');
fclose(FilePtr);


for f_n=1:length(f_list)
    f=f_list(f_n);
    SG.freq = f;    for P_n=1:length(P_list)
        P = P_list(P_n);
        SG.ampN = P;
        for n=1:Nmeasurements
            pause(0.5)
            data.raw.V(f_n,P_n,n) = MM.value;
        end
        data.V(f_n,P_n) = mean(data.raw.V(f_n,P_n,:));
        data.V_std(f_n,P_n) = std(data.raw.V(f_n,P_n,:));
        
        save(fullfile(start_dir, FileName2),'data');
        FilePtr = fopen(fullfile(start_dir, FileName), 'a');
        tmp = [squeeze(data.raw.V(f_n,P_n,:))];
        fprintf(FilePtr,'%s\t',datestr(clock,'YYYY_mm_DD HH:MM:SS'));
        fprintf(FilePtr,'%e\t%d\t%e',f,P,data.V(f_n,P_n));
        fprintf(FilePtr,fmtstr,squeeze(data.raw.V(f_n,P_n,:)));
        fclose(FilePtr);
        
        figure(f_n);xlabel('input power (W)');ylabel('output voltage (V)')
        loglog(10.^(P_list/10),data.V(f_n,:));
    end
end
    