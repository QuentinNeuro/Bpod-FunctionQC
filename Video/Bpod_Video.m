function vidObj=Bpod_Video(action,type,vidObj,currentTrial,filepath,filename)
global BpodSystem
switch type
    case 1
        Bpod_Bonsai('Quentin');
        vidObj=[];
    case 2
        if nargin<3
            vidObj=[];
            currentTrial=0;
        end
        vidObj=Bpod_Webcam(action,vidObj,currentTrial);
end
end