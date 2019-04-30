function StimAirPairing
%Functions used in this protocol:
%"CuedReward_Phase": specify the phase of the training
%"WeightedRandomTrials" : generate random trials sequence

%"Online_LickPlot"      : initialize and update online lick and outcome plot
%"Online_LickEvents"    : extract the data for the online lick plot
%"Online_NidaqPlot"     : initialize and update online nidaq plot
%"Online_NidaqEvents"   : extract the data for the online nidaq plot

global BpodSystem nidaq S
PulsePal;
%% Define parameters
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S

if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    Bpod2_TaskParameters_AirStimPairing();
end

% Initialize parameter GUI plugin and Pause
BpodParameterGUI('init', S);
BpodSystem.Pause=1;
HandlePauseCondition;
S = BpodParameterGUI('sync', S);

%% Define trial types parameters, trial sequence and Initialize plots
[S.TrialsNames, S.TrialsMatrix]=Air_Stim_Pairing_Phase(S,S.Names.Phase{S.GUI.Phase});  % choose Air_Stim_Pairing
TrialSequence=WeightedRandomTrials(S.TrialsMatrix(:,2)', S.GUI.MaxTrials);
S.NumTrialTypes=max(TrialSequence);
FigLick=Online_LickPlot_Air_Stim_Pairing('ini',TrialSequence,S.TrialsMatrix,S.Names.Phase{S.GUI.Phase});

%% NIDAQ Initialization
if S.GUI.Photometry
    Nidaq_photometry2('ini');
    FigNidaq=Online_Nidaq2Plot_4class('ini',S.TrialsNames,S.Names.Phase{S.GUI.Phase}); %'Air_Stim_Pairing'
end

BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
%% Main trial loop
for currentTrial = 1:S.GUI.MaxTrials
    switch TrialSequence(currentTrial)
        case 1
                 load('C:\Users\kepecs\Documents\MATLAB\Bpod\Protocols\StimAirPairing\LightTrain_1ms');
        case 2
                 load('C:\Users\kepecs\Documents\MATLAB\Bpod\Protocols\StimAirPairing\LightTrain_5ms');
        case 3
                 load('C:\Users\kepecs\Documents\MATLAB\Bpod\Protocols\StimAirPairing\LightTrain_10ms');
        case 4
                 load('C:\Users\kepecs\Documents\MATLAB\Bpod\Protocols\StimAirPairing\LightTrain_20ms');
    end
    
     ProgramPulsePal(ParameterMatrix);
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin 
    
%% Initialize current trial parameters
% 	S.Sound     =	S.TrialsMatrix(TrialSequence(currentTrial),3);
% 	S.Delay     =	S.TrialsMatrix(TrialSequence(currentTrial),4)+(S.GUI.DelayIncrement*(currentTrial-1));
	S.Valve     =	S.TrialsMatrix(TrialSequence(currentTrial),5);
% 	S.Outcome   =   S.TrialsMatrix(TrialSequence(currentTrial),6);
%     S.ITI = 2;
%     while S.ITI > 3 * S.GUI.ITI
%         S.ITI = exprnd(S.GUI.ITI);
%     end
  
%% Assemble State matrix
 	sma = NewStateMatrix();
    %Pre task states
    sma = AddState(sma, 'Name','PreState',...
        'Timer',S.GUI.PreCue,...
        'StateChangeConditions',{'Tup','AirPuff'},...
        'OutputActions',{'BNCState',1}); 
    sma=AddState(sma,'Name', 'AirPuff',...
        'Timer',0.5,...
        'StateChangeConditions', {'Tup', 'WaitAir'},...
        'OutputActions', {'ValveState', 2});
    sma=AddState(sma,'Name', 'WaitAir',...
        'Timer',2.5,...
        'StateChangeConditions', {'Tup', 'LightStim'},...
        'OutputActions', {});
    sma=AddState(sma,'Name', 'LightStim',...
        'Timer',2,...
        'StateChangeConditions', {'Tup', 'WaitLight'},...
        'OutputActions', {'BNCState',2});
    sma=AddState(sma,'Name', 'WaitLight',...
        'Timer',1,...
        'StateChangeConditions', {'Tup', 'Pairing'},...
        'OutputActions', {}); 
    sma=AddState(sma,'Name', 'Pairing',...
        'Timer',0.5,...
        'StateChangeConditions', {'Tup', 'WaitPairing'},...
        'OutputActions', {'ValveState', 2,'BNCState',2});
    sma=AddState(sma,'Name', 'WaitPairing',...
        'Timer',2.5,...
        'StateChangeConditions', {'Tup', 'ITI'},...
        'OutputActions', {}); 
    sma = AddState(sma,'Name', 'ITI',...
        'Timer',3,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions',{});
    SendStateMatrix(sma);
 
%% NIDAQ Get nidaq ready to start
if S.GUI.Photometry
     Nidaq_photometry2('WaitToStart');
end
     RawEvents = RunStateMatrix;
    
%% NIDAQ Stop acquisition and save data in bpod structure
if S.GUI.Photometry
    Nidaq_photometry2('Stop');
    BpodSystem.Data.NidaqData{currentTrial} = [nidaq.ai_data nidaq.ao_data(1:size(nidaq.ai_data,1),:)];
end
%% Save
if ~isempty(fieldnames(RawEvents))                                          % If trial data was returned
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);            % Computes trial events from raw data
    BpodSystem.Data.TrialSettings(currentTrial) = S;                        % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.TrialTypes(currentTrial) = TrialSequence(currentTrial); % Adds the trial type of the current trial to data
    SaveBpodSessionData;                                                    % Saves the field BpodSystem.Data to the current data file
end

%% PLOT - extract events from BpodSystem.data and update figures
currentOutcome=Online_LickEvents(S.TrialsMatrix,currentTrial,TrialSequence(currentTrial),S.Names.StateToZero{S.GUI.StateToZero});
FigLick=Online_LickPlot_Air_Stim_Pairing('update',[],[],[],FigLick,currentTrial,currentOutcome);
if S.GUI.Photometry
    [currentNidaq470, nidaqRaw]=Online_NidaqDemod(nidaq.ai_data,nidaq.LED1,S.GUI.LED1_Freq,S.GUI.LED1_Amp,S.Names.StateToZero{S.GUI.StateToZero},currentTrial);
    currentNidaq405=Online_NidaqDemod(nidaq.ai_data,nidaq.LED2,S.GUI.LED2_Freq,S.GUI.LED2_Amp,S.Names.StateToZero{S.GUI.StateToZero},currentTrial);
     FigNidaq=Online_Nidaq2Plot_4class('update',[],[],FigNidaq,currentNidaq470,currentNidaq405,nidaqRaw,TrialSequence(currentTrial));
end
HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.

if BpodSystem.BeingUsed == 0
    return
end
end
end
