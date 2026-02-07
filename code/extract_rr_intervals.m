%% Bubble Entropy Project - Extract RR Intervals Function

function rr_clean = extract_rr_intervals(rr_data)
% Cleans, detrends, and normalizes raw RR interval data.

    min_rr_length = 100; % Minimum acceptable raw record length
    
    % Initialize the output cell array.
    rr_clean = {};

    for i = 1:length(rr_data)
        rr = rr_data{i};
        
        % Skip records that are empty or too short
        if length(rr) >= min_rr_length
            rr_clean = cell(size(rr_data));

            for i = 1:length(rr_data)
                rr = rr_data{i};

                if isempty(rr)
                    continue;
                end
                
                % --- Outlier Removal ---
                % Remove obvious non-physiological RR intervals
                valid_idx = (rr > 0.3) & (rr < 2.0);  % 300ms to 2000ms
                rr_filtered = rr(valid_idx);
                
                if length(rr_filtered) < 50
                    % Skip records if outlier removal leaves too few data points
                    rr_clean{i} = [];
                    continue;
                end
                
                % --- Trend Removal ---
                % Remove the slow-moving baseline trend
        
                % Determine an adaptive window size for the moving median filter
                window_size = min(51, floor(length(rr_filtered)/4));
                if mod(window_size, 2) == 0
                    window_size = window_size - 1; % Ensure window size is odd for symmetry
                end
                
                % Calculate the trend component (baseline fluctuation)
                trend = movmedian(rr_filtered, window_size);
                rr_detrended = rr_filtered - trend + mean(rr_filtered);
                
                % --- Normalization ---
                % Normalize the detrended series to zero mean and unit standard deviation
                % This ensures r=0.2 in SampEn is equivalent to 0.2 * STD for every signal
                rr_normalized = (rr_detrended - mean(rr_detrended)) / std(rr_detrended);
                
                % Store the cleaned, processed vector
                rr_clean{i} = rr_normalized;
            end
            
            % Remove any empty cells that were skipped during processing
            rr_clean = rr_clean(~cellfun(@isempty, rr_clean));
        end
    end
 end