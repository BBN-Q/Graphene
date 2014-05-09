%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%     What and hOw?      %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot the noise temperature vs frequency from a series of specrums
% Intended for data taken by Temperature_sweep_spectrum_grabber
% Created in May 2014 by KC Fong and Jesse Crossno

function [smoothedData,noiseTemp] = Noise_temperature_analyzer(data,BWMHz)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%     Initialize         %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%find spacing between frequency points and convert BW into # of points
%here BW is actually the number of additional points taken on either side
deltaf=data(3,1)-data(2,1);
BW=floor(BWMHz/(2*deltaf));

%create a blank array the size of data
s=size(data);
smoothedData=zeros(s);
smoothedData(:,1)=data(:,1);
smoothedData(1,:)=data(1,:);

%initialize the output array
noiseTemp=zeros(s(1)-1-2*BW,2);


%integrating loop
for j=2:s(2)
    for i=2+BW:s(1)-BW
        smoothedData(i,j)=mean(data(i-BW:i+BW,j));
    end
end

%calulate noise temperatures
for i=1:s(1)-1-2*BW
    
    %location of point in smoothedData
    k=i+1+BW;
    
    fit=fitlm(smoothedData(1,2:s(2)),smoothedData(k,2:s(2)));
    %calculate the noise temp as nt=(offset/slope)
    nt=fit.Coefficients.Estimate(1)/fit.Coefficients.Estimate(2);
    
    noiseTemp(i,1)=smoothedData(k,1);
    noiseTemp(i,2)=nt;
end
figure;plot(noiseTemp(:,1),noiseTemp(:,2));grid on;
    
    








