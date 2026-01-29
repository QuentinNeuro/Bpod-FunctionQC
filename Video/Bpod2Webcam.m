function recorder=Bpod2Webcam(action,filepath,filename,recorder)

switch action
    case 'ini'
        clear recorder
        recorder = WebcamRecorder();
        recorder.frameRate = 20;
        recorder.videoFormat = 'MPEG-4';  % Smaller file size
        recorder.quality = 90;
        recorder.filepath=filepath;
        mkdir(filepath)
        recorder.selectROI();
    case 'start'
        recorder.outputFile=filename;
        recorder.outputPath=filename;
        recorder.start();
    case 'stop'
         recorder.stop();
end