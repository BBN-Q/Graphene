function [newdata, data] = smpSpect(newdata, data)
% compute auto correlation of one or two pulses, plus optionally 
% the difference spectrum. 
% Windows must be smaller than a single record (?).

persistent olddata;
persistent nold;
persistent count;
persistent win;

nft = size(data, 1);
nsamp = size(data, 2) * 2;

if isnan(data(1))
    nold = 0;
    count = 0;    
    olddata = nan(nsamp, nft);
    data(:) = 0;
    win = window(@hann, nsamp);
end

if nft >= 2
    newdata = reshape(newdata, 2, size(newdata, 1)/2)';
end
  
if nft == 3
    newdata =  [newdata, diff(newdata, [], 2)];
end
    
nwin = floor((nold + size(newdata, 1) - nsamp/2)/nsamp);

nold2 = nold + size(newdata, 1) - nwin*nsamp;
olddata2 = newdata(end-nold2+1:end, :);

newdata = [olddata(1:nold, :); newdata(1:(nwin+.5)*nsamp-nold, :)];

ft = mean(abs(ifft(reshape(newdata(1:end-nsamp/2, :), nsamp, nwin, nft).* repmat(win, [1, nwin, nft]))).^2, 2) ... 
    + mean(abs(ifft(reshape(newdata(nsamp/2+1:end, :), nsamp, nwin, nft) .* repmat(win, [1, nwin, nft]))).^2, 2);

w = nwin/(count+nwin);
data =  0.5 * w * permute(ft(1:end/2, :, :), [3, 1, 2]) + (1-w) * data;
count = count+nwin;


nold = nold2;
olddata(1:nold, :) = olddata2(1:nold, :);

newdata = []; % save copying