function [demodDataTW,modDataTW]=Online_Process_Photometry(demodData,modData)
global S BpodSystem

%% Parameters from S
sampRate=S.GUI.NidaqSamplingRate;
decimateFactor=S.GUI.DecimateFactor;
dsampRate=round(sampRate/decimateFactor);
TW=[BpodSystem.Data.TrialSettings(1).GUI.TimeMin BpodSystem.Data.TrialSettings(1).GUI.NidaqDuration];
baseTW=[S.GUI.BaselineBegin S.GUI.BaselineEnd];
baseTW_pts=baseTW*dsampRate;
StateToZero=S.Names.StateToZero{S.GUI.StateToZero};
TimeToZero=BpodSystem.Data.RawEvents.Trial{1,end}.States.(StateToZero)(1,1);

%% demodulated data : decimate PSTH and DFF
data=decimate(demodData,decimateFactor);
[timeTW,dataTW]=Online_PSTH(data,TW,TimeToZero,dsampRate);
baselineAVG=mean(dataTW(baseTW_pts(1):baseTW_pts(2)),'omitnan');
dataTWDFF=100*(dataTW-baselineAVG)/baselineAVG;

demodDataTW(:,1)=timeTW;
demodDataTW(:,2)=dataTWDFF;
demodDataTW(:,3)=dataTW;

%% modulated data : PSTH
[modDataTW(:,1),modDataTW(:,2)]=Online_PSTH(modData,TW,TimeToZero,sampRate);

end