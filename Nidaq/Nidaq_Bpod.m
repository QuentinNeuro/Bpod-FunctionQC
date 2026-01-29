function Nidaq_Bpod(action,currentTrial)
global nidaq S BpodSystem

switch action
        case 'ini'
%% General parameters
nidaq=[];
nidaq.settings.device='Dev1';
nidaq.settings.duration=S.GUI.NidaqDuration;
nidaq.settings.samplingrate=S.GUI.NidaqSamplingRate;

%% Initialize variables for mapping and data collection
nidaq.output.list=[];
nidaq.input.list=[];
nidaq.rec.ao_data=[];
nidaq.rec.ai_data=[];

%% Output parameters
if S.GUI.Photometry
    %% Map GUI fields to output parameters for sinewave generation
    nidaq.output.ao0.amplitude='LED1_Amp';
    nidaq.output.ao0.frequency='LED1_Freq';
    nidaq.output.ao0.phase='modPhase';
    nidaq.output.ao1.amplitude='LED2_Amp';
    nidaq.output.ao1.frequency='LED2_Freq';
    nidaq.output.ao1.phase='modPhase';
    
%% Input/Output mapping
    nidaq.input.list{1}='ai0';
    nidaq.output.list{1}='ao0';
    if S.GUI.Isobestic405
        nidaq.input.list{2}='ai0';
        nidaq.output.list{2}='ao1';
    end
    if xor(S.GUI.RedChannel,S.GUI.DbleFibers)
        nidaq.input.list{2}='ai1';
        nidaq.input.list{2}='ao1';
    end
    % Dble fibers, dble channels
    if and(S.GUI.RedChannel,S.GUI.DbleFibers)
        nidaq.input.list    = {'ai0','ai1','ai2','ai3'};
        nidaq.output.list   = {'ao0','ao1','ao0','ao1'};
    end
end

%% DAQ session Initialization
nidaq.session = daq('ni');
nidaq.session.Rate = nidaq.settings.samplingrate;
% Inputs
for ch = unique(nidaq.input.list)
    addinput(nidaq.session,nidaq.settings.device,ch,'Voltage');
end
% Outputs
for ch = unique(nidaq.output.list)
    addoutput(nidaq.session,nidaq.settings.device,ch,'Voltage');
end
% Wheel
if S.GUI.Wheel
    addinput(nidaq.session,nidaq.settings.device,'ctr0','Position');
    % nidaq.counter.EncoderType = 'X1';
end

% Set up the callback function to collect the data and store them in nidaq.rec.ai_data 
nidaq.session.ScansAvailableFcn = @Nidaq_callback_nested;
nidaq.session.ScansAvailableFcnCount = nidaq.settings.samplingrate / 5;

    case 'WaitToStart'
nidaq.rec.ai_data=[];
nidaq.rec.ao_data=[];

for ch = unique(nidaq.output.list)
    c=cell2mat(ch);
    nidaq.rec.ao_data(:,end+1)=Photometry_mod(S.GUI.(nidaq.output.(c).amplitude),S.GUI.(nidaq.output.(c).frequency),S.GUI.(nidaq.output.(c).phase),...
        nidaq.settings.samplingrate, S.GUI.NidaqDuration, S.GUI.Modulation);
end

preload(nidaq.session,nidaq.rec.ao_data);
start(nidaq.session, "continuous");

    case 'Stop'
%% STOP NIDAQ and get the output to zero
stop(nidaq.session)
flush(nidaq.session) % requiered before sending output to zero
write(nidaq.session,zeros(1,size(nidaq.rec.ao_data,2)));

    case 'Save'
%% Organize data in BpodSystsem structure
if S.GUI.Photometry
    % Saves settings and modulation command only on the first trial
    if currentTrial==1 
        BpodSystem.Data.Photometry.settings=nidaq.settings;
        BpodSystem.Data.Photometry.output=nidaq.output;
        BpodSystem.Data.Photometry.input=nidaq.input;
        co=1;
        for ch = unique(nidaq.output.list)
            c=cell2mat(ch);
            BpodSystem.Data.Photometry.Data.(c)=nidaq.rec.ao_data(:,co);
            co=co+1;
        end
    end
    % Saves input data
    ci=1;
    for ch = unique(nidaq.input.list)
        c=cell2mat(ch);
        BpodSystem.Data.Photometry.Data.(c){currentTrial}=nidaq.rec.ai_data(:,ci);
        ci=ci+1;
    end
end
    % Saves wheel data
    if S.GUI.Wheel
        BpodSystem.Data.Wheel.Data{currentTrial} = nidaq.rec.ai_data(:,end);
    end
end

function Nidaq_callback_nested(src,~)
    [data, ~] = read(src, src.ScansAvailableFcnCount, "OutputFormat", "Matrix");
    nidaq.rec.ai_data = [nidaq.rec.ai_data; data];
end
end