function smset(channels, vals, ramprate)
% smset(channels, vals, ramprate)
%
% Set channels to vals.
% channels can be a cell or char array with channel names, or a vector
% with channel numbers.
% vals is a vector with one element for each channel.
% ramprate is used instead of instrument default if given, finite,     
% and smaller than default. A negative ramprate prevents
% waiting for ramping to finish for self ramping channels (type = 1).
% (This faeature is mainly used by smrun).

global smdata;

if isempty(channels) 
    return
end

dt = .01;

if ~isnumeric(channels)
    channels = smchanlookup(channels);
end

nchan = length(channels);

if size(vals, 2) > 1
    vals = vals';
end

if length(vals) == 1
    vals = vals * ones(nchan, 1);
end


rangeramp = vertcat(smdata.channels(channels).rangeramp);
instchan = vertcat(smdata.channels(channels).instchan);

if nargin >= 3 %&& ~isempty(ramprate)
    if size(ramprate, 2) > 1
        ramprate = ramprate';
    end

    if length(ramprate) == 1
        ramprate = ramprate * ones(nchan, 1);
    end

    mask = isfinite(ramprate);
    if any(mask)
        rangeramp(mask, 3) = min(ramprate(mask), rangeramp(mask, 3));
    end
end

%limits & conversion factor
vals = max(min(vals, rangeramp(:, 2)), rangeramp(:, 1));

vals2 = vals .* rangeramp(:, 4);
rangeramp(:, 3) = rangeramp(:, 3) .* rangeramp(:, 4);

curr = zeros(nchan, 1);
chantype = zeros(nchan, 1);
ramptime = zeros(nchan, 1);

for k = 1:nchan
    chantype(k) = smdata.inst(instchan(k, 1)).type(instchan(k, 2));
end

% channels to ramp.

rampchan = find(isfinite(rangeramp(:, 3))& chantype == 1);
stepchan = find(isfinite(rangeramp(:, 3)) & chantype == 0);

if any(rangeramp(stepchan, 3) < 0)
    error('Negative ramp rate for step channel.');
end
    
setchan = find(~isfinite(rangeramp(:, 3)));

% get current val for step channels
for k = stepchan'
    curr(k)= smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 0]);
end

initial_val = zeros(nchan, 1); %no actual reason to make it nchan long
% start ramps
for k = rampchan'
    %get initial values for faulty inst check at end
    if isfield(smdata.inst(instchan(k, 1)),'faulty') &&...
                ~isempty(smdata.inst(instchan(k, 1)).faulty) &&...
                smdata.inst(instchan(k, 1)).faulty
            initial_val(k)=smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 0]);
    end
    ramptime(k) = smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 1], vals2(k), rangeramp(k, 3));
end

for k = setchan'    
    smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 1], vals2(k));
end

tramp = now;

if ishandle(999)
    smdispchan(channels([rampchan; setchan]), vals([rampchan; setchan]));
end

% step channels
if ~isempty(stepchan)
    rangeramp(stepchan, 3) = dt * rangeramp(stepchan, 3) .* (2 * (vals2(stepchan) > curr(stepchan)) - 1);
    nstep = floor((vals2(stepchan)-curr(stepchan))./rangeramp(stepchan, 3));
    for l = 1:max(nstep)
        tstep = now;
        curr = curr + rangeramp(:, 3);        
        for k = stepchan(l <= nstep)';
            smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 1], curr(k));
        end
        
        if ishandle(1001) && ~mod(l, 10)
            smdispchan(channels(stepchan(l <= nstep)), curr(stepchan(l <= nstep))...
                ./rangeramp(stepchan(l <= nstep), 4));
        end

        % wait
        while (now - tstep) * 24 * 3600 < dt ;end
        
        if ishandle(1000) 
            c = get(1000, 'CurrentCharacter');
            if c == char(27)
                return;
            end
        end
    end
end

% set exact target value 
for k = stepchan'    
    smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 1], vals2(k));
end
if ishandle(999)
    smdispchan(channels(stepchan), vals(stepchan));
end

smdata.chanvals(channels) = vals;

%redefine rampchan so autochans are excluded
rampchan = rampchan(rangeramp(rampchan, 3) > 0);
ramptime = ramptime(rampchan);

if ~isempty(rampchan)
    
    %initial wait for ramping channels
    pause(max(ramptime) + 24*3600*(tramp - now));
    
    %check ramping channels on faulty instruments
    for k = rampchan'
        %display(k)
        %check if faulty instrument (field exists, isnt empty, AND true)
        while isfield(smdata.inst(instchan(k, 1)),'faulty') &&...
                ~isempty(smdata.inst(instchan(k, 1)).faulty) &&...
                smdata.inst(instchan(k, 1)).faulty
            curr_val= smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 0]);            
            %display(curr_val)
            %break when the inst passes the target value
            if (initial_val(k)<=vals2(k) && curr_val>=vals2(k)) ||...
                    (initial_val(k)>=vals2(k) && curr_val<=vals2(k))
                break
            else pause(.5)
            end
        end
    end
end