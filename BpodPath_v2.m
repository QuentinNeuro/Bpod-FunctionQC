function BpodPath_v2(varargin)
%%Adjust bpod folders - data and protocol - to make it user-specific.
%% Designed by Quentin 2026 for PBI ePHYS plateform
global BpodSystem
%% Default Bpod path
defaultBpodPath='E:\Bpod\Bpod Local\';
defaultUserPath='E:\Bpod\Bpod-Data\';

%% Inputs
% Parse inputs from varargin
p = inputParser();  
% Define expected parameters with defaults
addParameter(p, 'username',     []);
addParameter(p, 'userpath',    []);

% Parse the inputs
parse(p, varargin{:});
username    = p.Results.username;
userpath   =  p.Results.userpath;


%% Build Bpod path
if ~isempty(username)
    if isempty(userpath)
        bpodpath=[defaultUserPath username filesep];
    else
        bpodpath=[userpath filesep username filesep];
    end
    if ~exist(bpodpath,'dir')
        bpodpath
        disp('Bpod user does not exist, check BpodPath_v2')
        bpodpath=defaultBpodPath;
    end
else
    bpodpath=defaultBpodPath;
end

bpodpath_protocols=[bpodpath 'protocols' filesep];
bpodpath_data=[bpodpath 'data' filesep];

%% Set Bpod path  
BpodSystem.Path.ProtocolFolder=bpodpath_protocols;
BpodSystem.Path.DataFolder=bpodpath_data;
BpodSystem.SystemSettings.ProtocolFolder = bpodpath_protocols;
BpodSystem.SystemSettings.DataFolder     = bpodpath_data;
BpodSystem.SaveSettings;

end