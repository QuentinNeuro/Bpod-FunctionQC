function demodData=Online_Demodulation(rawData,sampleRate,modFreq,lowCutoff,phaseShift)
% Demodulate an AM-modulated input ('rawData') in quadrature given a
% reference ('refData'). 'LowCutOff' is a corner frequency for 5-pole
% butterworth lowpass filter.

if nargin<4
    lowCutoff=15;
    phaseShift=0;
end
if nargin<5
    phaseShift=0;
end

if size(rawData,2)==1
    rawData=rawData';
end

%% Prepare reference data and generates 90deg shifted ref data
dLength = length(rawData);
dt      = 1/sampleRate;
time    = [0:1:dLength-1] * dt;
refData   = sin(2 * pi * modFreq * time+phaseShift);
refData90 = cos(2 * pi * modFreq * time+phaseShift);

%% Decoding
processedData_0     = rawData .* refData;
processedData_90    = rawData .* refData90;

%% Filter
    lowCutoff = lowCutoff/(sampleRate/2); % normalized CutOff by half SampRate (see doc)
    [b, a] = butter(5, lowCutoff, 'low'); 
    % pad the data to suppress windows effect upon filtering
    pad = 1;
    if pad
        paddedData_0        = processedData_0(1:sampleRate);
        paddedData_90       = processedData_90(1:sampleRate);
        demodDataFilt_0     = filtfilt(b,a,[paddedData_0 processedData_0]);
        demodDataFilt_90    = filtfilt(b,a,[paddedData_90 processedData_90]);        
        processedData_0     = demodDataFilt_0(sampleRate + 1: end);
        processedData_90    = demodDataFilt_90(sampleRate + 1: end);
    else
        processedData_0     = filtfilt(b,a,processedData_0);
        processedData_90    = filtfilt(b,a,processedData_90); 
    end
    
demodData = (processedData_0 .^2 + processedData_90 .^2) .^(1/2);
end