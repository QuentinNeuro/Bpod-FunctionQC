function [demodDataTW,modDataTW]=Online_Process_Photometry(demodData,modData)
global S BpodSystem

%% Parameters from S
sampRate=S.GUI.NidaqSamplingRate;
decimateFactor=S.GUI.DecimateFactor;
dsampRate=round(sampRate/decimateFactor);
TW=[S.GUI.TimeMin S.GUI.TimeMax];
baseTW=[S.GUI.BaselineBegin S.GUI.BaselineEnd];
StateToZero=S.Names.StateToZero{S.GUI.StateToZero};
TimeToZero=BpodSystem.Data.RawEvents.Trial{1,end}.States.(StateToZero)(1,1);

%% DFF and decimate
data=decimate(demodData,decimateFactor);
baseTW_pts=baseTW*dsampRate;
baselineAVG=mean(data(baseTW_pts(1):baseTW_pts(2)),'omitnan');
data=100*(data-baselineAVG)/baselineAVG;

%% PSTH and Output
[modDataTW(:,1),modDataTW(:,2)]=Online_PSTH(modData,TW,TimeToZero,sampRate);
[demodDataTW(:,1),demodDataTW(:,2)]=Online_PSTH(data,TW,TimeToZero,dsampRate);
end