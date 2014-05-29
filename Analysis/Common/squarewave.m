function [SqWave, TimeWave] = squarewave(Freq, SampleRate, SampleLength)
TimeWave = (0:1:SampleLength-1)/SampleRate;
SqWave = sign(sin(2*pi*TimeWave*Freq));