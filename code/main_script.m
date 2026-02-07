%% Bubble Entropy Project - Main Analysis Script
clear; clc; close all;

%% Path Setup
% Get the folder of the current script (main_script.m)
current_folder = fileparts(mfilename('fullpath'));

% Find the project root folder
project_root = fileparts(current_folder);

% Define the path to the 'data' folder
data_path = fullfile(project_root, 'data');

% Add the current folder to the path
addpath(current_folder);

%% Parameters
m_range = 3:15;  % Range of embedding dimensions (m) to test for Bubble Entropy
r_sampen = 0.2;  % Tolerance (r) for Sample Entropy
m_sampen = 2;    % Embedding dimension (m) for Sample Entropy

%% Load and Preprocess Data
% Load ECG recordings from PhysioNet databases (nsr: Normal Sinus Rhythm; chf: Congestive Heart Failure)
fprintf('Loading NSR data...\n');
nsr_data = load_data(fullfile(data_path, 'nsr')); 

fprintf('Loading CHF data...\n');
chf_data = load_data(fullfile(data_path, 'chf'));

fprintf('Loaded %d NSR records and %d CHF records\n', length(nsr_data), length(chf_data));

% Validate minimum record count for statistical viability
if length(nsr_data) < 5 || length(chf_data) < 5
    error('Insufficient data loaded. Please check your data files. They should be in the ''data'' subfolder.');
end

%% Preprocess RR intervals
fprintf('Preprocessing RR intervals...\n');

nsr_rr_clean = extract_rr_intervals(nsr_data);
chf_rr_clean = extract_rr_intervals(chf_data);

%% Calculate Entropy Measures
% Initialize result matrices to store entropy values for each patient across all m values
fprintf('Calculating entropy measures...\n');

results.bubble_nsr = zeros(length(nsr_rr_clean), length(m_range));
results.bubble_chf = zeros(length(chf_rr_clean), length(m_range));
results.sampen_nsr = zeros(length(nsr_rr_clean), 1);
results.sampen_chf = zeros(length(chf_rr_clean), 1);

% Calculate Bubble Entropy
for i = 1:length(m_range)
    m = m_range(i);
    fprintf('Calculating Bubble Entropy for m=%d...\n', m);

    % Loop through all NSR records
    for j = 1:length(nsr_rr_clean)
        % Check if signal length is sufficient for the maximum m tested, plus buffer
        if length(nsr_rr_clean{j}) > max(m_range) + 100  
            results.bubble_nsr(j, i) = bubble_entropy(nsr_rr_clean{j}, m);
        else
            results.bubble_nsr(j, i) = NaN; % Mark invalid records
        end
    end
    
    % Loop through all CHF records
    for j = 1:length(chf_rr_clean)
        if length(chf_rr_clean{j}) > max(m_range) + 100
            results.bubble_chf(j, i) = bubble_entropy(chf_rr_clean{j}, m);
        else
            results.bubble_chf(j, i) = NaN;
        end
    end
end

% Calculate Sample Entropy
% Since signals are pre-normalized to unit standard deviation (STD=1), 
% r=0.2 correctly implements the standard SampEn threshold of 0.2 * STD
fprintf('Calculating Sample Entropy...\n');

for j = 1:length(nsr_rr_clean)
    if length(nsr_rr_clean{j}) > 100
        results.sampen_nsr(j) = sample_entropy(nsr_rr_clean{j}, m_sampen, r_sampen);
    else
        results.sampen_nsr(j) = NaN;
    end
end
for j = 1:length(chf_rr_clean)
    if length(chf_rr_clean{j}) > 100
        results.sampen_chf(j) = sample_entropy(chf_rr_clean{j}, m_sampen, r_sampen);
    else
        results.sampen_chf(j) = NaN;
    end
end

% Data Cleaning
% Filter out patient records where calculation returned NaN
valid_nsr_bubble = all(~isnan(results.bubble_nsr), 2);
valid_chf_bubble = all(~isnan(results.bubble_chf), 2);
valid_nsr_sampen = ~isnan(results.sampen_nsr);
valid_chf_sampen = ~isnan(results.sampen_chf);

