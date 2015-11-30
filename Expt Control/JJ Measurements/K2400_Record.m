function K2400_Record

%Create File
UniqueName = input('Enter unique file identifier: ','s');
start_dir = 'C:\Users\qlab\Documents\Graphene Data';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('GrapheneGateSweep_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName, '.dat');
FilePtr = fopen(fullfile(start_dir, FileName), 'w');
%create header string
HeaderStr=strcat(datestr(StartTime), ' Keithley 2400 Record\tFile number:',UniqueName,'\r\n');
fprintf(FilePtr, HeaderStr);
fprintf(FilePtr, 'Time\tVoltage\r\n');
fclose(FilePtr);

%Connect to Keithley 2400
K2400=deviceDrivers.Keithley2400();
K2400.connect('24');

global KEY_IS_PRESSED
KEY_IS_PRESSED = 0;
fprintf('\r\nPress any button to quit\r\n')
figure
hold on
fig = gcf;
set(fig, 'KeyPressFcn', @myKeyPressFcn)
tic;
n=1;

while ~KEY_IS_PRESSED
    val1=K2400.value();
    plot(toc,val1,'.')
    data(:,n)=[toc, val1];
    n=n+1;
    drawnow
end
    FilePtr = fopen(fullfile(start_dir, FileName), 'a');
    fprintf(FilePtr,'%e\t%e\r\n',data);
    fclose(FilePtr);


K2400.disconnect
clear K2400
end


function myKeyPressFcn(~, ~)
global KEY_IS_PRESSED
KEY_IS_PRESSED  = 1;
end