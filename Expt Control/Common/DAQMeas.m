function output = DAQMeas(DAQ,samplingRateAI,timeAI)
%DAQMeas Collect data from NIDAQ at rate samplingRateAI for time timeAI.
%Collect data from NIDAQ at rate samplingRateAI for time timeAI.
  
    global output
    output = struct('time',[],'voltage',[]);
      
    %Setup NIDAQ
    DAQ.Rate = samplingRateAI;
    DAQ.DurationInSeconds = timeAI;
    lh = addlistener(DAQ,'DataAvailable', @storeData);
    DAQ.startBackground();
    DAQ.wait();
    delete(lh)
end

function storeData(src,event)
    global output
    output.time = [output.time; event.TimeStamps];
    output.voltage = [output.voltage; event.Data];
end


