%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2018 Crypto4a Technologies Inc.
%
% Permission is hereby granted, free of charge, to any person obtaining a 
% copy of this software and associated documentation files (the "Software"),
% to deal in the Software without restriction, including without limitation 
% the rights to use, copy, modify, merge, publish and/or distribute copies 
% of the Software, and to permit persons to whom the Software is 
% furnished to do so subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included 
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS 
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE 
% USE OR OTHER DEALINGS IN THE SOFTWARE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [h] = lz78y_prediction_estimate(input_data)
%
% This is an estimate of min_entropy for non-IID noise sources as specified
% in NIST SP-800-90B section 6.3.10 (January 2018). It is called the Lz78Y
% Prediction Estimate
%
% input_data:   vector of input elements (binary only). Can handle both 
%               horizontal and vertical vectors.
%
% h:            consists of an estimate of the min-entropy of a non-IID
%               entropy source
%
function [h] = lz78y_prediction_estimate(input_data)

    % Transposing the data if necessary
    if size(input_data, 1) > size(input_data, 2)
        input_data = transpose(input_data);
    end

    %Initializing a few parameters
    L                    = length(input_data);
    B                    = 16;
    N                    = L - B - 1;
    dictionnarySize      = 0;
    maxDictionnarySize   = 65536;
    D                    = ones(2, 2^(B+1)-1) * -1;  % We initialize D with null values (-1)
    correct              = zeros(1, N);
    precision            = 0.001;                    % Level of precision used in solving for P_local
    prev                 = zeros(B, N);
    index_row            = 1;                        % We set the initial value to 1 to avoid errors due to Matlab's indexing

    % Generating the prev array to make computations more efficient
    for i = 1 : B
        [~, prev(i, 1 : L-i+1), ~] = find_repeated_str(input_data, i);
    end

    % Going through the data (step 3)
    for i = B+2:L
    
        % Creating the dictionnary
        % The rows of dictionnary D will be for the different possible outputs 
        % from the data (0 -> 1st row, 1 -> 2nd row, etc.). The column will be 
        % given with an offset according to the previous outputs of variable 
        % lengths(0 -> 1st col, 1 -> 2nd col, 00 -> 3rd col, 10
        % -> 4th col, etc.)
        for j = B : -1 : 1

                if dictionnarySize < maxDictionnarySize
                current_sequence = prev(j, i-j-1);                              % Equivalent to s(i-j-1)...s(i-2) where s is input_data
                memory_offset = 2^(j-1);                                        % Adding memory offset to distinguish sequence lengths
                col = memory_offset + current_sequence;
                D(input_data(i-1)+1, col) = D(input_data(i-1)+1, col) + 1; 
                if D(input_data(i-1)+1, col) == 0                               % Since -1 corresponds to NULL, we add a new element when we see a zero
                    dictionnarySize = dictionnarySize + 1;
                    D(input_data(i-1)+1, col) = D(input_data(i-1)+1, col) + 1;  % Adding the new element to D
                end
            end
        end

        % Trying to predict the next value
        prediction = -1;
        maxcount = 0;
        for j = B : -1 : 1 
            loop_prev = prev(j, i-j) + 2^(j-1);              % We use our memory offset. loop_prev then corresponds to the col in D
        
            % (ii) Since every column of D is associated to a value of "prev",
            % we check if it's in the dictionnary by checking the column
            if any(D(:, loop_prev) ~= -1)
                % Since it is binary, we check if y = 1 has been counted more
                % often
                if D(1, loop_prev) <= D(2, loop_prev)
                    y = 1;
                else
                    y = 0;
                end
                index_row = y + 1;                           % Takes Matlab's indexing into account

            end
            % (iii)
            if D(index_row, loop_prev) > maxcount            % Index_row is 1 bigger than y for Matlab's indexing
                prediction = y;                                            
                maxcount = D(index_row, loop_prev);
            end
        end
        if prediction == input_data(i)
            correct(i-B-1) = 1;
        end
    end
 
    % Number of correct predictions
    C = sum(correct);

    % Calculating the predictor's global performance and the upper bound of the
    % 99% confidence interval
    P_global = C/N;
    if P_global == 0
        P_prime_global = 1-0.01^(1/N);
    else
        P_prime_global = min(1, P_global + 2.576 * sqrt((P_global * (1-P_global))/(N-1)));
    end

    % We now find the longest run of correct predictions
    r = 0;
    count = 1;
    for i = 1:N-1
    
       % Keep adding to the run
       if correct(i) == 1 && correct(i+1) == correct(i)
           count = count+1; 
       % Checking for new record and resetting the counter
       else
           if count > r
               r = count;
           end
           count = 1;
       end
   
       % Dealing with the last element
       if i == N-1 && count > r
           r = count;
       end  
    end
    r = r + 1;

    % Instead of using a binary search, we use Matlab's vectors to find the 
    % minimum difference between the two sides of the equation. The x_function
    % is an iterative function.
    P_local = 0:precision:1;
    q       = 1 - P_local;
    equation_vec1 = (1 - P_local.*x_function(P_local, r))./(((r + 1 - ...
                    r.*x_function(P_local, r)).*q).*x_function(P_local...
                    , r).^(N+1));
    equation_vec2 = 0.99 * ones(1, 1/precision +1);

    [~, best_p_index] = min(abs(equation_vec2-equation_vec1));

    % Best_p_index was actually the index of best value for P_local
    best_P_local = P_local(best_p_index);

    % Measuring the min-entropy
    h = -log2(max([P_prime_global best_P_local 1/2]));
end
