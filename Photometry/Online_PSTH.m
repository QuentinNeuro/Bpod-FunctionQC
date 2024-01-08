function [timeTW,dataTW]=Online_PSTH(data,tw,timeToZero,sampRate)

if size(data,2)==1
    data=data';
end

%% Time window
dt=1/sampRate;
expectedSizeTW=diff(tw)*sampRate;
time=[0:1:length(data)-1] * dt; 
timeZ=time-timeToZero;
timeTW=linspace(tw(1),tw(2),expectedSizeTW);
idxZeroT=find(timeZ>=0,1);
idxZeroTW=find(timeTW>=0,1);

%% Padding Parameters
dataBef=data(1:(idxZeroT-1));
dataAft=data(idxZeroT:end);
sizeDBef=length(dataBef);
sizeDAft=length(dataAft);

sizeTBef=length(timeTW(1:(idxZeroTW-1)));
sizeTAft=length(timeTW(idxZeroTW:end));

%% Padding data
dataTW=nan(size(timeTW));
if sizeDBef>=sizeTBef
    dataTW(1:idxZeroTW-1)=dataBef(end-sizeTBef+1:end);
else
    dataTW(idxZeroTW-sizeDBef:idxZeroTW-1)=dataBef;
end
if sizeDAft>=sizeTAft
    dataTW(idxZeroTW:end)=dataAft(1:sizeTAft);
else
    dataTW(idxZeroTW:idxZeroTW+sizeDAft-1)=dataAft(1:sizeDAft);
end
end
