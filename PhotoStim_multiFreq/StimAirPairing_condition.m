function StimAirPairing_condition
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
    Bpod1_TaskParameters_AirStimPairing_1();
    S.SoundRamping=0.2;         %sec
    S.MeanSoundFrequencyA = 500;   %Hz
    S.MeanSoundFrequencyB = 5000;  %Hz
    S.WidthOfFrequencies=2;
    S.NumberOfFrequencies=5;
    S.RewardAmount=10;
    S.SoundDuration1=1;
    S.SoundDuration2=1;
end

% Initialize parameter GUI plugin and Pause
BpodParameterGUI('init', S);
BpodSystem.Pause=1;
HandlePauseCondition;
S = BpodParameterGUI('sync', S);

%% Define trial types parameters, trial sequence and Initialize plots
[S.TrialsNames, S.TrialsMatrix]=Air_Stim_Pairing_Phase_condition(S,S.Names.Phase{S.GUI.Phase});  % choose Air_Stim_Pairing
TrialSequence=WeightedRandomTrials(S.TrialsMatrix(:,2)', S.GUI.MaxTrials);
S.NumTrialTypes=max(TrialSequence);
FigLick=Online_LickPlot_Air_Stim_Pairing('ini',TrialSequence,S.TrialsMatrix,S.TrialsNames,S.Names.Phase{S.GUI.Phase});

%% NIDAQ Initialization
if S.GUI.Photometry
    Nidaq_photometry1('ini');
    FigNidaq=Online_Nidaq1Plot_4class('ini',S.TrialsNames,S.Names.Phase{S.GUI.Phase}); %'Air_Stim_Pairing'
end
%%
SF = 192000; % Sound card sampling rate
PsychToolboxSoundServer('init');
BpodSystem.SoftCodeHandlerFunction = 'SoftCodeHandler_PlaySound';
Sound1=SoundGenerator(SF, S.MeanSoundFrequencyA, S.WidthOfFrequencies, S.NumberOfFrequencies, S.SoundDuration1, S.SoundRamping);
PsychToolboxSoundServer('Load', 1, Sound1);  

Sound2=SoundGenerator(SF, S.MeanSoundFrequencyB, S.WidthOfFrequencies, S.NumberOfFrequencies, S.SoundDuration2, S.SoundRamping);
Sound2= fliplr(Sound2);
PsychToolboxSoundServer('Load', 2, Sound2);
    
%% sound generation

BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
%% Main trial loop
for currentTrial = 1:S.GUI.MaxTrials
   switch TrialSequence(currentTrial) % Determine trial-specific state matrix fields
        case 1
          load('C:\Users\Kepecs\Documents\Data\Ada\Bpod\Protocols\StimAirPairing_condition\LightTrain_40hz.mat');
        case 2
          load('C:\Users\Kepecs\Documents\Data\Ada\Bpod\Protocols\StimAirPairing_condition\LightTrain_60hz.mat');
        case 3
          load('C:\Users\Kepecs\Documents\Data\Ada\Bpod\Protocols\StimAirPairing_condition\LightTrain_100hz.mat');
        case 4
          load('C:\Users\Kepecs\Documents\Data\Ada\Bpod\Protocols\StimAirPairing_condition\LightTrain_125hz.mat');
    end
ProgramPulsePal(ParameterMatrix);
S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin 
      
%% Assemble State matrix
 	sma = NewStateMatrix();
    sma = AddState(sma, 'Name','PreState',...
        'Timer',5,...
        'StateChangeConditions',{'Tup','Pairing'},...
        'OutputActions',{}); 
    if TrialSequence(currentTrial)==1 
    sma=AddState(sma,'Name', 'Pairing',...
        'Timer', 0.5,...
        'StateChangeConditions', {'Tup', 'PostResponse'},...
        'OutputActions', {'ValveState', 2,'BNCState',2});  
    elseif TrialSequence(currentTrial)==2
    sma=AddState(sma,'Name', 'Pairing',...
        'Timer',0.5,...
        'StateChangeConditions', {'Tup', 'PostResponse'},...
        'OutputActions', {'BNCState',2});  
    elseif TrialSequence(currentTrial)==3
    sma=AddState(sma,'Name', 'Pairing',...
        'Timer', 0.5,...
        'StateChangeConditions', {'Tup', 'PostResponse'},...
        'OutputActions', {'ValveState', 2});  
    elseif TrialSequence(currentTrial)==4
    sma=AddState(sma,'Name', 'Pairing',...
        'Timer', 0.5,...
        'StateChangeConditions', {'Tup', 'PostResponse'},...
        'OutputActions', {});  
    end
    sma=AddState(sma,'Name', 'PostResponse',...
        'Timer',7,...
        'StateChangeConditions', {'Tup', 'exit'},...
        'OutputActions', {});
    SendStateMatrix(sma);
 
%% NIDAQ Get nidaq ready to start
if S.GUI.Photometry
     Nidaq_photometry1('WaitToStart');
end
     RawEvents = RunStateMatrix;
    
%% NIDAQ Stop acquisition and save data in bpod structure
if S.GUI.Photometry
    Nidaq_photometry1('Stop');
    BpodSystem.Data.NidaqData{currentTrial} = nidaq.ai_data;
end
%% Save
if ~isempty(fieldnames(RawEvents))                                          % If trial data was returned
    BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);            % Computes trial events from raw data
    BpodSystem.Data.TrialSettings(currentTrial) = S;                        % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
    BpodSystem.Data.TrialTypes(currentTrial) = TrialSequence(currentTrial); % Adds the trial type of the current trial to data
    SaveBpodSessionData;                                                    % Saves the field BpodSystem.Data to the current data file
end

%% PLOT - extract events from BpodSystem.data and update figures
[currentOutcome, currentLickEvents]=Online_LickEvents_4class(currentTrial,S.Names.StateToZero{S.GUI.StateToZero});
FigLick=Online_LickPlot_Air_Stim_Pairing('update',[],[],[],[],FigLick,currentTrial,currentOutcome,TrialSequence(currentTrial),currentLickEvents);
if S.GUI.Photometry
     currentNidaq=Online_Nidaq1Events(nidaq.ai_data,currentTrial,S.Names.StateToZero{S.GUI.StateToZero});
     FigNidaq=Online_Nidaq1Plot_4class('update',[],[],FigNidaq,currentNidaq,TrialSequence(currentTrial));
end
HandlePauseCondition; % Checks to see if the protocol is paused. IfBpodPath('Ada') so, waits until user resumes.

if BpodSystem.BeingUsed == 0
    return
end
end
end
