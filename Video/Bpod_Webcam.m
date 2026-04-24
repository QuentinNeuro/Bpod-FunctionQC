function vidObj=Bpod_Webcam(action,vidObj,currentTrial)
global BpodSystem

switch action
   case 'ini' % Initialie webcam recording - Should be before main trial loop
        clear vidObj
        vidObj = WebcamRecorder_log();
        % vidObj.frameRate = 20;
        vidObj.videoFormat = 'MPEG-4';  % Smaller file size
        vidObj.quality = 90;
        % File Path
        [filepath,filename]=fileparts(BpodSystem.Path.CurrentDataFile);
        filepath=[filepath filesep filename];
        mkdir(filepath);
        vidObj.outputPath=filepath;
        % ROI
        vidObj.selectROI();

   case 'Start' % Start webcam recording - before RunStateMatrix
       [~,filename]=fileparts(BpodSystem.Path.CurrentDataFile);
       vidObj.outputFile=sprintf('%s_%.0d',filename,currentTrial);
       vidObj.start(); % Stop webcam recording - after RunStateMatrix

   case 'Stop'
       vidObj.stop();
       
   case 'Flush'
       vidObj.delete();
end
end