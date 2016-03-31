clear T_list T_n T_set TC 
T_list=[2,3,4,5,6,7,8,10,15,20,25,30,25,40,45,50:10:250];
TC = deviceDrivers.Lakeshore335();
TC.connect('12')
TC.rampRate1 = 0;
TC.range1 = 0;
PIDs = zeros(length(T_list),5);
h2 = waitbar(0,'Get ready to tune');
TC.PID1 = [500,200,100];
pause on
for T_n=1:length(T_list);
    T_set = T_list(T_n);
    TC.setPoint1 = T_set;
    if T_set <= 5.5        
        TC.PID1 = [500,200,100];
        TC.range1 = 1;
    elseif T_set <= 70        
        TC.PID1 = [500,200,100];
        TC.range1 = 2;        
    elseif T_set <= 310
        TC.PID1 = [500,200,100];
        TC.range1 = 3;        
    else
        sprintf('error: temperature set above 310')
        break
    end
    while abs(TC.temperatureA-T_set)>0.5
        while abs(TC.temperatureA-T_set)>0.5
            pause(1)
        end
        pause(1)
    end
    waitbar((T_n-1)/length(T_list),h2,sprintf('Tuning %d K, temperture %d of %d',T_set,T_n,length(T_list)))
    PID = TC.autoTune(1,2,1);
    PIDs(T_n,:) = [T_set TC.range1 PID(1) PID(2) PID(3)];
end
TC.disconnect();
clear T_list T_n T_set TC