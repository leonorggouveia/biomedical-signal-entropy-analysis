%% Bubble Entropy Project - Plot Generating Function

function plot_results(results, m_range, p_values_bubble, p_value_sampen)
% Generates and displays plots
    
    % Find the embedding dimension 'm' that yielded the lowest p-value (best discrimination)
    [min_p, best_m_idx] = min(p_values_bubble);
    best_m = m_range(best_m_idx);
    
    % Calculate Mean and Standard Deviation for stability plots (Figures 2 & 3)
    mean_nsr = mean(results.bubble_nsr, 1);
    mean_chf = mean(results.bubble_chf, 1);
    std_nsr = std(results.bubble_nsr, 0, 1);
    std_chf = std(results.bubble_chf, 0, 1);

    % Figure 1: Discrimination Power (p-value vs m) and Combined Boxplot
    figure('Position', [100, 100, 1200, 500]);
    
    % Subplot 1: Discriminating Power (p-value vs m)
    subplot(1, 2, 1);
    % Plot Bubble Entropy p-values (The lower, the better the discrimination)
    semilogy(m_range, p_values_bubble, 'ro-', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'DisplayName', 'Bubble Entropy');
    hold on;
    
    % Plot Sample Entropy p-value as a constant horizontal line for comparison
    sampen_x = [min(m_range), max(m_range)];
    semilogy(sampen_x, [p_value_sampen, p_value_sampen], 'k--', 'LineWidth', 2, ...
             'DisplayName', sprintf('Sample Entropy (p=%.4f)', p_value_sampen));
    
    yline(0.05, 'g--', 'p=0.05', 'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom');
    
    xlabel('Embedding Dimension m');
    ylabel('p-value (log scale)');
    title('Discriminating Power: BEn vs SampEn (NSR vs CHF)');
    legend('Location', 'northeast');
    grid on;
    
    % Subplot 2: Combined Box Plots (BEn vs SampEn)
    % Visually compares the separation of groups for the two entropy types
    subplot(1, 2, 2);
    
    % Data preparation for combined box plot (Groups 1-4)
    box_data = [results.bubble_nsr(:, best_m_idx); results.bubble_chf(:, best_m_idx); ...
                results.sampen_nsr; results.sampen_chf];
    
    % Define group labels: 1=BEn NSR, 2=BEn CHF, 3=SampEn NSR, 4=SampEn CHF
    groups = [ones(size(results.bubble_nsr(:, best_m_idx))); ...
              2*ones(size(results.bubble_chf(:, best_m_idx))); ...
              3*ones(size(results.sampen_nsr)); ...
              4*ones(size(results.sampen_chf))];
    
    % Generate boxplot showing median, quartiles, and outliers
    boxplot(box_data, groups, 'Labels', {'BEn NSR', 'BEn CHF', 'SampEn NSR', 'SampEn CHF'}, ...
            'boxstyle', 'outline');
    
    title(sprintf('Distribution Comparison (BEn m=%d, SampEn m=2, r=0.2)', best_m));
    ylabel('Entropy Value (Normalized)');
    grid on;
    
    % Annotate the p-values directly onto the boxplot for immediate reference
    y_lim = ylim;
    text(1.5, y_lim(2)*0.95, sprintf('BEn p = %.2e', min_p), ...
         'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10, 'Color', 'r');
    text(3.5, y_lim(2)*0.95, sprintf('SampEn p = %.2e', p_value_sampen), ...
         'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10, 'Color', 'k');

    % Figure 2: Stability Plot (Mean vs m)
    figure('Position', [100, 600, 800, 400]);
    
    % Plot mean entropy with standard deviation as error bars
    errorbar(m_range, mean_nsr, std_nsr, 'bo-', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'b');
    hold on;
    errorbar(m_range, mean_chf, std_chf, 'ro-', 'LineWidth', 2, 'MarkerSize', 6, 'MarkerFaceColor', 'r');
    
    xlabel('Embedding Dimension m');
    ylabel('Mean Bubble Entropy');
    title('Bubble Entropy Mean vs. Embedding Dimension (Stability)');
    % The flatness of these lines after m=5 confirms BEn's robustness to 'm' selection
    legend('NSR Mean \pm Std', 'CHF Mean \pm Std', 'Location', 'best');
    grid on;
    
    % Figure 3: Variability Plot (Standard Deviation vs m)
    % This plot explicitly shows how the estimate variability changes with dimension 'm'
    figure('Position', [900, 600, 800, 400]);
    
    plot(m_range, std_nsr, 'b-^', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b');
    hold on;
    plot(m_range, std_chf, 'r-s', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    
    xlabel('Embedding Dimension m');
    ylabel('Standard Deviation (\sigma) of Bubble Entropy');
    title('Variability of Bubble Entropy vs. Embedding Dimension');
    % Low, constrained sigma, especially for CHF, reinforces the method's reliability
    legend('NSR Variability (\sigma)', 'CHF Variability (\sigma)', 'Location', 'best');
    grid on;
end
