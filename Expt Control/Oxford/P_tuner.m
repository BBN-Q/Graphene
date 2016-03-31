P_list = logspace(0,2,10);
initial_equil_time = 30;
rampRate = 0;
equil_time = 20;
measure_time = 60;
setPoint = 3;
range = 1;

len = length(P_list);
data.mean = zeros(1,len);
data.mean_error = zeros(1,len);
data.mse = zeros(1,len);
data.T_vapor = zeros(len,measure_time*10);
data.T_probe = zeros(len,measure_time*10);
data.equil_time = equil_time;
data.measure_time = measure_time;
data.setPoint = setPoint;
data.P_list=P_list;


TC = deviceDrivers.Lakeshore335();
TC.connect('12');
TC.rampRate1 = rampRate;
TC.range1 = range;
TC.PID1 = [P_list(1),0,0];
TC.setPoint1 = setPoint;

pause on; data.startTime = clock;
for P_n=1:length(P_list)
    P = P_list(P_n);
    TC.PID1 = [P,0,0];
    pause(equil_time);
    for n=1:measure_time*10
        data.time(P_n,n)=etime(clock,data.startTime);
        data.T_vapor(P_n,n)=TC.temperatureA;
        data.T_probe(P_n,n)=TC.temperatureB;
        while etime(clock,data.startTime)-data.time(P_n,n)<0.1
        end
    end
    data.mean(P_n) = mean(data.T_vapor(P_n,:));
    data.mean_error(P_n) = data.mean(P_n) - setPoint;
    data.mse(P_n) = mean((data.T_vapor(P_n,:) - setPoint).^2);
    figure(991);xlabel('P value');ylabel('temperture (K)');
    plot(P_list,data.mean_error);
    plot(P_list,data.mse);
    legend('mean error','mean squared error')
    
    figure(992);hold all;xlabel('time');ylabel('temperture (K)');
    for p=1:length(P_n)
        plot(data.time(p,:),data.T_vapor(p,:));
    end
    legend()
end