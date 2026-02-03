classdef WebcamRecorder_log < handle
    % WebcamRecorder - Background webcam recording using videoinput logging
    % 
    % Usage:
    %   recorder = WebcamRecorder();  % Create recorder instance
    %   recorder.start();              % Start recording
    %   recorder.stop();               % Stop recording
    %
    % Properties you can set before starting:
    %   recorder.frameRate = 30;       % Sampling rate (fps)
    %   recorder.outputFile = 'video.avi';
    %   recorder.outputPath = '';      % Directory path
    
    properties
        frameRate = 30;                % Frames per second
        outputFile = 'webcam_video.avi';  % Filename or full path
        outputPath = '';               % Optional: directory path (empty = current directory)
        videoFormat = 'Motion JPEG AVI';  % Video format
        quality = 90;                  % Video quality (for MPEG-4)
        deviceID = 1;                  % Camera device ID (usually 1)
        videoResolution = '';          % Video resolution (empty = default)
        keepAlive = true;              % Keep videoinput object alive between recordings (faster start)
    end
    
    properties (Access = private)
        vid                            % videoinput object
        roi                            % Region of interest [x, y, width, height]
        isRecording = false;
        tempLogFile                    % Temporary log file path
        finalOutputPath                % Final output path with ROI cropping
        actualFrameRate                % Actual frame rate being used
    end
    
    methods
        function obj = WebcamRecorder_log()
            % Constructor - initializes webcam
            info = imaqhwinfo('winvideo');
            if isempty(info.DeviceIDs)
                error('No webcam devices found');
            end
            fprintf('Available camera devices:\n');
            for i = 1:length(info.DeviceIDs)
                fprintf('  Device %d: %s\n', info.DeviceIDs{i}, info.DeviceInfo(i).DeviceName);
            end
            
            % Pre-create videoinput object for faster starts
            obj.vid = videoinput('winvideo', obj.deviceID);
            
            % Set resolution if specified
            if ~isempty(obj.videoResolution)
                obj.vid.VideoResolution = obj.videoResolution;
            end
            
            % Get actual frame rate
            src = getselectedsource(obj.vid);
            try
                obj.actualFrameRate = str2double(src.FrameRate);
            catch
                obj.actualFrameRate = obj.frameRate;
            end
            
            fprintf('Camera initialized (Device %d)\n', obj.deviceID);
        end
        
        function selectROI(obj)
            % Select Region of Interest interactively
            % Call this once before recording to set ROI for all subsequent recordings
            % 
            % Instructions:
            % 1. Click and drag to draw a rectangle around your region of interest
            % 2. Resize/move the rectangle if needed
            % 3. Double-click INSIDE the rectangle to confirm and continue
            
            % Get a snapshot from the existing videoinput object
            frame = getsnapshot(obj.vid);
            
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
            
            % Adjust ROI dimensions to be even numbers (required for H.264/MPEG-4)
            obj.roi(3) = round(obj.roi(3) / 2) * 2;  % width (make even)
            obj.roi(4) = round(obj.roi(4) / 2) * 2;  % height (make even)
            
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
            % Start background recording using logging mode
            if obj.isRecording
                warning('Recording already in progress');
                return;
            end
            
            % Construct final output path
            if isempty(obj.outputPath)
                obj.finalOutputPath = obj.outputFile;
            else
                % Create directory if it doesn't exist
                if ~exist(obj.outputPath, 'dir')
                    mkdir(obj.outputPath);
                    fprintf('Created directory: %s\n', obj.outputPath);
                end
                obj.finalOutputPath = fullfile(obj.outputPath, obj.outputFile);
            end
            
            % Configure for logging mode
            if isempty(obj.roi)
                % No ROI - log directly to final file
                obj.vid.LoggingMode = 'disk';
                
                % Create video file object
                logfile = VideoWriter(obj.finalOutputPath, obj.videoFormat);
                logfile.FrameRate = obj.frameRate;
                if strcmp(obj.videoFormat, 'MPEG-4')
                    logfile.Quality = obj.quality;
                end
                
                obj.vid.DiskLogger = logfile;
                obj.tempLogFile = '';
            else
                % With ROI - log to memory first, then crop and save
                obj.vid.LoggingMode = 'memory';
                
                % Set to continuous acquisition (Inf frames)
                obj.vid.FramesPerTrigger = Inf;
                
                obj.tempLogFile = 'memory';
            end
            
            % Set frame rate
            src = getselectedsource(obj.vid);
            
            try
                % Try to set the requested frame rate
                src.FrameRate = num2str(obj.frameRate);
                obj.actualFrameRate = str2double(src.FrameRate);
            catch
                % If setting fails, get the actual frame rate being used
                try
                    obj.actualFrameRate = str2double(src.FrameRate);
                    fprintf('Using camera default: %d fps\n', obj.actualFrameRate);
                catch
                    % If we can't even read it, use requested as estimate
                    obj.actualFrameRate = obj.frameRate;
                end
            end
            
            % Start acquisition
            start(obj.vid);
            obj.isRecording = true;
            
            fprintf('Recording started: %s at %d fps\n', obj.finalOutputPath, obj.actualFrameRate);
            if ~isempty(obj.roi)
                fprintf('Using ROI: [x=%.0f, y=%.0f, width=%.0f, height=%.0f]\n', ...
                    obj.roi(1), obj.roi(2), obj.roi(3), obj.roi(4));
            end
        end
        
        function stop(obj)
            % Stop background recording
            if ~obj.isRecording
                warning('No recording in progress');
                return;
            end
            
            % Stop acquisition
            stop(obj.vid);
            
            framesCaptured = obj.vid.FramesAcquired;
            fprintf('Recording stopped: %d frames captured\n', framesCaptured);
            
            % Process ROI if needed
            if ~isempty(obj.roi)
                fprintf('Processing ROI cropping...\n');
                
                % Wait for frames to be available
                framesAvailable = obj.vid.FramesAvailable;
                if framesAvailable == 0
                    warning('No frames available to save');
                    obj.isRecording = false;
                    flushdata(obj.vid);  % Clear buffer
                    return;
                end
                
                fprintf('Retrieving %d frames from memory...\n', framesAvailable);
                
                % Get all available frames from memory
                [frames, ~, metadata] = getdata(obj.vid, framesAvailable);
                
                % Create output video writer
                outputVideo = VideoWriter(obj.finalOutputPath, obj.videoFormat);
                outputVideo.FrameRate = obj.actualFrameRate;
                if strcmp(obj.videoFormat, 'MPEG-4')
                    outputVideo.Quality = obj.quality;
                end
                open(outputVideo);
                
                % Crop and write each frame
                numFrames = size(frames, 4);
                fprintf('Cropping and saving %d frames...\n', numFrames);
                for i = 1:numFrames
                    frame = frames(:, :, :, i);
                    cropped = imcrop(frame, obj.roi);
                    
                    % Ensure dimensions are even (for H.264 codec compatibility)
                    [h, w, ~] = size(cropped);
                    if mod(w, 2) ~= 0
                        cropped = cropped(:, 1:end-1, :);  % Remove last column
                    end
                    if mod(h, 2) ~= 0
                        cropped = cropped(1:end-1, :, :);  % Remove last row
                    end
                    
                    writeVideo(outputVideo, cropped);
                    
                    % Progress indicator every 100 frames
                    if mod(i, 100) == 0
                        fprintf('  Processed %d/%d frames\n', i, numFrames);
                    end
                end
                
                close(outputVideo);
                fprintf('ROI cropping complete\n');
            else
                % Flush data from disk logger
                flushdata(obj.vid);
            end
            
            obj.isRecording = false;
            
            fprintf('Video saved to: %s\n', obj.finalOutputPath);
        end
        
        function delete(obj)
            % Destructor - cleanup
            if obj.isRecording
                obj.stop();
            end
            if ~isempty(obj.vid) && isvalid(obj.vid)
                delete(obj.vid);
            end
        end
    end
end