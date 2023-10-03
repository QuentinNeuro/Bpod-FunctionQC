function [DFF,dataTW,timeTW]=Photometry_DFF_PSTH(demodData,stateToZero)
global BpodSystem S

%% Parameters
% Processing
sampRate=S.GUI.NidaqSamplingRate;
decimateFactor=S.GUI.DecimateFactor;
sampRateDF=sampRate/decimateFactor;
dt= 1/sampRateDF;
baselineTW=[S.GUI.BaselineBegin S.GUI.BaselineEnd];

% Time window
plotTW=[S.GUI.TimeMin{1} S.GUI.TimeMax{1}];
expectedSizeTW=diff(plotTW)*sampRateDF;
timeToZero=BpodSystem.Data.RawEvents.Trial{1,end}.States.(stateToZero)(1,1);

%% Process Data
data=decimate(demodData,decimateFactor);
time=[0:1:length(data)-1] * dt;
f0=mean(data(time>=baselineTW(1) & time<=baselineTW(2)),'omitnan');
DFF=(data-f0)/f0;

%% timeWindow
timeZ=time-timeToZero;
timeTW=linspace(plotTW(1),plotTW(2),expectedSizeTW);

%% timeWindow
% Finding the time window index
timeZ_IO=false(size(timeZ));
timeTW_IO=false(size(timeTW));
timeZ_IO(timeZ>=tw(1) & timeZ<=tw(2))=true;
timeZinTW=timeZ(timeZ_IO);
timeTW_IO(timeTW>=timeZinTW(1) & timeTW<=timeZinTW(end))=true;
% Extract corresponding data
dataTW=DFF(timeZ_IO);
% padding
k=find(timeTW_IO);
padStart=k(1)-1;
padStop=length(timeTW_IO)-k(end);
dataTW=[nan(1,padStart) dataTW nan(1,padStop)];
% adjust length to expected length
switch length(dataTW)-length(timeTW)
    case 1
        dataTW=dataTW(1:end-1);
    case 2
        dataTW=dataTW(2:end-1);
end

end


