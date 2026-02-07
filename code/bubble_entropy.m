%% Bubble Entropy Project - Bubble Entropy Function

function bEn = bubble_entropy(x, m)
% Calculates the Bubble Entropy of the time series x for embedding dimension m
    if m < 3
        error('Embedding dimension m must be at least 3');
    end
    
    N = length(x);
    if N < (m + 1) * 10
        warning('Time series might be too short for reliable entropy estimation');
    end

    % Process for dimension m
    % Create embedded vectors of length m and quantify complexity using swap count
    swaps_m = zeros(1, N - m + 1);
    % Extract all m-dimensional vectors
    for i = 1:(N - m + 1)
        vec = x(i:i + m - 1);
        % The core feature: count swaps required by bubble sort
        swaps_m(i) = count_bubble_swaps(vec);
    end
    
    %  Create Coarse-Grained Probability Distribution
    % Maximum possible swaps for a vector of length m is m*(m-1)/2
    max_swaps_m = m * (m - 1) / 2;
    % Create histogram of swap counts
    [counts_m, ~] = histcounts(swaps_m, 0:max_swaps_m+1);

    % Normalize histogram to obtain probabilities
    p_m = counts_m / sum(counts_m);
    p_m = p_m(p_m > 0); % Remove zero probabilities
    
    % Calculate Rényi Entropy (H2) of order alpha=2
    if isempty(p_m)
        H2_m = 0; % Handle case of insufficient data/uniform pattern
    else
        H2_m = -log(sum(p_m .^ 2));
    end

    % Process for Dimension m+1
    % Repeat the entire procedure for vectors of length m+1
    swaps_m1 = zeros(1, N - m);
    for i = 1:(N - m)
        vec = x(i:i + m); % Vector of length m+1
        swaps_m1(i) = count_bubble_swaps(vec);
    end
    
    max_swaps_m1 = (m + 1) * m / 2;
    [counts_m1, ~] = histcounts(swaps_m1, 0:max_swaps_m1+1);
    p_m1 = counts_m1 / sum(counts_m1);
    p_m1 = p_m1(p_m1 > 0); % Remove zero probabilities
    
    % Calculate Rényi Entropy (H2)
    if isempty(p_m1)
        H2_m1 = 0;
    else
        H2_m1 = -log(sum(p_m1 .^ 2));
    end

    % Calculate Conditional Bubble Entropy
    % The result is the conditional difference between H2(m+1) and H2(m), normalized
    
    % Normalization factor: log( (m+1) / (m-1) )
    normalization_factor = log( (m+1) / (m-1) );
    
    if normalization_factor == 0 || H2_m1 <= H2_m % Check for division by zero or non-increasing entropy
        bEn = 0;
    else
        % Conditional entropy is the difference in Rényi entropy divided by the normalization factor
        bEn = (H2_m1 - H2_m) / normalization_factor;
    end
    
end
