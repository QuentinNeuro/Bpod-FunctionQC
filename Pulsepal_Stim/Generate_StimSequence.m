function [TrialSequence,TrialNames,StimSequence]=Generate_StimSequence(S,TrialSequence,TrialNames)

% Parameters
nbOfTrialTypes=max(TrialSequence);
maxTrials=S.GUI.MaxTrials;
block=S.GUI.Opto_Block;
proba=S.GUI.Opto_Proba;
trialType=S.GUI.Opto_TrialType;
if bloc==1 && proba>0
    bloc=ceil(maxTrials)*proba;
end

% Generate Sequence
stimSquence=zeros(1,maxTrials);

% block
if block
    blockIdx=1:block:maxTrials
    for b=2:2:length(blockIdx)
        StimSequence(blockIdx(b):blockIdx(b+1))=1;
    end

else
% not block
if trialType>0
else
end
end
