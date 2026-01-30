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
        dispInfo=0;
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
        function obj = WebcamRecorder()
            % Constructor - initializes webcam
            try
                obj.cam = webcam();
            catch ME
                error('Could not initialize webcam: %s', ME.message);
            end
        end
        
        function selectROI(obj)
            % Select Region of Interest interactively
            % Call this once before recording to set ROI for all subsequent recordings
            % 
            % Instructions:
            % 1. Click and drag to draw a rectangle around your region of interest
            % 2. Resize/move the rectangle if needed
            % 3. Double-click INSIDE the rectangle to confirm and continue
            
            frame = snapshot(obj.cam);
            
            figure('Name', 'Select Region of Interest', 'NumberTitle', 'off');
            imshow(frame);
            title({'Draw rectangle around region of interest', ...
                   'Adjust as needed, then DOUBLE-CLICK INSIDE to confirm'}, ...
                   'FontSize', 12);
            
            % Let user draw ROI
            h = imrect();
            fprintf('Waiting for ROI selection... (double-click inside rectangle to confirm)\n');
            wait(h);  % Wait for double-click
            
            obj.roi = getPosition(h);
            close(gcf);
            
            fprintf('ROI confirmed: [x=%.0f, y=%.0f, width=%.0f, height=%.0f]\n', ...
                obj.roi(1), obj.roi(2), obj.roi(3), obj.roi(4));
        end
        
        function clearROI(obj)
            % Clear ROI to use full frame
            obj.roi = [];
            fprintf('ROI cleared - will use full frame\n');
        end
        
        function start(obj)
            % Start background recording
            if obj.isRecording
                warning('Recording already in progress');
                return;
            end
            
            % Construct full file path
            if isempty(obj.outputPath)
                fullPath = obj.outputFile;
            else
                % Create directory if it doesn't exist
                if ~exist(obj.outputPath, 'dir')
                    mkdir(obj.outputPath);
                    fprintf('Created directory: %s\n', obj.outputPath);
                end
                fullPath = fullfile(obj.outputPath, obj.outputFile);
            end
            
            % Get frame size
            frame = snapshot(obj.cam);
            if ~isempty(obj.roi)
                frame = imcrop(frame, obj.roi);
            end
            [height, width, ~] = size(frame);
            
            % Initialize video writer
            obj.videoWriter = VideoWriter(fullPath, obj.videoFormat);
            obj.videoWriter.FrameRate = obj.frameRate;
            if strcmp(obj.videoFormat, 'MPEG-4')
                obj.videoWriter.Quality = obj.quality;
            end
            open(obj.videoWriter);
            
            % Create and start timer for background recording
            obj.timerObj = timer(...
                'ExecutionMode', 'fixedRate', ...
                'Period', 1/obj.frameRate, ...
                'TimerFcn', @(~,~)obj.captureFrame());
            
            obj.isRecording = true;
            obj.frameCount = 0;
            
            start(obj.timerObj);
            if obj.dispInfo
            fprintf('Recording started: %s at %d fps\n', fullPath, obj.frameRate);
            if ~isempty(obj.roi)
                fprintf('Using ROI: [x=%.0f, y=%.0f, width=%.0f, height=%.0f]\n', ...
                    obj.roi(1), obj.roi(2), obj.roi(3), obj.roi(4));
            else
                fprintf('Using full frame\n');
            end
            end
        end
        
        function stop(obj)
            % Stop background recording
            if ~obj.isRecording
                warning('No recording in progress');
                return;
            end
            
            % Stop and delete timer
            stop(obj.timerObj);
            delete(obj.timerObj);
            obj.timerObj = [];
            
            % Get the full path before closing
            fullPath = obj.videoWriter.Path;
            
            % Close video writer
            close(obj.videoWriter);
            obj.videoWriter = [];
            
            obj.isRecording = false;
            if obj.dispInfo
                fprintf('Recording stopped: %d frames captured\n', obj.frameCount);
                fprintf('Video saved to: %s\n', fullPath);
            end
        end
        
        function delete(obj)
            % Destructor - cleanup
            if obj.isRecording
                obj.stop();
            end
            if ~isempty(obj.cam)
                clear obj.cam;
            end
        end
    end
    
    methods (Access = private)
        function captureFrame(obj)
            % Capture and write a single frame (called by timer)
            try
                frame = snapshot(obj.cam);
                
                % Crop to ROI if specified
                if ~isempty(obj.roi)
                    frame = imcrop(frame, obj.roi);
                end
                
                % Write frame
                writeVideo(obj.videoWriter, frame);
                obj.frameCount = obj.frameCount + 1;
                
            catch ME
                warning('Error capturing frame: %s', ME.message);
            end
        end
    end
end