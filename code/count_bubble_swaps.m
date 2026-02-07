function num_swaps = count_bubble_swaps(vec)
% Counts the number of swaps required to sort a vector using the bubble sort algorithm
    
    n = length(vec);
    data = vec; % Create a copy to perform the sort on
    num_swaps = 0;
    
    % Outer loop: Controls the number of passes needed (n-1 passes max)
    for i = 1:n-1
        % Inner loop: Compares adjacent elements in the unsorted portion (n-i)
        for j = 1:n-i
            % Comparison step: If the current element is greater than the next, swap
            if data(j) > data(j+1)

                % Perform the adjacent swap
                temp = data(j);
                data(j) = data(j+1);
                data(j+1) = temp;

                % Increment the swap counter
                num_swaps = num_swaps + 1;
            end
        end
    end
end
