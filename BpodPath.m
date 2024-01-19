function BpodPath(Name)
%%Changes the BpodUserPath, registered users are 'Ada', 'Quentin'. 
%%Use 'ini' as an input argument to use the default bpod folder.
%%New user should be add in the BpodPath function file inside the switch
%%command
%%The BpodUserPath should contain protocol, calibration and data folders
%%
%% Designed by Quentin 2017 for kepecslab Bpod

defaultPath='C:\Users\Kepecs\Documents\Bpod';
%% User specific
try
switch Name
    case 'Quentin'
        Path='C:\Users\Kepecs\Documents\Data\Quentin\Bpod';
    case 'Ada'
        Path='C:\Users\Kepecs\Documents\Data\Ada\Bpod';
    case 'Tzvia'
        Path='C:\Users\Kepecs\Documents\Data\Tzvia\Bpod';
    case 'Ele'
        Path='C:\Users\Kepecs\Documents\Data\Ele\Bpod';
    case 'Fengrui'
        Path='C:\Users\Kepecs\Documents\Data\Fengrui\Bpod';
    case 'Keran'
        Path='C:\Users\Kepecs\Documents\Data\Keran\Bpod';
    case 'Amy'
        Path='C:\Users\Kepecs\Documents\Data\Amy\Bpod';
    case 'Sensors'
        Path='C:\Users\Kepecs\Documents\Data\Sensors\Bpod';
    case 'ini'
        Path=defaultPath;
    otherwise        
        Path=['C:\Users\Kepecs\Documents\Data\' Name '\Bpod'];
        disp('Trying to reach')
        disp(Path)
        disp('Consider adding it to BpodPath function')
end

%% Overwritting the txt file
cd(defaultPath);
BpodUserPathTXT=fopen('BpodUserPath.txt','w');
fprintf(BpodUserPathTXT,'%c',Path);
fclose(BpodUserPathTXT);
disp(Path)

catch
    disp('Cannot find the bpod path -- Check BpodPath function - ini to use the default bpod folder');
end
end