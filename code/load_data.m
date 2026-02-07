%% Bubble Entropy Project - Load Data Function

function rr_data = load_data(data_folder)
% Loads ECG files, extracts QRS locations, and calculates RR intervals

    % Find all header files (.hea) to identify patient records
    hea_files = dir(fullfile(data_folder, '*.hea'));
    
    if isempty(hea_files)
        warning('No .hea files found in %s. Check data path and file extension.', data_folder);
        rr_data = {};
        return;
    end
    
    rr_data = {};

    for i = 1:length(hea_files)
        try
            % Get base filename
            [~, basename, ~] = fileparts(hea_files(i).name);
            
            % Read raw signal and sampling frequency using the local helper function
            header_file = fullfile(data_folder, [basename '.hea']);
            [Fs, signal] = read_files(header_file);
            
            if isempty(signal)
                fprintf('Skipping %s: Could not read signal data.\n', basename);
                continue;
            end
            
            % Use the first channel (ECG 1) for QRS detection.
            ecg = signal(:, 1);
            
            % QRS Detection using findpeaks
            % Initial threshold based on 0.5 * STD above the mean
            initial_threshold = mean(ecg) + 0.5*std(ecg);
            % Minimum peak distance enforced by 0.3 seconds
            min_peak_distance_samples = round(0.3 * Fs); 
            
            [~, qrs_locs] = findpeaks(ecg, 'MinPeakHeight', initial_threshold, ...
                                      'MinPeakDistance', min_peak_distance_samples);
            
            % If initial detection yields few peaks, use a lower threshold
            if length(qrs_locs) < 10
                fallback_threshold = mean(ecg) + 0.3*std(ecg);
                [~, qrs_locs] = findpeaks(ecg, 'MinPeakHeight', fallback_threshold, ...
                                          'MinPeakDistance', min_peak_distance_samples);
            end
                
            % Calculate RR intervals
            if length(qrs_locs) > 2
                % RR intervals = difference in QRS sample locations / sampling frequency
                rr_intervals = diff(qrs_locs) / Fs;
                rr_data{end+1} = rr_intervals;
                fprintf('Extracted %d RR intervals from %d QRS peaks\n', length(rr_intervals), length(qrs_locs));
            else
                fprintf('Warning: Too few QRS detections (%d) in %s. Skipping record.\n', length(qrs_locs), basename);
            end
            
        catch ME
            % Log errors without crashing the entire script
            fprintf('Error processing %s: %s\n', basename, ME.message);
        end
    end
end


% Local Helper Function
function [Fs, signal] = read_files(header_file)
% Reads the .ecg file and extracts Fs from the .hea file
    
    signal = [];
    Fs = 0; % Initialize sampling frequency
    
    try
        % Read Header (.hea) for Sampling Frequency (Fs)
        fid = fopen(header_file, 'r');
        if fid == -1
            error('Cannot open header file');
        end
        
        % Read first line, which contains metadata including Fs
        first_line = fgetl(fid);
        parts = strsplit(first_line);
        if length(parts) >= 3
            Fs = str2double(parts{3}); % Fs is the third element
        end
        
        fclose(fid);
        
        if Fs == 0
            Fs = 128; % Default fallback to common PhysioNet sampling rate
        end
        
        % Locate Data File (.ecg)
        [folder, basename, ~] = fileparts(header_file);
        ecg_file = fullfile(folder, [basename '.ecg']);
        
        if exist(ecg_file, 'file')
            data_filename = ecg_file;
        else
            error('No data file found for %s', basename);
        end
        
        % Read binary data
        fid = fopen(data_filename, 'r');
        if fid == -1
            error('Cannot open data file');
        end
        
        % Read all data as 16-bit signed integers
        signal_data = fread(fid, 'int16');
        fclose(fid);
        
        % Reshape Signal (handle multi-channel data)
        num_channels = 2;
        if mod(length(signal_data), num_channels) == 0
            % Reshape data: Columns=Channels, Rows=Samples
            signal = reshape(signal_data, num_channels, [])';
        else
            % Assume single channel if reshape fails cleanly
            signal = signal_data;
        end
        
    catch ME
        % If file reading or parsing fails, return empty signal
        fprintf('Error reading files: %s\n', ME.message);
    end
end