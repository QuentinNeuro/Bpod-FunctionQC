function [outcome, curLickEvents]=Online_LickEvents(StateToZero)
%[outcome, curLickEvents]=CurrentTrialEvents(BpodSystem, trialsMatrix, currentTrial, currentTrialType, time)
%
%This function extracts the outcome (absence or presence of neverlickedstate) and the licking events
%to update the trials and licks plots, respectively (see associated functions). 
%The timestamp of lickEvents output is normalized to the timing of the event
%
%Output arguments can be used as an input argument for Online_LickPlot function.
%
%function written by Quentin for CuedReinforcers bpod protocol

global BpodSystem
%% Extract the lick events from the BpodSystem structure
curLickEvents=NaN;  %if no lick, random number
try
    LickEventsRaw=BpodSystem.Data.RawEvents.Trial{1,end}.Events.Port1In;
    TimeForZero=BpodSystem.Data.RawEvents.Trial{1, end}.States.(StateToZero)(1,1);      
    curLickEvents=LickEventsRaw-TimeForZero;
end
%% Outcome : green if the animal has collected the reward / showed anticipatory licks
if sum(curLickEvents>-1 & curLickEvents<2)>1
    outcome='g';
else
    outcome='r';
end
end

