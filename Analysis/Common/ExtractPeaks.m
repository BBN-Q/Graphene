function Peak_data = ExtractPeaks(data_x,data_y,thresh,pre_delay,post_delay)
%Counts the number of peaks above some threshold (thresh) for a given
%vector (data) with peaks being separated by delay indices. Stores the data
%surrounding the peaks.

Peak_data=struct('num_peaks',[],'Time',[],'Voltage',[]);

points=length(data_y);
num_peaks=0;
i=1;
while i<points
    val=data_y(i);
    if val>thresh
        num_peaks=num_peaks+1;
        if (i-pre_delay)<1
            buffer=zeros(1,abs(i-pre_delay)+1);
            Peak_data.Time(num_peaks,:)=[buffer data_x(1:i+post_delay)];
            Peak_data.Voltage(num_peaks,:)=[buffer data_y(1:i+post_delay)];
        elseif (i+post_delay)>points
            buffer=zeros(1,abs(i+post_delay)-points);
            Peak_data.Time(num_peaks,:)=[data_x(i-pre_delay:points) buffer];
            Peak_data.Voltage(num_peaks,:)=[data_y(i-pre_delay:points) buffer];
        else
            Peak_data.Time(num_peaks,:)=data_x(i-pre_delay:i+post_delay);
            Peak_data.Voltage(num_peaks,:)=data_y(i-pre_delay:i+post_delay);
        end
        i=i+post_delay;        
    else
        i=i+1;
    end
end

Peak_data.num_peaks=num_peaks;


end

