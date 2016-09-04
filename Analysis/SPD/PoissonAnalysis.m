function [ result ] = PoissonAnalysis( data, TimeWindow )
    PhotonMatrix = data.photon;
% 
    TotalArraySize = length(PhotonMatrix);
    WindowSize = floor(TimeWindow/data.TimeBinLength);
    if mod(TotalArraySize, WindowSize) ~= 0
        ReshapedV = reshape([PhotonMatrix ones(1,WindowSize-mod(TotalArraySize, WindowSize))], WindowSize, floor(TotalArraySize/WindowSize)+1);
        ReshapedV = ReshapedV(:, 1:end-1);
    else ReshapedV = reshape(PhotonMatrix, WindowSize, floor(TotalArraySize/WindowSize));
    end
    result.PhotonMatrix = ReshapedV;
    
    result.PhotonCounts = sum(ReshapedV);
    result.h = histogram(result.PhotonCounts)
end