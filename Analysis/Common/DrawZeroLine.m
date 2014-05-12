%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Draw zero, or more generally, a vertical or horizonal line on existing graph
%
% grab a figure, then draw
function DrawZeroLine(HorV, LineValue)
NumOfPoints = 1001;
if HorV == 'v'
    Limits = get(gco, 'YLim')
    DrawnLine(:,1) = LineValue*ones(NumOfPoints,1);
    DrawnLine(:,2) = linspace(Limits(1), Limits(2), NumOfPoints);
else
    Limits = get(gco, 'XLim')
    DrawnLine(:,1) = linspace(Limits(1), Limits(2), NumOfPoints);
    DrawnLine(:,2) = LineValue*ones(NumOfPoints,1);
end
hold on; plot(DrawnLine(:,1), DrawnLine(:,2), 'r')
end