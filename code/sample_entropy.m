%% Bubble Entropy Project - Sample Entropy Function

function e = sample_entropy(x, m, r)
% Calculates Sample Entropy, which measures the complexity of a time series
% by calculating the logarithmic ratio of template matches of length m+1 to m

    N = length(x);
    if N < m + 2
        e = NaN;
        return;
    end
    
    % B: Count of matching template pairs of length m
    % A: Count of matching template pairs of length m+1
    B = 0;
    A = 0;
    
    % Define the maximum possible number of template vectors for length m and m+1
    Nm = N - m;       % Total template vectors of length m
    Nm1 = N - m - 1;  % Total template vectors of length m+1
    
    % Counting Loop: Exclude self-matches (j > i)

    % Loop through all possible starting points for the first vector (i)
    for i = 1:Nm
        % Extract template vector X_i (length m)
        template_m = x(i : i + m - 1);
        
        % Loop through all subsequent starting points for the second vector (j > i)
        for j = (i + 1) : Nm
            % Extract comparison vector X_j (length m)
            comparison_m = x(j : j + m - 1);
            
            % Check similarity for length m using max norm (Chebyshev distance)
            dist_m = max(abs(template_m - comparison_m));
            
            if dist_m <= r
                % Match found for length m (increment total count B)
                B = B + 1;
                
                % Check if this match also extends to length m+1
                if j <= Nm1 && i <= Nm1 % j must be a valid starting point for an m+1 vector
                    
                    % Check the m+1 element: x(i+m) vs x(j+m)
                    dist_m1_extension = abs(x(i + m) - x(j + m));
                    
                    if dist_m1_extension <= r
                        % Match found for length m+1 (increment total count A)
                        A = A + 1;
                    end
                end
            end
        end
    end
    
% Final Sample Entropy Calculation
    
    % Use the mathematically robust formula: e = -log( (A/Nm1) / (B/Nm) )
    % This form accounts for the different number of total possible vectors (N-m vs N-m-1)
    
    if Nm1 <= 0 || B == 0 
        % Handle cases where N is too small or no matches were found.
        e = Inf; 
        
    else
        % Normalize counts to get probabilities
        A_norm = A / Nm1; % A normalized by the number of m+1 templates
        B_norm = B / Nm;  % B normalized by the number of m templates
        
        if B_norm == 0
            e = Inf; 
        else
            e = -log(A_norm / B_norm);
        end
    end
end