results.bubble_nsr = results.bubble_nsr(valid_nsr_bubble, :);
results.bubble_chf = results.bubble_chf(valid_chf_bubble, :);
results.sampen_nsr = results.sampen_nsr(valid_nsr_sampen);
results.sampen_chf = results.sampen_chf(valid_chf_sampen);

fprintf('Valid records: %d NSR, %d CHF for Bubble Entropy\n', sum(valid_nsr_bubble), sum(valid_chf_bubble));
fprintf('Valid records: %d NSR, %d CHF for Sample Entropy\n', sum(valid_nsr_sampen), sum(valid_chf_sampen));

%% Statistical Analysis
% Calculate p-values for Bubble Entropy across all tested m values (two-sample t-test)
p_values_bubble = zeros(1, length(m_range));
for i = 1:length(m_range)
    if ~isempty(results.bubble_nsr) && ~isempty(results.bubble_chf)
        % Perform t-test: H0 = means are equal (no discrimination).
        [~, p_values_bubble(i)] = ttest2(results.bubble_nsr(:, i), results.bubble_chf(:, i));
    else
        p_values_bubble(i) = NaN;
    end
end

% Calculate p-value for Sample Entropy comparison
if ~isempty(results.sampen_nsr) && ~isempty(results.sampen_chf)
    [~, p_value_sampen] = ttest2(results.sampen_nsr, results.sampen_chf);
else
    p_value_sampen = NaN;
end

% Find the embedding dimension (m) that yields the best discrimination (minimum p-value)
[min_p, best_m_idx] = min(p_values_bubble);
best_m = m_range(best_m_idx);

% Plot the complexity distribution for a representative NSR patient using the optimal 'm'
plot_disorder_distribution(nsr_rr_clean{valid_nsr_bubble(1)}, best_m);

%% Output Numerical Summary
% Calculate summary statistics (means and standard deviations) for the best performing m
mean_nsr_ben = mean(results.bubble_nsr(:, best_m_idx));
mean_chf_ben = mean(results.bubble_chf(:, best_m_idx));
std_nsr_ben = std(results.bubble_nsr(:, best_m_idx));
std_chf_ben = std(results.bubble_chf(:, best_m_idx));

mean_nsr_sampen = mean(results.sampen_nsr);
mean_chf_sampen = mean(results.sampen_chf);

% Determine significance strings
ben_status_str = {'Not Significant', 'Statistically Significant'};
ben_status = ben_status_str{(min_p < 0.05) + 1}; % +1 converts logical (0 or 1) to index (1 or 2)

sampen_status_str = {'Not Significant', 'Statistically Significant'};
sampen_status = sampen_status_str{(p_value_sampen < 0.05) + 1};

fprintf('\nBubble Entropy Performance (at optimal m=%d):\n', best_m);
fprintf('   - Mean Bubble Entropy (NSR): %.3f\n', mean_nsr_ben);
fprintf('   - Mean Bubble Entropy (CHF): %.3f\n', mean_chf_ben);
fprintf('   - P-value (BEn): %.6f (%s)\n', min_p, ben_status);
fprintf('   - Standard Deviation (NSR): %.4f\n', std_nsr_ben);
fprintf('   - Standard Deviation (CHF): %.4f\n', std_chf_ben);
fprintf('\nSample Entropy Performance (at m=2, r=0.2):\n');
fprintf('   - Mean Sample Entropy (NSR): %.3f\n', mean_nsr_sampen);
fprintf('   - Mean Sample Entropy (CHF): %.3f\n', mean_chf_sampen);
fprintf('   - P-value (SampEn): %.6f (%s)\n', p_value_sampen, sampen_status);

%% Plot Results
plot_results(results, m_range, p_values_bubble, p_value_sampen);

%% Save results
% Save all variables to a .mat file in the 'code' folder for reproducibility and external access
save(fullfile(current_folder, 'results.mat'), 'results', 'm_range', 'p_values_bubble', 'p_value_sampen', 'best_m', 'min_p');
fprintf('Results saved in the current folder.\n');