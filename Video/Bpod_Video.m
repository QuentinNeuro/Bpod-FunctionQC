function vidObj=Bpod_Video(action,type,vidObj,currentTrial,filepath,filename)
global BpodSystem

switch type
    case 1
        Bpod2Bonsai_Quentin();
        vidObj=[];
    case 2
       switch action
           case 'ini' % Initialie webcam recording - Should be before main trial loop
                clear vidObj
                vidObj = WebcamRecorder();
                vidObj.frameRate = 20;
                vidObj.videoFormat = 'MPEG-4';  % Smaller file size
                vidObj.quality = 90;
                % File Path
                if nargin<5
                    try
                        [filepath,filename]=fileparts(BpodSystem.Path.CurrentDataFile);
                        filepath=[filepath filesep filename];
                        mkdir(filepath);
                        vidObj.outputPath=filepath;
                    catch
                        disp('Warning - videos will be saved in current folder path')
                    end
                end
                vidObj.selectROI();
   
           case 'Start' % Start webcam recording - before RunStateMatrix
               if nargin<6
                   try
                   [~,filename]=fileparts(BpodSystem.Path.CurrentDataFile);
                   vidObj.outputFile=sprintf('%s_%.0d',filename,currentTrial);
                   catch
                       disp('Warning - default video name')
                   end
               end
                vidObj.start(); % Stop webcam recording - after RunStateMatrix
           case 'Stop'
                 vidObj.stop();
           case 'Flush'
               vidObj.delete();
       end
end
end