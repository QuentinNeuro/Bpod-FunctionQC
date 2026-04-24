classdef WebcamRecorder < handle
    % WebcamRecorder - Background webcam recording with ROI selection
    % 
    % Usage:
    %   recorder = WebcamRecorder();  % Create recorder instance
    %   recorder.start();              % Start recording
    %   recorder.stop();               % Stop recording
    %
    % Properties you can set before starting:
    %   recorder.frameRate = 30;       % Sampling rate (fps)
    %   recorder.outputFile = 'video.avi';
    %   recorder.selectROI = true;     % Enable ROI selection
    
    properties
        frameRate = 30;                % Frames per second
        outputFile = 'webcam_video.avi';  % Filename or full path
        outputPath = '';               % Optional: directory path (empty = current directory)
        videoFormat = 'Motion JPEG AVI';  % Video format
        quality = 90;                  % Video quality (for MPEG-4)
        dispInfo=1;
    end
    
    properties (Access = private)
        cam                            % Webcam object
        videoWriter                    % VideoWriter object
        timerObj                       % Timer for background recording
        roi                            % Region of interest [x, y, width, height]
        isRecording = false;
        frameCount = 0;
    end
    
    methods
        function vidObj = WebcamRecorder()
            % Constructor - initializes webcam
            try
                vidObj.cam = webcam();
            catch ME
                error('Could not initialize webcam: %s', ME.message);
            end
        end
        
        function selectROI(vidObj)
            % Select Region of Interest interactively
            % Call this once before recording to set ROI for all subsequent recordings
            % 
            % Instructions:
            % 1. Click and drag to draw a rectangle around your region of interest
            % 2. Resize/move the rectangle if needed
            % 3. Double-click INSIDE the rectangle to confirm and continue
            
            frame = snapshot(vidObj.cam);
            
            figure('Name', 'Select Region of Interest', 'NumberTitle', 'off');
            imshow(frame);
            title({'Draw rectangle around region of interest', ...
                   'Adjust as needed, then DOUBLE-CLICK INSIDE to confirm'}, ...
                   'FontSize', 12);
            
            % Let user draw ROI
            h = imrect();
            fprintf('Waiting for ROI selection... (double-click inside rectangle to confirm)\n');
            wait(h);  % Wait for double-click
            
            vidObj.roi = getPosition(h);
            close(gcf);
            
            fprintf('ROI confirmed: [x=%.0f, y=%.0f, width=%.0f, height=%.0f]\n', ...
                vidObj.roi(1), vidObj.roi(2), vidObj.roi(3), vidObj.roi(4));
        end
        
        function clearROI(vidObj)
            % Clear ROI to use full frame
            vidObj.roi = [];
            fprintf('ROI cleared - will use full frame\n');
        end
        
        function start(vidObj)
            % Start background recording
            if vidObj.isRecording
                warning('Recording already in progress');
                return;
            end
            
            % Construct full file path
            if isempty(vidObj.outputPath)
                fullPath = vidObj.outputFile;
            else
                % Create directory if it doesn't exist
                if ~exist(vidObj.outputPath, 'dir')
                    mkdir(vidObj.outputPath);
                    fprintf('Created directory: %s\n', vidObj.outputPath);
                end
                fullPath = fullfile(vidObj.outputPath, vidObj.outputFile);
            end
            
            % Get frame size
            frame = snapshot(vidObj.cam);
            if ~isempty(vidObj.roi)
                frame = imcrop(frame, vidObj.roi);
            end
            [height, width, ~] = size(frame);
            
            % Initialize video writer
            vidObj.videoWriter = VideoWriter(fullPath, vidObj.videoFormat);
            vidObj.videoWriter.FrameRate = vidObj.frameRate;
            if strcmp(vidObj.videoFormat, 'MPEG-4')
                vidObj.videoWriter.Quality = vidObj.quality;
            end
            open(vidObj.videoWriter);
            
            % Create and start timer for background recording
            vidObj.timerObj = timer(...
                'ExecutionMode', 'fixedRate', ...
                'Period', 1/vidObj.frameRate, ...
                'TimerFcn', @(~,~)vidObj.captureFrame());
            
            vidObj.isRecording = true;
            vidObj.frameCount = 0;
            
            start(vidObj.timerObj);
            if vidObj.dispInfo
            fprintf('Recording started: %s at %d fps\n', fullPath, vidObj.frameRate);
            if ~isempty(vidObj.roi)
                fprintf('Using ROI: [x=%.0f, y=%.0f, width=%.0f, height=%.0f]\n', ...
                    vidObj.roi(1), vidObj.roi(2), vidObj.roi(3), vidObj.roi(4));
            else
                fprintf('Using full frame\n');
            end
            end
        end
        
        function stop(vidObj)
            % Stop background recording
            if ~vidObj.isRecording
                warning('No recording in progress');
                return;
            end
            
            % Stop and delete timer
            stop(vidObj.timerObj);
            delete(vidObj.timerObj);
            vidObj.timerObj = [];
            
            % Get the full path before closing
            fullPath = vidObj.videoWriter.Path;
            
            % Close video writer
            close(vidObj.videoWriter);
            vidObj.videoWriter = [];
            
            vidObj.isRecording = false;
            if vidObj.dispInfo
                fprintf('Recording stopped: %d frames captured\n', vidObj.frameCount);
                fprintf('Video saved to: %s\n', fullPath);
            end
        end
        
        function delete(vidObj)
            % Destructor - cleanup
            if vidObj.isRecording
                vidObj.stop();
            end
            if ~isempty(vidObj.cam)
                clear obj.cam;
            end
        end
    end
    
    methods (Access = private)
        function captureFrame(vidObj)
            % Capture and write a single frame (called by timer)
            try
                frame = snapshot(vidObj.cam);
                
                % Crop to ROI if specified
                if ~isempty(vidObj.roi)
                    frame = imcrop(frame, vidObj.roi);
                end
                
                % Write frame
                writeVideo(vidObj.videoWriter, frame);
                vidObj.frameCount = vidObj.frameCount + 1;
                
            catch ME
                warning('Error capturing frame: %s', ME.message);
            end
        end
    end
end