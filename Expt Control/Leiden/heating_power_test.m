function data = heating_power_test(I_list)
%HEATING_POWER_TEST applys a current, waits some time and removes current 
%recording temperature
%Jesse Crossno Jun 18th 2016

%get info from user
assert(max(I_list)<50E-3,'max current set about 50 mA');

hold_time = input('Enter hold time (s) [300]: ');
if isempty(hold_time)
    hold_time = 300;
end
UniqueName = input('Enter uniquie file identifier: ','s');

%settings
Rex = 101.1E6;
address='7';
data_interval = 1; %in seconds
initial_wait_time = 1000;

%initialize
pause on
X110375 = deviceDrivers.X110375(Rex,address);
heater = deviceDrivers.YokoGS200();
heater.connect('18');
heater.value = 0;
heater.output = 1;

I_length = length(I_list);
t_length = 2*floor(hold_time/data_interval)+floor(initial_wait_time/data_interval);
blank = zeros(I_length,t_length);
data.time = blank;
data.temperature = blank;
data.I_list = I_list;
data.Rex = Rex;
data.Vex = X110375.sineAmp;
data.freq = X110375.sineFreq;
data.time_constant = X110375.timeConstant;
data.initial_wait_time = initial_wait_time;
data.data_interval = data_interval;

start_dir = 'D:\Crossno\data';
start_dir = uigetdir(start_dir);
StartTime = clock;
FileName = strcat('heating_power_test_', datestr(StartTime, 'yyyymmdd_HHMMSS'),'_',UniqueName,'.mat');

figure(981); clf; xlabel('time (min)');ylabel('Temperature (K)'); 
grid on; hold all; legend('show');
figure(982); clf; xlabel('time (min)');ylabel('Temperature (K)'); 

%internal function to measures T every interval seconds for time seconds
    function [measurement_times, temperatures] = measure_temperature(time,interval)
        n = floor(time/interval);
        measurement_times = zeros(1,n);
        temperatures = zeros(1,n);
        start = clock;
        for i=1:n
            while etime(clock,start) < interval*(i-1)
            end
            t = clock;
            temperatures(i) = X110375.temperature();
            measurement_times(i) = etime(t,StartTime);
            change_to_figure(982); clf; grid on;
            xlabel('time (min)'); ylabel('Temperature (K)'); 
            plot(measurement_times(1:i)-measurement_times(1),temperatures(1:i),'r.');
            pause(0.1)
        end
    end
%create the progress bar
pbar = waitbar(0,'Please wait...');

for I_n=1:I_length
    I = I_list(I_n);
    waitbar((I_n-1)/I_length, pbar, sprintf('Setpoint %d of %d: %g mA', I_n, I_length, I*1000))
    
    heater.value = 0;
    [init_times, init_temps] = measure_temperature(initial_wait_time,data_interval);
    heater.value = I;
    [hot_times, hot_temps] = measure_temperature(hold_time,data_interval);
    heater.value = 0;
    [cool_times, cool_temps] = measure_temperature(hold_time,data_interval);
    
    t0 = init_times(1);
    data.time(I_n,:) = [init_times-t0, hot_times-t0, cool_times-t0];
    data.temperature(I_n,:) = [init_temps, hot_temps, cool_temps];
    
    save(fullfile(start_dir, FileName),'data')

    change_to_figure(981);
    plot(data.time(I_n,:)/60,data.temperature(I_n,:), 'DisplayName', sprintf('%g mA',I*1000))
    legend('off'); legend('show');
end
close(pbar)
end

