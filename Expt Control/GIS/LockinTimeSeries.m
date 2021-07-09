%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and How?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Taking a long timeseries on multiple lockins
% Written in June 2021 by Caleb Fried (cfried@college.harvard.edu)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [data] = LockinTimeSeries(LockinNum, MaxRuntime, timeConstant, interval, ExcitVoltage)

if LockinNum > 3
    disp('Only up to 3 lockins supported; add more to the program if necessary!')
    return
end


Lockin = deviceDrivers.SRS865();
Lockin.connect('128.33.89.76')
disp('Connecting Lock-in 1...')
pause(1);
if Lockin.isConnected == 1
    disp('Connected!')
    Lockin.sineAmp = 0;
else
    disp('Failed!')
    return
end

if LockinNum >= 2
    Lockin2 = deviceDrivers.SRS865();
    Lockin2.connect('128.33.89.143')
    disp('Connecting Lock-in 2...')
    pause(1);
    if Lockin2.isConnected == 1
        disp('Connected!')
        Lockin2.sineAmp = 0;
    else
        disp('Failed!')
        return
    end
end

if LockinNum >= 3
    Lockin3 = deviceDrivers.SRS865();
    Lockin3.connect('128.33.89.16')
    disp('Connecting Lock-in 3...')
    pause(1);
    if Lockin3.isConnected == 1
        disp('Connected!')
        Lockin3.sineAmp = 0;
    else
        disp('Failed!')
        return
    end
end
    pause(9*timeConstant);

pause on;
data.tstart = clock;
for i = 1:(MaxRuntime/(interval/3600)+1)
    
    h = figure('CloseRequestFcn','','Position',[500 250 750 750]);
    subplot(2,2,4);
    set(gca,'XColor', 'none','YColor','none')
    title('Type anything to stop run')
    timeleft = num2str(MaxRuntime - etime(clock,data.tstart)/3600);
    disp(strcat('Measuring Lock-ins for',{' '}, timeleft, ' more hours. Type anything to stop the run'))
    save('backup.mat','data');
    hedit = uicontrol('style','edit','Units','pixels','Position',[475 200 180 20],'callback','uiresume','string',"Continue?");
    T = timer('Name','mm', ...
   'TimerFcn','uiresume', ...
   'StartDelay',(interval - 10*LockinNum*timeConstant - 0.3*LockinNum), ...
   'ExecutionMode','singleShot');
    if i > 1
        subplot(2,2,1);
        plot(data.time(1:i-1),data.X(1:i-1),'.-'); grid on; box on;
        xlabel('oxidation time (hours)');
        ylabel('Lock-in X (V)');
        title('Lockin 1');
        subplot(2,2,2);
        if LockinNum >= 2
        plot(data.time2(1:i-1),data.X2(1:i-1),'.-'); grid on; box on;
        xlabel('oxidation time (hours)');
        ylabel('Lock-in X (V)');
        title('Lockin 2');
        end
        if LockinNum >= 3
        subplot(2,2,3);
        plot(data.time3(1:i-1),data.X3(1:i-1),'.-'); grid on; box on;
        xlabel('oxidation time (hours)');
        ylabel('Lock-in X (V)');
        title('Lockin 3');
        end
    end

    Lockin.sineAmp = ExcitVoltage;
    pause(10*timeConstant);
    Lockin.X;
    pause(0.1)
    data.X(i) = Lockin.X;
    pause(0.1)
    Lockin.Y;
    pause(0.1)
    data.Y(i) = Lockin.Y;
    t1 = clock;
    data.time(1,i) = etime(t1,data.tstart)/3600;
    subplot(2,2,1);
    plot(data.time(1:i),data.X(1:i),'.-'); grid on; box on;
    xlabel('oxidation time (hours)');
    ylabel('Lock-in X (V)');
    title('Lockin 1');
    Lockin.sineAmp = 0;
    if get(hedit,'String') ~= "Continue?"
        break
    end
    
    if LockinNum >= 2
        Lockin2.sineAmp = ExcitVoltage;
        pause(10*timeConstant);
        Lockin2.X;
        pause(0.1)
        data.X2(i) = Lockin2.X;
        pause(0.1)
        Lockin2.Y;
        pause(0.1)
        data.Y2(i) = Lockin2.Y;
        t2 = clock;
        data.time2(1,i) = etime(t2,data.tstart)/3600;
        subplot(2,2,2);
        plot(data.time2(1:i),data.X2(1:i),'.-'); grid on; box on;
        xlabel('oxidation time (hours)');
        ylabel('Lock-in X (V)');
        title('Lockin 2');
        Lockin2.sineAmp = 0;
        if get(hedit,'String') ~= "Continue?"
            break
        end
    end
    
    if LockinNum >= 3
        Lockin3.sineAmp = ExcitVoltage;
        pause(10*timeConstant);
        Lockin3.X;
        pause(0.1)
        data.X3(i) = Lockin3.X;
        pause(0.1)
        Lockin3.Y;
        pause(0.1)
        data.Y3(i) = Lockin3.Y;
        t3 = clock;
        data.time3(1,i) = etime(t3,data.tstart)/3600;
        subplot(2,2,3);
        plot(data.time3(1:i),data.X3(1:i),'.-'); grid on; box on;
        xlabel('oxidation time (hours)');
        ylabel('Lock-in X (V)');
        title('Lockin 3');
        Lockin3.sineAmp = 0;
        if get(hedit,'String') ~= "Continue?"
            break
        end
    end
    save('backup.mat','data');

    start(T)
    uiwait(h)
    if get(hedit,'String') ~= "Continue?"
        break
    end
    delete(h)
    stop(T)
    delete(T)
end
disp('Run stopped')
Lockin.disconnect;
if LockinNum >= 2
Lockin2.disconnect;
end
if LockinNum >= 3
Lockin3.disconnect;
end
clear Lockin Lockin2 Lockin3 Rload1 Rload2 Rload3 runtime timeleft Vexcit1 Vexcit2 Vexcit3 i interval output T h hedit t1
close all force

end