function plot_disorder_distribution(test_signal, m)
% Illustrates the conceptual histogram of swap counts.

    N = length(test_signal);
    
    % Generate all Swap Counts for dimension m
    swaps_m = zeros(1, N - m + 1);
    
    for i = 1:(N - m + 1)
        vec = test_signal(i:i + m - 1);
        swaps_m(i) = count_bubble_swaps(vec); 
    end
    
    % Build the Probability Distribution
    max_swaps = m * (m - 1) / 2;
    swap_counts_indices = 0:max_swaps;
    
    % Create histogram and normalize to get the probability vector
    [counts, ~] = histcounts(swaps_m, 0:max_swaps+1);
    full_p = counts / sum(counts);
    
    
    % Plotting
    
    figure('Position', [100, 100, 700, 500]);
    bar(swap_counts_indices, full_p, 'FaceColor', [0.1 0.5 0.8]);
    
    xlabel('Swap Count (n) - Measure of Structural Disorder');
    ylabel('Probability P(n)');
    title(sprintf('Bubble Entropy Disorder Distribution (m=%d)', m));
    
    xticks(swap_counts_indices);
    grid on;
    
    % Annotate the concept on the plot
    text(0, max(full_p)*0.95, 'Low Disorder (Regular)', 'HorizontalAlignment', 'left', 'FontSize', 10, 'FontWeight', 'bold');
    text(max_swaps, max(full_p)*0.95, 'High Disorder (Complex)', 'HorizontalAlignment', 'right', 'FontSize', 10, 'FontWeight', 'bold');
end
