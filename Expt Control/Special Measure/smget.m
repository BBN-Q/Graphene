function data = smget(channels)
% data = smget(channels)
% 
% Get current values of channels.
% channels can be a cell or char array with channel names, or a vector
% with channel numbers.
% data is a cell vector of data arrays.

global smdata;

if(isempty(channels))
    data={};
    return
end
if ~isnumeric(channels)
    channels = smchanlookup(channels);
end

nchan = length(channels);
data = cell(1, nchan);
instchan = vertcat(smdata.channels(channels).instchan);

for k = 1:nchan;
    data{k} = smdata.inst(instchan(k, 1)).cntrlfn([instchan(k, :), 0])...
        ./smdata.channels(channels(k)).rangeramp(4);
    if length(data{k}) == 1
        smdata.chanvals(channels(k)) = data{k};
    end
end

if ishandle(999)
    str = get(smdata.chandisph, 'string');
    for k = 1:nchan
        if length(data{k}) == 1 
            str{channels(k)} = sprintf('%.5g', data{k});
        end
    end
    set(smdata.chandisph, 'string', str);
end